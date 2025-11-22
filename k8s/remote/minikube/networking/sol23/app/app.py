from flask import Flask, jsonify, request
import logging
import os

app = Flask(__name__)

# Configure logging to show route access
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

@app.route('/')
def home():
    logger.info(f"Accessed: / - Method: {request.method} - Headers: {dict(request.headers)}")
    return jsonify({
        "message": "Welcome to API Demo",
        "routes": [
            "/api/v1/users",
            "/api/v1/products", 
            "/api/v1/orders",
            "/api/v1/health",
            "/api/v2/users",
            "/api/v2/products"
        ]
    })

@app.route('/api/v1/users', methods=['GET', 'POST'])
def users_v1():
    logger.info(f"Accessed: /api/v1/users - Method: {request.method}")
    if request.method == 'POST':
        return jsonify({"message": "User created", "method": "POST", "version": "v1"})
    return jsonify({"users": ["user1", "user2", "user3"], "version": "v1"})

@app.route('/api/v1/products')
def products_v1():
    logger.info(f"Accessed: /api/v1/products - Method: {request.method}")
    return jsonify({"products": ["product1", "product2"], "version": "v1"})

@app.route('/api/v1/orders')
def orders_v1():
    logger.info(f"Accessed: /api/v1/orders - Method: {request.method}")
    return jsonify({"orders": ["order1", "order2"], "version": "v1"})

@app.route('/api/v1/health')
def health_v1():
    logger.info(f"Accessed: /api/v1/health - Method: {request.method}")
    return jsonify({"status": "healthy", "version": "v1"})

@app.route('/api/v2/users')
def users_v2():
    logger.info(f"Accessed: /api/v2/users - Method: {request.method}")
    return jsonify({"users": ["v2_user1", "v2_user2"], "version": "v2"})

@app.route('/api/v2/products')
def products_v2():
    logger.info(f"Accessed: /api/v2/products - Method: {request.method}")
    return jsonify({"products": ["v2_product1", "v2_product2"], "version": "v2"})

@app.route('/api/echo', methods=['POST'])
def echo():
    data = request.get_json()
    logger.info(f"Accessed: /api/echo - Method: {request.method} - Data: {data}")
    return jsonify({"echo": data, "received": True})

@app.route('/api/status/<status_code>')
def status_code_test(status_code):
    logger.info(f"Accessed: /api/status/{status_code} - Method: {request.method}")
    try:
        code = int(status_code)
        return jsonify({"status": code}), code
    except ValueError:
        return jsonify({"error": "Invalid status code"}), 400

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5000))
    app.run(host='0.0.0.0', port=port, debug=True)
