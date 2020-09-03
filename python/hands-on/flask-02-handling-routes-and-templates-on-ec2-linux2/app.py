from flask import Flask, render_template

app = Flask(__name__)

@app.route("/")
def head():
    first = "this is my first condition"
    return render_template("yeni.html", mesaj = first)


@app.route("/for")
def for_example():
    names = ["Mehmet", "ali", "hasan", "veysel"]
    return render_template("deneme.html", isimler = names)


if __name__ == "__main__":
    app.run(debug=True)