from flask import Flask, request, redirect, jsonify
import time
import requests

app = Flask(__name__)

class MoneyAmount:
    def __init__(self):
        self.amount_value = None
        self.currency_value = None
    
    def amount(self, amount):
        self.amount_value = amount
        return self
    
    def currency(self, currency):
        self.currency_value = currency
        return self

class QRCode:
    def __init__(self):
        self.amount = MoneyAmount()
        self.merchantPaymentId = None
        self.codeType = None
        self.orderItems = []
        self.orderDescription = None
        self.isAuthorization = None
        self.redirectUrl = None
        self.redirectType = None
        self.userAgent = None

class PaymentApi:
    def __init__(self, apiClient):
        self.apiClient = apiClient

    def createQRCode(self, qrCode):
        # Implement your createQRCode logic here
        pass

class PaypayApiAdaptor:
    def __init__(self, apiClient):
        self.apiClient = apiClient
    
    def createQrCode(
        self,
        merchantPaymentId,
        amount,
        orderItems,
        orderDescription,
        isAuthorization,
        redirectUrl,
        redirectType,
        userAgent
    ):
        qrCode = QRCode()
        qrCode.amount = MoneyAmount().amount(amount).currency('JPY')
        qrCode.merchantPaymentId = merchantPaymentId
        qrCode.codeType = 'ORDER_QR'
        qrCode.orderItems = orderItems
        qrCode.orderDescription = orderDescription
        qrCode.isAuthorization = isAuthorization
        qrCode.redirectUrl = redirectUrl
        qrCode.redirectType = redirectType
        qrCode.userAgent = userAgent

        payment_api = PaymentApi(self.apiClient)
        return payment_api.createQRCode(qrCode)

api_client = "a_skHc4tc3WQ_PD4m"  # Initialize your API client here
paypay_api_adaptor = PaypayApiAdaptor(api_client)

@app.route('/order', methods=['POST'])
def order():
    data = request.get_json()
    merchant_payment_id = str(int(time.time() * 1000))  # Equivalent to Instant.now().toEpochMilli().toString() in Kotlin

    order_items = [
        {
            "name": "バウムクーヘン",
            "category": "ケーキ",
            "productId": "XXX001",
            "quantity": data.get("quantity"),
            "unitPrice": MoneyAmount().amount(500).currency("JPY")
        }
    ]

    response = paypay_api_adaptor.createQrCode(
        merchantPaymentId=merchant_payment_id,
        amount=sum(item["unitPrice"].amount_value * item["quantity"] for item in order_items),
        orderItems=order_items,
        orderDescription="注文説明",
        isAuthorization=None,
        redirectUrl="http://localhost:8080/paymentDetails/%s" % merchant_payment_id,
        redirectType="WEB_LINK",
        userAgent=None
    )

    print(response)

    return redirect(response.data.url)

if __name__ == "__main__":
    app.run(port=5001, debug=True)
