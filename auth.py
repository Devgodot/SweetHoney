from flask import Blueprint, jsonify, request, session
from flask_caching import Cache
from confige import db, app
from flask_jwt_extended import (
    create_access_token,
    create_refresh_token,
    jwt_required,
    get_jwt,
    current_user,
    get_jwt_identity,
)
from random import randint
import random
from models import User, TokenBlocklist, UserInterface, Levels
import json
cache = Cache(app, config={'CACHE_TYPE': 'SimpleCache'})

auth_bp = Blueprint("auth", __name__)

import requests, time
from enum import Enum
class HashingMode(Enum):
    ENCODE = 0
    DECODE = 1

words ={ "٠": "%zs%", "١": "%p3%", "٢": "%q6%", "٣": "%rz%", "٤": "%pi%", "٥": "%c5%", "٦": "%h5%", "٧": "%xa%", "٨": "%w1%", "٩": "%59%", "*": "%dh%", "$": "%n8%", "^": "%44%", "&": "%ga%", "۱": "%ry%", "۰": "%47%", "۲": "%j8%", "۳": "%4a%", "۴": "%w0%", "۵": "%df%", "۶": "%k5%", "۷": "%cq%", "۸": "%9v%", "۹": "%hu%", "ً": "%97%", "ٌ": "%vr%", "ٍ": "%q9%", "َ": "%8c%", "ُ": "%79%", "ِ": "%24%", "ـ": "%2c%", "؛": "%2v%", "«": "%1p%", "»": "%lz%", "ك": "%yz%", " ": "%08%", "‌": "%e7%", "!": "%6k%", "\"": "%wb%", "\'": "%ka%", "(": "%h7%", ")": "%gh%", "+": "%5g%", ",": "%4u%", "-": "%vb%", ".": "%z6%", "/": "%q7%", "0": "%qz%", "1": "%r6%", "2": "%2b%", "3": "%fj%", "4": "%0g%", "5": "%n3%", "6": "%cr%", "7": "%iz%", "8": "%ki%", "9": "%g5%", ":": "%uu%", ";": "%kq%", "<": "%96%", "=": "%26%", ">": "%sj%", "?": "%3y%", "@": "%19%", "[": "%5b%", "]": "%mf%", "_": "%9a%", "a": "%nx%", "b": "%zu%", "c": "%ir%", "d": "%zh%", "e": "%wi%", "f": "%h8%", "g": "%ue%", "h": "%50%", "i": "%xi%", "j": "%36%", "k": "%jj%", "l": "%wm%", "m": "%5x%", "n": "%7z%", "o": "%k1%", "p": "%c1%", "q": "%8u%", "r": "%n6%", "s": "%x3%", "t": "%91%", "u": "%6v%", "v": "%vs%", "w": "%d0%", "x": "%22%", "y": "%rd%", "z": "%b7%", "{": "%3r%", "}": "%v4%", "،": "%eh%", "؟": "%yv%", "ء": "%j5%", "أ": "%5h%", "ؤ": "%xe%", "إ": "%pj%", "ئ": "%3l%", "ا": "%2l%", "آ": "%dl%", "ب": "%r4%", "ة": "%1s%", "ت": "%c4%", "ث": "%wj%", "ج": "%ar%", "ح": "%x9%", "خ": "%2g%", "د": "%yg%", "ذ": "%7i%", "ر": "%ff%", "ز": "%1l%", "س": "%gy%", "ش": "%gr%", "ص": "%ph%", "ض": "%ap%", "ط": "%kb%", "ظ": "%wn%", "ع": "%mj%", "غ": "%bl%", "ف": "%v3%", "ق": "%04%", "ل": "%8i%", "م": "%9d%", "ن": "%wd%", "ه": "%4e%", "و": "%de%", "ي": "%sh%", "پ": "%x7%", "چ": "%ym%", "ژ": "%66%", "ک": "%8q%", "گ": "%7d%", "ی": "%xl%" }
def find_key_by_value(dictionary, target_value):
    for key, value in dictionary.items():
        if value == target_value:
            return key
    return None
def hashing(mode:HashingMode, text=""):
	if mode == HashingMode.ENCODE:
		hash_text = ""
		for graph in text:
			hash_text += words.get(graph)
		return hash_text
	if mode == HashingMode.DECODE:
		new_text = ''
		graphs = text.split("%")
		for graph in graphs:
			if graph != "" and graph != "%":
				new_text += find_key_by_value(words, "%"+str(graph)+"%")
		return new_text

