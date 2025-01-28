from flask import jsonify, Blueprint, request
from confige import db
from flask_jwt_extended import current_user, jwt_required
from models import UserInterface
import time
purchase_bp = Blueprint("purchase", __name__)

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
    print(purchases)
    if current:
        return jsonify({"num":current})
    else:
        return jsonify({"message":"خرید موجود نیست"})
