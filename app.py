from flask import Flask, render_template
from prometheus_client import Counter, generate_latest

app = Flask(__name__)

REQUEST_COUNT = Counter('app_requests_total', 'Total Request Count')

@app.route("/")
def home():
    return render_template("index.html")

@app.route("/health")
def health():
    return {"status": "running"}

@app.route('/metrics')
def metrics():
    return generate_latest(), 200, {'Content-Type': 'text/plain'}

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
