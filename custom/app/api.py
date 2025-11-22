from flask import Flask
import socket, requests, subprocess, os

app = Flask(__name__)
PORT = int(os.getenv('PORT', '8080'))
TEXT = os.getenv('TEXT', 'default app')

@app.route('/')
def hello():
    return f"{TEXT} running on port {PORT}"

@app.route('/tools')
def tools():
    return "curl, ping, dig, nslookup, nc, tcpdump, iperf3, nmap, redis, psql, mysql"

@app.route('/test/<host>')
def test(host):
    try:
        socket.gethostbyname(host)
        return f"{host} is reachable"
    except:
        return f"{host} not found"

if __name__ == '__main__': 
    app.run(host='0.0.0.0', port=PORT)
