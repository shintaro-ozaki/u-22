from flask import Flask, jsonify, request
from flask_cors import CORS
import paypayopa


API_KEY="a_skHc4tc3WQ_PD4m"
API_SECRET="ex7PTkYWG/b68MronstUx6Va7JJnXvdCZG8WoE4Owug="
MERCHANT_ID="563062778299113472"

client = paypayopa.Client(auth=(API_KEY, API_SECRET),
                        production_mode=False)
client.set_assume_merchant(MERCHANT_ID)
app = Flask(__name__)
CORS(app)


@app.route("/")
def hello():
    print("hello")
    return {"message": "hello"}

@app.route('/donate', methods=["POST"])
def donate():
    output = {}
    data = request.get_json()
    response = client.Code.create_qr_code(data)
    output["redirectUrl"] = response['data']['url']
    return jsonify(output)

@app.route("/detail")
def smartpay():
    response = client.Payment.get_payment_details(MERCHANT_ID)
    print(response)
    return jsonify(response)


if __name__ == "__main__":
    # need to change address where you are located in.
    app.run(host='192.168.10.101', port=5001, debug=True)