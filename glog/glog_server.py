import base64
import logging
import sys

from flask import Flask, request
from datetime import datetime

log = logging.getLogger('werkzeug')
log.setLevel(logging.ERROR)

app = Flask(__name__)


@app.route('/', methods=['POST'])
def result():
    """
    Just writes the data in the POST request to a file and echoes it out
    :return:
    """
    if 'GLog' in request.json:
        base64_received = request.json['GLog']
        base64_decode_received = base64.b64decode(base64_received)
        text = base64_decode_received.decode('UTF-8')
        payload = f"{ datetime.now().strftime('%d/%m/%Y, %H:%M:%S')} : {text}" 

        print(payload)

        with open("/Users/az/Desktop/notiblock.log", "a") as fo:
            fo.write(f"{payload}\n")
    return '\n'

def run_server(_port):
    app.run(host='0.0.0.0', port=_port, debug=False)


if __name__ == "__main__":
    if len(sys.argv) > 1:
        port = int(sys.argv[1])
    else:
        port = 5000
    run_server(port)
