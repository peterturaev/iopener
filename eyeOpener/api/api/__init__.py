from flask import Flask

def start_app(cfg=None):
    app = Flask(__name__)
    from api.views import api
    app.register_blueprint(api)
    return app
