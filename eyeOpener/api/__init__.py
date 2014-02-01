from flask import Flask
import iOpener
app = Flask(__name__)
app.register_blueprint(api.views, url_prefix='/api')