def post_request(url, payload={}):
    headers = {
    'content-type': 'application/x-www-form-urlencoded'
    }

    requests.packages.urllib3.disable_warnings()
    session2 = requests.Session()
    session2.verify = False

    response = session2.post(url, data=payload, headers=headers)

    return (response.text)

@auth_bp.post("/verify")
def verify_user():
    data = request.get_json()
    code = str(randint(0, 9)) + str(randint(0, 9)) + str(randint(0, 9)) + str(randint(0, 9)) 
    cache.set('code', code, timeout=300)
    game = data.get("game", "")
    phone :str= data.get("phone")
    if not phone.startswith("09") or len(phone) != 11:
        return jsonify({"error":"فرمت شماره نامعتبر است"}), 400
    print(code)
    data = {
    'username': "09999876739",
    'password': "0O3LH",
    'to': phone,
    'text': f"با سلام\nبه بازی {game} خوش آمدید\n کد تائید شما جهت ورود در بازی :\n{code}",
    'from': "", 
    'fromSupportOne': "", 
    'fromSupportTwo': ""
    }
    return jsonify({"message":"در انتظار تائید", "response":post_request(url="https://rest.payamak-panel.com/api/SmartSMS/Send", payload=data)})
    


@auth_bp.get("/random_levels")
@jwt_required()
def get_random_levels():
    if "GodotEngine" in request.headers.get("User-Agent"):
        season = UserInterface.query.first().data.get("season", "1")
        part = request.args.get("part", 0)
        num_levels = UserInterface.query.first().data.get("laps_allowed"+str(season))[int(part)]
        # Query all levels from the database
        all_levels = Levels.query.filter_by(part=str(part), type="لیگ").all()
        # Get the list of level IDs already in league_levels
        existing_level_ids = current_user.data.get(f"league_levels_{part}_{season}", [[], 0])[0]
        level_ids = [int(level.get("id", 0)) for level in existing_level_ids]
        # Filter out levels that are already in the league_levels list
        available_levels = [level for level in all_levels if level.id not in level_ids]
        random_levels = [Levels.query.filter_by(id=id).first() for id in level_ids]
        # If the number of selected levels is less than num_levels, add additional levels
        while len(random_levels) < num_levels:
            if len(available_levels) == 0:
                break
            random_levels.append(random.choice(available_levels))
        while len(random_levels) > num_levels:
            random_levels.pop()
        random_levels = list(set(random_levels))
        level_data = []
        for x, level in enumerate(random_levels):
            level_info = {
                "id": level.id,
                "state": current_user.data.get(f"league_levels_{part}_{season}", [[], 0])[0][x].get("state", 0) if len(current_user.data.get(f"league_levels_{part}_{season}", [[], 0])[0]) > x else 0,
                "score": current_user.data.get(f"league_levels_{part}_{season}", [[], 0])[0][x].get("score", 0) if len(current_user.data.get(f"league_levels_{part}_{season}", [[], 0])[0]) > x else 0
            }
            level_data.append(level_info)
        total_score = sum(json.loads(hashing(HashingMode.DECODE, level.data.get("data"))).get("score", 0) for level in random_levels)

        current_user.data = current_user.update(data={f"league_levels_{part}_{season}":[level_data, total_score]}, overwrite=False)
        db.session.commit()
        return jsonify({"level_data": level_data, "total_score": total_score})
    return "شما اجازه دسترسی ندارید", 400
@auth_bp.post("/register")
def register_user():
    data = request.get_json()
    if data.get("code") == cache.get("code"):
        username = "user"+str(len(User.query.all()))
        user_p = User.get_user_by_phone(phone=data.get("phone"))
        if user_p is not None:
            user = User.get_user_by_phone(phone=data.get("phone"))
            access_token = create_access_token(identity=user.username, expires_delta=False)
            refresh_token = create_refresh_token(identity=user.username)
            return (
                jsonify(
                    {
                        "message": "Logged In ",
                        "tokens": {"access": access_token, "refresh": refresh_token, "id":user.id},
                    }), 200)
        else:
            phone :str= data.get("phone")
            if not phone.startswith("09") or len(phone) != 11:
                return jsonify({"error":"فرمت شماره نامعتبر است"})
                
            new_user = User(username=username, phone=data.get("phone"), data=data.get("data", {"lvl":0, "score":0, "unlock_level_h":1, "unlock_level_v":1, "unlock_level_ve":1, "unlock_level_m":1, "unlock_level_s":1, "level":1, "part":1, "ticket":0, "name":"", "icon":"", "unlock_part":0, "sound":True, "music":True, "league_open_time":0,"league_close_time":0 , "league_end_time":0}), password="1234")
            new_user.save()
            access_token = create_access_token(identity=new_user.username, expires_delta=False)
            refresh_token = create_refresh_token(identity=new_user.username)
            return (
                jsonify(
                    {
                        "message": "Logged In ",
                        "tokens": {"access": access_token, "refresh": refresh_token, "id":new_user.id},
                    }), 200)
    else:
        return jsonify({"error":"کد صحیح نمی باشد"}, 400)

