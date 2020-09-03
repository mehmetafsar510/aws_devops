from flask import Flask, render_template

app = Flask(__name__)

@app.route("/")
def head():
    return render_template("index.html", hazırlayan = "mehmet")

if __name__ == "__main__":
    app.run(debug=True)