from flask import Flask
from flask_jwt_extended import JWTManager
from flask_sqlalchemy import SQLAlchemy
import socket

jwt = JWTManager()
app = Flask(__name__)


app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False
app.config["SECRET_KEY"] = "supersecretkey"
app.config["UPLOAD_FOLDER"] = "static/files"
app.secret_key = 'abscd'

if socket.gethostname() == "mhh83":
    from sshtunnel import SSHTunnelForwarder
    server = SSHTunnelForwarder(("45.159.150.9", 22), ssh_password="haghshenas67", ssh_username="pachim", remote_bind_address=("127.0.0.1", 3306))
    server.start()
    local_host = server.local_bind_port
    app.config["SQLALCHEMY_DATABASE_URI"] = 'mysql://pachim:haghshenas67@127.0.0.1:{}/data'.format(local_host)
else:
    app.config["SQLALCHEMY_DATABASE_URI"] = 'mysql://pachim:haghshenas67@localhost:3306/data'
db = SQLAlchemy(app)