@auth_bp.get("/whoami")
@jwt_required()
def whoami():
    if "GodotEngine" in request.headers.get("User-Agent"):
        data = {}
        season = UserInterface.query.first().data.get("season", 1)
        for d in current_user.data.keys():
            if d not in ["ticket","score", f"league_score{season}", "unlock_level_h", "unlock_level_m", "unlock_level_v", "unlock_level_s", "unlock_level_ve"]:
                data[d] = current_user.data.get(d)
            else:
                if d == "score":
                    data["num1"] = current_user.data.get(d)
                if d == f"league_score{season}":
                    data["num2"] = current_user.data.get(d)
                
        return jsonify(
            {
                "message": "message",
                "user_details": {
                    "username": current_user.username,
                    # Add other user details here if needed
                },
                "data": data
            }
        )
    return "شما اجازه دسترسی ندارید", 400
@auth_bp.get("/get")
@jwt_required()
def get_data():
    if "GodotEngine" in request.headers.get("User-Agent"):
        name = request.args.get("name", "")
        name2 = name
        match name:
            case "uh":
                name2 = "unlock_level_h"
            case"um":
                name2 = "unlock_level_m"
            case "uv":
                name2 = "unlock_level_v"
            case "us":
                name2 = "unlock_level_s"
            case "uve":
                name2 = "unlock_level_ve"
            case "oh":
                name2 = "open_hives"
        if name2 != "":
            return jsonify({"num":current_user.data.get(name2, None)})
        else:
            return "نام متغییر وارد نشده", 400
    return "شما اجازه دسترسی ندارید", 400
@auth_bp.post("/update")
@jwt_required()
def save_data():
    if "GodotEngine" in request.headers.get("User-Agent"):
        data = request.get_json()
        change_data = data
        if change_data.get("name", None):
            _name = change_data.get("name", "").split(" ")
            name = ""
            for t in _name:
                if t not in [" ", ""]:
                    name += t
            change_data["name"] = name
        current_user.data = current_user.update(change_data, False)
        db.session.commit()
        
        return jsonify(
            {
            "message": "اطلاعات زیر بروزرسانی شد",
            "data":change_data
            }
        )
    return "شما اجازه دسترسی ندارید", 400
