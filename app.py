from flask import Flask
from waitress import serve  # Production WSGI server

app = Flask(__name__)

@app.route('/')
def hello():
    return "Hello, My CI/CD pipeline is working or not? Let's see."

@app.route('/health')
def health():
    return "OK", 200

if __name__ == '__main__':
    # Production server
    serve(app, host='0.0.0.0', port=5000)