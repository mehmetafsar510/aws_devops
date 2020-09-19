from flask import Flask, request, render_template

from defliroman import int_to_rome

app = Flask(__name__)


@app.route("/", methods=["GET", "POST"])
def adder_page():
    errors = ""
    if request.method == "POST":
        number = None             
        try:
            number = float(request.form["number"])
        except:
            errors += " ".format(request.form["number"])
                        
        if number is not None and 0 < number < 4000:
            number_roman = int_to_rome(number)
            number_decimal = number
            return render_template ("result.html", number_roman=number_roman, number_decimal=number, developer_name = "Mehmet")    
        else:
            number is not None and 0 > number > 4000
            errors += " {!r} Not Valid! Please enter a number between 1 and 3999, inclusively..\n".format(request.form["number"])


    return render_template ("index.html", errors=errors, developer_name = "Mehmet")
    
if __name__ == "__main__":
    app.run(debug=True)
    #app.run(host='0.0.0.0', port=80)