@auth_bp.post("/AnswerLeague")
@jwt_required()
def answer_league():
    if "GodotEngine" in request.headers.get("User-Agent"):
        data = request.get_json()
        _id = data.get("id", 0)
        part = data.get("part", 0)
        not_play_level = False
        season = UserInterface.query.first().data.get("season", 1)
        for level in current_user.data.get(f"league_levels_{part}_{season}", [[], 0])[0]:
            if int(level["id"]) == int(_id):
                if level["state"] == -1:
                    not_play_level = True
                else:
                    not_play_level = False
        if id != None and not_play_level:
            level_content = Levels.query.filter_by(id=_id).first()
            level = json.loads(hashing(HashingMode.DECODE, level_content.data.get("data")))
            if level:
                score = 0
                lvl = current_user.data.get("lvl", 0)
                level_score = level.get("score", 0)
                state = level.get("state")
                user_answers = data.get("data")
                if state <= 1:
                    if state == 0:
                        answers = level.get("answers")
                    else:
                        answers = level.get("data")
                    if state == 1:
                        l = []
                        words_length = 0
                        for answer in answers:
                            l2 = []
                            for t in answer:
                                if t != " ":
                                    words_length += 1
                                l2.append(t)
                            l.append(l2)
                    else:
                        ans = answers
                        list = []
                        for t in ans:
                            list.append(len(t))
                        list.sort()
                        l = []
                        for x in list:
                            for t in ans:
                                if len(t) == x:
                                    l.append(t)
                                    ans.remove(t)
                                    break
                    if user_answers:
                        all_true = True
                        for x, answer in enumerate(user_answers):
                            for y, t in enumerate(answer):
                                if state == 0:
                                    z = len(answer) - y -1
                                else:
                                    z = y
                                if t == l[x][z]:
                                    if t != "":
                                      score += level_score / words_length
                                else:
                                    if l[x][z] != " ":
                                        all_true = False
                        if all_true:
                            score = level_score
                            lvl += 1
                        else:
                            score = int(score)
                if state == 2:
                    if user_answers == level.get("correct_answer"):
                        score = level_score
                        lvl += 1
                if state == 3:
                    correct_answers = []
                    for answer in level.get("options"):
                        if answer[1] == True:
                            correct_answers.append(answer[0])
                    for answer in user_answers:
                        if answer in correct_answers:
                            score += int(level_score / len(correct_answers))
                        else:
                            score -= int(level_score / len(correct_answers))
                    if user_answers == correct_answers:
                        lvl += 1
                if state == 4:
                    answers = level.get("answers")
                    
                    for answer in user_answers:
                        if answer in answers:
                            score += int(level_score / len(answers))
                        else:
                            if answer != "":
                                score -= int(level_score / len(answers))
                    if user_answers == answers:
                        lvl += 1
                if state == 5:
                    score = level_score
                    answers = [level.get("first_n"), level.get("last_n")]
                    first_n = []
                    last_n = []
                    for t in answers[0]:
                        first_n.append(t)
                    for t in answers[1]:
                        last_n.append(t)
                    for x, t in enumerate(user_answers[0]):
                        if t != first_n[x]:
                            score -= int(level_score / 5)
                    for x, t in enumerate(user_answers[1]):
                        if t != last_n[x]:
                            score -= int(level_score / 5)
                    if score < 0:
                        score = 0
                data = current_user.data.get(f"league_levels_{part}_{season}", [[], 0])
                for level in data[0]:
                    if int(level["id"]) == int(_id):
                        level["state"] = 1
                        level["score"] = score
                player_score = score + current_user.data.get(f"league_score{season}", 0)
                current_user.data = current_user.update(data={f"league_score{season}":player_score, f"league_levels_{part}_{season}" : data}, overwrite=False)
                db.session.commit()
                return jsonify({"score": current_user.data.get(f"league_score{season}", 0)})
            return "مرحله وجود ندارد", 400
        return "مرحله انتخاب نشده", 400
    return "شما اجازه دسترسی ندارید", 400
@auth_bp.post("/AnswerNormal")
@jwt_required()
def answer_normal():
    if "GodotEngine" in request.headers.get("User-Agent"):
        request_data = request.get_json()
        id = current_user.data.get("level_data")
        type = "کاوش در منطقه"
        lvl = current_user.data.get("lvl", 0)
        part = ["mosque", "home", "school", "village", "VE"][id[1]]
        p = ["m", "h", "s", "v", "ve"][id[1]]
        level = id[0]
        unlock_level = current_user.data.get("unlock_level_"+p, 1)
        level_content = Levels.query.filter_by(type=type, part=part, level=level).first()
        if level_content != None:
            score = current_user.data.get("score", 0)
            num = 0
            data = json.loads(hashing(HashingMode.DECODE, level_content.data.get("data")))
            level_score = data.get("score", 0)
            state = data.get("state")
            user_answers = request_data.get("data", {})
            if state <= 1:
                if state == 0:
                    answers = data.get("answers")
                else:
                    answers = data.get("data")
                if state == 1:
                    l = []
                    words_length = 0
                    for answer in answers:
                        l2 = []
                        for t in answer:
                            if t != " ":
                                words_length += 1
                            l2.append(t)
                        l.append(l2)
                else:
                    ans = answers
                    list = []
                    for t in ans:
                        list.append(len(t))
                    list.sort()
                    l = []
                    for x in list:
                        for t in ans:
                            if len(t) == x:
                                l.append(t)
                                ans.remove(t)
                                break
                if user_answers:
                    all_true = True
                    for x, answer in enumerate(user_answers):
                        for y, t in enumerate(answer):
                            if state == 0:
                                z = len(answer) - y -1
                            else:
                                z = y
                            if t != "" and t != l[x][z]:
                                all_true = False
                    if all_true and level + 1 > unlock_level:
                        unlock_level = level + 1
                        lvl += 1
                        score += level_score
                        num = level_score
            if state == 5:
                answers = data.get("data", {})
                all_true = True
                for a in answers:
                    for a2 in user_answers:
                        if a[2] == a2[4]:
                            if a[0] != a2[3]:
                                all_true = False
                if all_true and level + 1 > unlock_level:
                    unlock_level = level + 1
                    lvl += 1
                    score += level_score
                    num = level_score
            current_user.data = current_user.update(data={"score":score, "unlock_level_"+p:unlock_level, "lvl":lvl}, overwrite=False)
            db.session.commit()
            return jsonify({"num": num})
        return "مرحله وجود ندارد", 400
    return "شما اجازه دسترسی ندارید", 400

