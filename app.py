from flask import Flask
from waitress import serve  # Production WSGI server

app = Flask(__name__)

@app.route('/')
def hello():
    return "Hello, DevOps Learner! My CI/CD pipeline is working! Now, practice more and be professional in it."

@app.route('/health')
def health():
    return "OK", 200

if __name__ == '__main__':
    # Production server
    serve(app, host='0.0.0.0', port=5000)