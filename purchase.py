from flask import jsonify, Blueprint, request
from confige import db
from flask_jwt_extended import current_user, jwt_required
from models import UserInterface

purchase_bp = Blueprint("purchase", __name__)

@purchase_bp.get("/buy")
@jwt_required()
def purchase():
    purchases = UserInterface.query.first().data.get("purchases")
    current = purchases.get(request.args.get("id", ""))
    if current:
        score = current_user.data.get("score", 0)
        if score >= current:
            score -= current
            current_user.data = current_user.update(data={"score":int(score)}, overwrite=False)
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