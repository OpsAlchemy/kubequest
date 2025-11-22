https://killercoda.com/chadmcrowell/course/cka/rollback-deployment


controlplane:~$ k create deploy apache --image httpd
deployment.apps/apache created
controlplane:~$ k set deployments.apps/apache "httpd=httpd:2.4.54"
error: unknown command "deployments.apps/apache httpd=httpd:2.4.54"
See 'kubectl set -h' for help and examples
controlplane:~$ k set image deployments.apps/apache "*=httpd:2.4.54"
deployment.apps/apache image updated
controlplane:~$ k rollout undo deployment.apps/apache
deployment.apps/apache rolled back
controlplane:~$ 





