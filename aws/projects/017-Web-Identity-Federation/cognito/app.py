from flask import Flask, render_template, request

app = Flask(__name__)

@app.route('/', methods=['GET'])
def enter():
    return render_template('enter.html')

if __name__=='__main__':
    app.run('0.0.0.0',port=80)


