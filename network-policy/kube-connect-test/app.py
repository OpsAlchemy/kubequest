from flask import Flask, render_template, request
import socket
import time
import os

app = Flask(__name__)
POD_NAME = os.environ.get("POD_NAME", "unknown-pod")
THEME_COLOR = os.environ.get("THEME_COLOR", "#17a2b8")

def test_connection(host, port, proto):
    result = {}
    try:
        start = time.time()
        if proto.lower() == "tcp":
            with socket.create_connection((host, int(port)), timeout=2) as s:
                pass
        else:
            return {"status": "Unsupported protocol", "success": False}
        duration = int((time.time() - start) * 1000)
        result = {"status": f"✅ Success in {duration}ms", "success": True}
    except Exception as e:
        result = {"status": f"❌ {type(e).__name__}: {e}", "success": False}
    return result

@app.route("/", methods=["GET", "POST"])
def index():
    results = []
    if request.method == "POST":
        entries = request.form["batch_input"].strip().splitlines()
        for line in entries:
            try:
                if not line.strip():
                    continue
                parts = line.strip().split(":")
                host = parts[0]
                port = parts[1] if len(parts) > 1 else "80"
                proto = parts[2] if len(parts) > 2 else "tcp"
                res = test_connection(host, port, proto)
                results.append({
                    "host": host,
                    "port": port,
                    "proto": proto.upper(),
                    "result": res["status"],
                    "success": res["success"]
                })
            except Exception as e:
                results.append({
                    "host": line,
                    "port": "-",
                    "proto": "-",
                    "result": f"Invalid format: {e}",
                    "success": False
                })
    return render_template("index.html", results=results, pod_name=POD_NAME, color=THEME_COLOR)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)

