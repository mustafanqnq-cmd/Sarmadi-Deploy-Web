import os
from flask import Flask

app = Flask(__name__)

@app.route("/")
def hello():
    return "Tython is Alive!"

if __name__ == "__main__":
    # رايلوي ستعطي بورت تلقائي، وهوغينغ فيس سيأخذ 7860
    port = int(os.environ.get("PORT", 7860))
    app.run(host='0.0.0.0', port=port)
