from flask import Flask, redirect, url_for, render_template

app = Flask(__name__)

@app.route("/")


def home():
    return "this is my first page, <h1> welcome home </h1>"

@app.route("/about")
def about():
    return "<h1> this is my about page </h1>"

@app.route("/error")
def error():
    return '<h1>Either you encountered an error or you are not authorized.</h1>'

@app.route("/hello")
def hello():
    return '<h1>Hello, World! </h1>'

@app.route("/admin")
def admin():
    return redirect(url_for("error"))

#@app.route("/<name>")
#def greet(name):
   # return f"Hello, {name}"

#@app.route('/<name>')
#def greet(name):
    greet_format=f"""
<!DOCTYPE html>
<html>
<head>
    <title>Greeting Page</title>
</head>
<body>
    <h1>Hello, { name }!</h1>
    <h1>Welcome to my Greeting Page</h1>
</body>
</html>
    """
    #return greet_format

@app.route("/greet-admin")
def greet_admin():
    return redirect(url_for("greet", name="master admin!"))

@app.route("/<name>")
def greet(name):
    number1 = 23
    number2 = 24
    return render_template("greet.html", isim = name, number1 = 54, number2 = 24, toplam = number1 + number2 )

@app.route("/list10")
def list10():
    return render_template("list10.html")

@app.route("/evens")
def evens():
    return render_template("even.html")



if __name__ == "__main__":
    #app.run(debug=True)
    app.run(host='0.0.0.0', port=80)