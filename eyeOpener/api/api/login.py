import logging
import urllib
import urllib2
import json

from flask import render_template, url_for, request, redirect
from flask.views import MethodView
from flask.ext.login import login_user

from api import settings
from api.models import User


logger = logging.getLogger(__name__)


class Login():
    def get(self):
        logger.debug('GET: %s' % request.args)
        params = {
            'response_type': 'code',
            'client_id': settings.GOOGLE_API_CLIENT_ID,
            'redirect_uri': url_for('auth', _external=True),
            'scope': settings.GOOGLE_API_SCOPE,
            'state': request.args.get('next'),
        }
        logger.debug('Login Params: %s' % params)
        url = settings.GOOGLE_OAUTH2_URL + 'auth?' + urllib.urlencode(params)

        context = {'login_url': url}
        return jsonify({"success":"true"})


class Auth():
    def _get_token(self):
        params = {
            'code': request.args.get('code'),
            'client_id': settings.GOOGLE_API_CLIENT_ID,
            'client_secret': settings.GOOGLE_API_CLIENT_SECRET,
            'redirect_uri': url_for('auth', _external=True),
            'grant_type': 'authorization_code',
        }
        payload = urllib.urlencode(params)
        url = settings.GOOGLE_OAUTH2_URL + 'token'

        req = urllib2.Request(url, payload)  # must be POST

        return json.loads(urllib2.urlopen(req).read())

    def _get_data(self, response):
        params = {
            'access_token': response['access_token'],
        }
        payload = urllib.urlencode(params)
        url = settings.GOOGLE_API_URL + 'userinfo?' + payload

        req = urllib2.Request(url)  # must be GET

        return json.loads(urllib2.urlopen(req).read())

    def get(self):
        logger.debug('GET: %s' % request.args)

        response = self._get_token()
        logger.debug('Google Response: %s' % response)

        data = self._get_data(response)
        logger.debug('Google Data: %s' % data)

        user = User.get_or_create(data)
        login_user(user)
        logger.debug('User Login: %s' % user)
        #return redirect(request.args.get('state') or url_for('index'))
	return jsonify({"success":"true"})
