import os
import random
from flask import Flask, redirect

app = Flask(__name__)

LINKS = [
    "https://chat.com/",
    "https://gemini.google.com/app",
    "https://grok.com/",
    "https://claude.ai/",
    "https://perplexity.ai/",
    "https://meta.ai/prompt/"
]

@app.route("/")
def go():
    return redirect(random.choice(LINKS), code=302)

if __name__ == "__main__":
    port = int(os.environ.get('PORT', 5000))
    app.run(host='0.0.0.0', port=port)
