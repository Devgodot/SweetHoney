from flask import jsonify, Blueprint, request
from confige import db
from flask_jwt_extended import current_user, jwt_required
from models import UserInterface
import time
purchase_bp = Blueprint("purchase", __name__)
import requests
def post_request(url, payload={}):
    headers = {
    'content-type': 'application/x-www-form-urlencoded',
    'X-Access-Token' : '1387b745-8344-4339-b0d9-4acc04692efb'
    }
    requests.packages.urllib3.disable_warnings()
    session2 = requests.Session()
    session2.verify = False

    response = session2.post(url, data=payload, headers=headers)
    return (response.text)

@purchase_bp.get("/buy")
@jwt_required()
def purchase():
    purchases = UserInterface.query.first().data.get("purchases")
    current = purchases.get(request.args.get("id", ""))
    name = request.args.get("id", "")
    if current:
        score = current_user.data.get("score", 0)
        data = current_user.data.get("open_hives", [0, 0, 0, 0])
        d = {}
        if score >= current:
            score -= current
            d["score"] = score
            for x in range(4):
                if name == f"hive{x}":
                    data[x] = 1
                    d[f"last_time_hive{x}"] = int(time.time())
            d["open_hives"] = data
            current_user.data = current_user.update(data=d, overwrite=False)
            db.session.commit()
            return jsonify({"num":score})
        else:
            return jsonify({"message":"امتیاز کافی نیست"})
    return jsonify({"message":"خرید موجود نیست"})


@purchase_bp.get("/cost")
@jwt_required()
def cost():
    purchases = UserInterface.query.first().data.get("purchases")
    current = purchases.get(request.args.get("id", ""))
    
    if current:
        return jsonify({"num":current})
    else:
        return jsonify({"message":"خرید موجود نیست"})
@purchase_bp.get("/consume")
@jwt_required()
def consume():
    token = request.get_json().get("token", "")
    result = post_request(f"https://developer.myket.ir/api/partners/applications/org.SweetHoney/purchases/products/league/tokens/{token}/consume")
    print(result)