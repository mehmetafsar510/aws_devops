from flask import Flask, request, render_template

from milisecondsconverter import milisecondsconverter

app = Flask(__name__)

@app.route("/", methods=["GET", "POST"])
def adder_page():
    errors = ""
    if request.method == "POST":
        number = None             
        try:
            number = int(request.form["number"])
        except:
            errors += " ".format(request.form["number"])
                        
        if number is not None and number > 1000:
            miliseconds = milisecondsconverter(number)
            number = number
            return render_template ("result.html", miliseconds=miliseconds, number=number, developer_name = "Mehmet", valid = True)   
        elif number is not None and 0 <number < 1000:
            return render_template ("result.html", errors= number,developer_name = "Mehmet", validnot = True)
        else:
            errors += "Not Valid! Please enter a number greater than zero.\n".format(request.form["number"])

    return render_template ("index.html", errors=errors, developer_name = "Mehmet")
    
if __name__ == "__main__":
    #app.run(debug=True)
    app.run(host='0.0.0.0', port=8000)
