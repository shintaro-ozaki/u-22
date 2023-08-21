import os
import subprocess

from dotenv import load_dotenv
from flask import Flask, jsonify, request
from flask_cors import CORS
import paypayopa


load_dotenv()
API_KEY=os.getenv("API_KEY")
API_SECRET=os.getenv("API_SECRET")
MERCHANT_ID=os.getenv("MERCHANT_ID")

client = paypayopa.Client(auth=(API_KEY, API_SECRET),
                        production_mode=False)
client.set_assume_merchant(MERCHANT_ID)
app = Flask(__name__)
CORS(app)

@app.route('/donate', methods=["POST"])
def donate():
    output = {}
    data = request.get_json()
    print(data)
    response = client.Code.create_qr_code(data)
    output["redirectUrl"] = response['data']['url']

    # outputに1を入れて、1が返ってきたらinsert
    return jsonify(output)

if __name__ == "__main__":
    # need to change address where you are located in.
    app.run(host='0.0.0.0', port=5001, debug=True)