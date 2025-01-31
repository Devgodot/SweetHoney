from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt, current_user
from models import User, UserInterface
from schemas import UserSchema
from sqlalchemy.sql import desc, text


user_bp = Blueprint("users", __name__)

@user_bp.get("/me")
@jwt_required()
def get_me():
    if "GodotEngine" in request.headers.get("User-Agent"):
        sort = request.args.get("sort")
        season = UserInterface.query.first().data.get("season", 1)
        if sort == "l":
            sort = f"league_score{season}"
        if sort and sort != "":
            users = User.query.order_by(desc( text(f"JSON_UNQUOTE(data->'$.{sort}')"))).all()
        else:
            users = User.query.all()
        previous_score = None
        current_position = 0
        for index, user in enumerate(users):
            current_score = user.data.get(request.args.get("sort"))
            if current_score != previous_score:
                current_position = index
            user.data['position'] = current_position + 1
            previous_score = current_score
            if current_user.data.get(sort) != None:
                for x, user in enumerate(users):
                    if user == current_user:
                        return jsonify({"message": "موقعیت شما طبق این رتبه بندی به شرح پیوست است", "pos":user.data["position"], "phone": current_user.phone, "num":current_user.data.get(sort, 0)})
            else:
                return jsonify({"message": "شما در این رتبه بندی وجود ندارید", "pos":0})
            
            
        return jsonify({"message": "لطفا پارامتر را مشخص کنید", "error":"sort=?"}), 400
    return "شما اجازه دسترسی ندارید", 400
    
@user_bp.get("/all")
@jwt_required()
def get_all_users():
    if "GodotEngine" in request.headers.get("User-Agent"):
        filter_data = []
        if request.args.get("filter"):
            filter_data =  request.args.get("filter").split("AND")
        sort = request.args.get("sort")
        season = UserInterface.query.first().data.get("season", 1)
        if sort == "l":
            sort = f"league_score{season}"
        page = request.args.get("page", default=1, type=int)

        per_page = request.args.get("per_page", default=3, type=int)
        if sort and sort != "":
            users = User.query.order_by(desc(text(f"JSON_UNQUOTE(data->'$.{sort}')"))).all()
        else:
            users = User.query.all()
        u = []
        for user in users:
            if sort and sort != "" and user.data.get(sort) != None:
                u.append(user)
            else:
                if not sort or sort == "":
                    u.append(user)
        u2 = []
        for x, user in enumerate(u):
            if x >= (page - 1) * per_page and x < page * per_page:
                u2.append(user)
        if filter_data:
            for user in u2:
                d = {}
                for key in filter_data:
                    k = key
                    if key == "l":
                        k = f"league_score{season}"
                    if user.data.get(k):
                        d[key] = user.data.get(k)
                user.data = d
        previous_score = None
        current_position = 0
        for index, user in enumerate(u2):
            current_score = user.data.get(request.args.get("sort"))
            if current_score != previous_score:
                current_position = index
            user.data['position'] = current_position
            previous_score = current_score
            result = UserSchema().dump(u2, many=True)

        return (
            jsonify(
                {
                    "users": result,
                }
            ),
            200,
        )
    return "شما اجازه دسترسی ندارید", 400

    