@auth_bp.post("/GetTime")
@jwt_required()
def get_time():
    if "GodotEngine" in request.headers.get("User-Agent"):
        name = request.get_json().get("name", "gift")
        mode = request.get_json().get("mode", 0)
        if mode == 1:
            if current_user.data.get("last_time_"+name, 0) == 0:
                current_user.data = current_user.update(data ={"last_time_"+name : int(time.time())}, overwrite=False)
                db.session.commit()
            last_time =  current_user.data.get("last_time_"+name)
            if int(time.time()) - last_time >= 86400:
                return jsonify({"gift":True})
            else:
                return jsonify({"time":int(time.time()) - last_time})
        else:
            return jsonify({"time":int(time.time())})
    return "شما اجازه دسترسی ندارید", 400
@auth_bp.post("/GetGift")
@jwt_required()
def get_gift():
    if "GodotEngine" in request.headers.get("User-Agent"):
        score = current_user.data.get("score", 0)
        name = request.get_json().get("name", "gift")
        num = UserInterface.query.first().data.get(name+"_num", 0)
        last_time =  current_user.data.get("last_time_"+name, int(time.time()))
        if int(time.time()) - last_time >= 86400:
            current_user.data = current_user.update(data={"score":score+num, "last_time_"+name:int(time.time()), name:False}, overwrite=False)
            db.session.commit()
            return jsonify({"num":num, "num2":score+num})
        else:
            return jsonify({"gift":False})
    return "شما اجازه دسترسی ندارید", 400

@auth_bp.get("/CheckLeague")
@jwt_required()
def check_league():
    if "GodotEngine" in request.headers.get("User-Agent"):
        season = UserInterface.query.first().data.get("season", 1)
        league_score = UserInterface.query.first().data.get(f"league_score{season}", 1500)
        league = current_user.data.get(f"league{season}")
        ticket = current_user.data.get("ticket", 0)
        return jsonify({"league":league, "num":league_score, "num2":ticket, "num3":current_user.data.get(f"league_score{season}", 0)})
    
    return "شما اجازه دسترسی ندارید", 400
@auth_bp.get("/OpenLeague")
@jwt_required()
def open_league():
    
    if "GodotEngine" in request.headers.get("User-Agent"):
        score = current_user.data.get("score")
        ticket = current_user.data.get("ticket", 0)
        season = UserInterface.query.first().data.get("season", 1)
        if score != None:
            league_score = UserInterface.query.first().data.get(f"league_score{season}", 1500)
            if score > league_score and ticket > 0:
                score -= league_score
                ticket -= 1
                current_user.data = current_user.update(data={"ticket":ticket, "score":score, f"league{season}":True, f"league_score{season}":0, "number_play":[0, 0, 0, 0, 0, 0], "played_level":[]}, overwrite=False)
                db.session.commit()
                return jsonify({"league":True})
            else:
                if score < league_score:
                    return jsonify({"message":"امتیاز کافی نیست"})
                else:
                    return jsonify({"message":"بلیط کافی نیست"})
        else:
            return jsonify({"message":"امتیاز کافی نیست"})
    return "شما اجازه دسترسی ندارید", 400
@auth_bp.get("/refresh")
@jwt_required(refresh=True)
def refresh_access():
    if "GodotEngine" in request.headers.get("User-Agent"):
        identity = get_jwt_identity()

        new_access_token = create_access_token(identity=identity)

        return jsonify({"access_token": new_access_token})
    return "شما اجازه دسترسی ندارید", 400
    


@auth_bp.get('/logout')
@jwt_required(verify_type=False) 
def logout_user():
    if "GodotEngine" in request.headers.get("User-Agent"):
        jwt = get_jwt()
        jti = jwt['jti']
        token_type = jwt['type']
        token_b = TokenBlocklist(jti=jti)
        token_b.save()
        return jsonify({"message": f"{token_type} token revoked successfully"}) , 200
    return "شما اجازه دسترسی ندارید", 400
