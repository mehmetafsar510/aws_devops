from flask import Flask

app = Flask(__name__)

@app.route('/shipping')
def shipping():
    return '<h1>This is shipping service</h1>'

if __name__ == '__main__':
   app.run(host='0.0.0.0', port=80)