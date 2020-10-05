from flask import Flask, render_template, request

def convert(milliseconds):
    seconds=(milliseconds/1000)%60
    seconds = int(seconds)
    minutes=(milliseconds/(1000*60))%60
    minutes = int(minutes)
    hours=(milliseconds/(1000*60*60))%24
    result = ''
    if milliseconds < 1000:
        result = ("Just %d millisecond/s" % (milliseconds))
    elif milliseconds < 60000:
        result = ("%d second/s" % (seconds))
    elif milliseconds < 360000:
        result = ("%d minute/s %d second/s" % (minutes, seconds))
    elif milliseconds < (24*360000):
        result = ("%d hour/s %d minute/s %d second/s" % (hours, minutes, seconds))
    return result


app = Flask(__name__)

@app.route("/", methods=['GET'])
def main_get():
    return render_template('index.html', developer_name='LIMA', not_valid=False)

@app.route("/", methods=['POST'])
def main_post():
    beta=request.form['number']
    if not beta.isdecimal():
        return render_template('index.html', developer_name='LIMA', not_valid=True)
    
    number=int(beta)
    if number < 0:
        return render_template('index.html', developer_name='LIMA', not_valid=True)
    return render_template('result.html',  milliseconds = number, result = convert(number), developer_name = 'LIMA')

if __name__ == "__main__":
    app.run(debug=True)
    #app.run(host='0.0.0.0', port=80)
    