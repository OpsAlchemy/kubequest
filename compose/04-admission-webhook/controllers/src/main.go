package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"os"
	"path/filepath"
	"strconv"

	admissionv1 "k8s.io/api/admission/v1"
	corev1 "k8s.io/api/core/v1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/apimachinery/pkg/runtime"
	"k8s.io/apimachinery/pkg/runtime/serializer"
	"k8s.io/client-go/kubernetes"
	rest "k8s.io/client-go/rest"
	"k8s.io/client-go/tools/clientcmd"
	"k8s.io/client-go/util/homedir"
)

var (
	scheme       = runtime.NewScheme()
	codecFactory = serializer.NewCodecFactory(scheme)
	deserializer = codecFactory.UniversalDeserializer()
)

var config *rest.Config
var clientSet *kubernetes.Clientset

type ServerParameters struct {
	port     int
	certFile string
	keyFile  string
}

var parameters ServerParameters

func init() {
	_ = corev1.AddToScheme(scheme)
	_ = admissionv1.AddToScheme(scheme)
}

func main() {
	useKubeConfig := os.Getenv("USE_KUBECONFIG")
	kubeConfigFilePath := os.Getenv("KUBECONFIG")

	flag.IntVar(&parameters.port, "port", 8443, "Webhook server port.")
	flag.StringVar(&parameters.certFile, "tlsCertFile", "/etc/webhook/certs/tls.crt", "File containing the x509 Certificate for HTTPS.")
	flag.StringVar(&parameters.keyFile, "tlsKeyFile", "/etc/webhook/certs/tls.key", "File containing the x509 private key to --tlsCertFile.")
	flag.Parse()

	if len(useKubeConfig) == 0 {
		c, err := rest.InClusterConfig()
		if err != nil {
			panic(err.Error())
		}
		config = c
	} else {
		var kubeconfig string
		if kubeConfigFilePath == "" {
			if home := homedir.HomeDir(); home != "" {
				kubeconfig = filepath.Join(home, ".kube", "config")
			}
		} else {
			kubeconfig = kubeConfigFilePath
		}
		fmt.Println("kubeconfig: " + kubeconfig)
		c, err := clientcmd.BuildConfigFromFlags("", kubeconfig)
		if err != nil {
			panic(err.Error())
		}
		config = c
	}

	cs, err := kubernetes.NewForConfig(config)
	if err != nil {
		panic(err.Error())
	}
	clientSet = cs

	http.HandleFunc("/", HandleRoot)
	http.HandleFunc("/mutate", HandleMutate)
	log.Printf("Starting webhook server on port %d", parameters.port)
	log.Fatal(http.ListenAndServeTLS(":"+strconv.Itoa(parameters.port), parameters.certFile, parameters.keyFile, nil))
}

func HandleRoot(w http.ResponseWriter, r *http.Request) {
	w.Write([]byte("Webhook Server is running!"))
}

func HandleMutate(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Invalid request method", http.StatusMethodNotAllowed)
		return
	}

	body, err := ioutil.ReadAll(r.Body)
	if err != nil {
		http.Error(w, fmt.Sprintf("Could not read request: %v", err), http.StatusBadRequest)
		return
	}
	defer r.Body.Close()

	// Parse admission request
	var admissionReviewReq admissionv1.AdmissionReview
	if _, _, err := deserializer.Decode(body, nil, &admissionReviewReq); err != nil {
		http.Error(w, fmt.Sprintf("Could not decode admission review: %v", err), http.StatusBadRequest)
		return
	}

	admissionResponse := &admissionv1.AdmissionResponse{
		UID:     admissionReviewReq.Request.UID,
		Allowed: true,
	}

	// Only mutate pods
	if admissionReviewReq.Request.Kind.Kind == "Pod" {
		// Get the pod object
		var pod corev1.Pod
		if err := json.Unmarshal(admissionReviewReq.Request.Object.Raw, &pod); err != nil {
			http.Error(w, fmt.Sprintf("Could not unmarshal pod: %v", err), http.StatusBadRequest)
			return
		}

		// Create patch operations to add labels
		var patch []map[string]interface{}

		// Add labels if they don't exist
		if pod.Labels == nil {
			patch = append(patch, map[string]interface{}{
				"op":    "add",
				"path":  "/metadata/labels",
				"value": map[string]string{},
			})
		}

		// Add custom labels
		labelsToAdd := map[string]string{
			"webhook-mutated":     "true",
			"injected-by-webhook": "example-webhook",
			"timestamp":           strconv.FormatInt(metav1.Now().Unix(), 10),
		}

		for key, value := range labelsToAdd {
			patch = append(patch, map[string]interface{}{
				"op":    "add",
				"path":  "/metadata/labels/" + escapeJSONPointer(key),
				"value": value,
			})
		}

		// Add an annotation
		annotationsPatch := map[string]interface{}{
			"op":    "add",
			"path":  "/metadata/annotations",
			"value": map[string]string{"webhook-injection": "completed"},
		}
		patch = append(patch, annotationsPatch)

		// Convert patch to JSON
		patchBytes, err := json.Marshal(patch)
		if err != nil {
			http.Error(w, fmt.Sprintf("Could not marshal patch: %v", err), http.StatusInternalServerError)
			return
		}

		// Set the patch in the response
		admissionResponse.Patch = patchBytes
		patchType := admissionv1.PatchTypeJSONPatch
		admissionResponse.PatchType = &patchType
	}

	// Create response
	admissionReviewRes := admissionv1.AdmissionReview{
		TypeMeta: metav1.TypeMeta{
			APIVersion: "admission.k8s.io/v1",
			Kind:       "AdmissionReview",
		},
		Response: admissionResponse,
	}

	responseBytes, err := json.Marshal(admissionReviewRes)
	if err != nil {
		http.Error(w, fmt.Sprintf("Could not marshal response: %v", err), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.Write(responseBytes)
}

// Helper function to escape JSON pointer special characters
func escapeJSONPointer(str string) string {
	// Replace ~ with ~0 and / with ~1
	result := ""
	for _, ch := range str {
		if ch == '~' {
			result += "~0"
		} else if ch == '/' {
			result += "~1"
		} else {
			result += string(ch)
		}
	}
	return result
}
