from flask import current_app, Blueprint, jsonify, Flask, request
from flask.ext.login import current_user
from functools import wraps
from api.models import Entry, Feed, User, Topic, UserTopic, FeedTopic, db_session
from api.parser import parseXml
from api.login import Login, Auth

import feedparser

api = Blueprint('api', __name__)
app = Flask(__name__)

@api.route("/")
def index():
     # We can use "current_app" to have access to our "app" object
     testFeed = Feed("testing")
     db_session.add(testFeed)

     db_session.commit()

     testEntry = Entry("test title", "image", "body", "link", None, "description", testFeed.id)
     db_session.add(testEntry)

     db_session.commit()

     #testFeedEntry = FeedEntry(testFeed.id, testEntry.id)
     #db_session.add(testFeedEntry)

     testTopic = Topic("test topic", "image")
     db_session.add(testTopic)

     testUser = User(name="test User", email="testEmail@email.com")
     db_session.add(testUser)
     db_session.commit()

     feeds = Feed.query.all()
     users = User.query.all()
     topics = Topic.query.all()
     return jsonify( feeds = [i.serialize for i in feeds], 
	users =  [i.serialize for i in users],
	topics = [i.serialize for i in topics] ), 200, {'Access-Control-Allow-Origin':'*'}

@api.route("/db")
def db():
     feeds = Feed.query.all()
     users = User.query.all()
     topics = Topic.query.all()
     ut = UserTopic.query.all()
     entries = Entry.query.all()
     feedTopics = FeedTopic.query.all()

     return jsonify( feeds = [i.serialize for i in feeds], 
        users =  [i.serialize for i in users], 
        topics = [i.serialize for i in topics],
	userTopics = [i.serialize for i in ut],
        entries = [i.serialize for i in entries],
	feedTopics = [i.serialize for i in feedTopics] ), 200, {'Access-Control-Allow-Origin':'*'}

@api.route("/feeds", methods = ['GET'])
def getFeeds():
     feeds = Feed.query.all()
     x = []
     for f in feeds:
	sf = f.serialize
	sf['entries'] = [i.serialize for i in Entry.query.filter_by(feed_id=f.id)]
        x.append(sf)
     entries = Entry.query.all()
     return jsonify( feeds = [x] ), 200, {'Access-Control-Allow-Origin':'*'}

@api.route("/feed/save", methods = ['POST'])
def saveFeed():
     url = request.args.get('url')
     topic = request.args.get('topic')
     feed = parseXml(url)

     #x = feedparser.parse(url)

     entries = Entry.query.filter_by(feed_id=feed.id)

     if feed.image is None:
	feed.image = entries[0].image
	db_session.add(feed)
	db_session.commit()

     return jsonify( feed = [feed.serialize], entries = [i.serialize for i in entries]  ), 200, {'Access-Control-Allow-Origin':'*'}
     #return feed

@api.route("/topic/save", methods = ['POST'])
def saveTopic():
     name = request.args.get('name')
     image = request.args.get('image')
     t = Topic(name, image)
     db_session.add(t)
     db_session.commit()
     return jsonify({"success" : "true"}), 200, {'Access-Control-Allow-Origin':'*'}

@api.route("/topic/update/<topicId>", methods = ['POST'])
def updateTopic(topicId):
     name = request.args.get('name')
     image = request.args.get('image')
     t = Topic.query.filter_by(id=topicId).one()
     t.name = name
     t.image = image
     db_session.merge(t)
     db_session.commit()
     return jsonify(topic = [t.serialize]), 200, {'Access-Controll-Allow-Origin':'*'}

@api.route("/topics/all", methods = ['GET'])
def showAllTopics():
     topics = Topic.query.all()
     return jsonify(topics = [i.serialize for i in topics]), 200, {'Access-Control-Allow-Origin':'*'}

@api.route("/feed/topic/<topicId>", methods = ['GET'])
def showFeedsByTopic(topicId):
     feedTopics = FeedTopic.query.filter_by(topic_id=topicId)
     x = []

     for ft in feedTopics:
	f = Feed.query.filter_by(id=ft.feed_id).first()
        x.append(f)

     x = serializeFeeds(x)

     return jsonify(feeds = [x]), 200, {'Access-Control-Allow-Origin':'*'}

@api.route("/feed/delete", methods = ['POST'])
def deleteFeeds():
     feed = Feed.query.filter_by(id=4).one()
     db_session.delete(feed)
     db_session.commit()
     return jsonify({"success" : "true"}), 200, {'Access-Control-Allow-Origin':'*'}

@api.route("/feedTopic/delete", methods = ['POST'])
def deleteFeedTopics():
     feedTopic = FeedTopic.query.filter_by(feed_id=3).one()
     db_session.delete(feedTopic)
     db_session.commit()
     return jsonify({"success" : "true"}), 200, {'Access-Control-Allow-Origin':'*'}


def serializeFeeds(feeds):
     x = []
     for f in feeds:
         sf = f.serialize
         sf['entries'] = [i.serialize for i in Entry.query.filter_by(feed_id=f.id)]
         x.append(sf)
     return x

@api.route("/user/<userId>/topic/<topicId>", methods = ['POST'])
def saveUserTopic(userId=None, topicId=None):
     user = User.query.filter_by(id=userId).first()
     topic = Topic.query.filter_by(id=userId).first()

     userTopic = UserTopic(userId, topicId);
     db_session.add(userTopic)
     db_session.commit()

     return jsonify({"success" : "true"}), 200, {'Access-Control-Allow-Origin':'*'}

@api.route("/feed/<feedId>/topic/<topicId>", methods = ['POST'])
def saveFeedTopic(feedId=None, topicId=None):
     feedTopic = FeedTopic(feedId, topicId);
     topic = Topic.query.filter_by(id=topicId).first()
     feed = Feed.query.filter_by(id=feedId).first()
     topic.image = feed.image
     db_session.add(topic)
     db_session.commit()
     db_session.add(feedTopic)
     db_session.commit()

     return jsonify({"success" : "true"}), 200, {'Access-Control-Allow-Origin':'*'}

@api.route("/feed/<feedId>/entries", methods = ['GET'])
def getEntriesByFeed(feedId):
     entries = Entry.query.filter_by(feed_id=feedId)
     return jsonify(entries = [i.serialize for i in entries]), 200, {'Access-Control-Allow-Origin':'*'}

@api.route("/login", methods=['GET', 'POST'])
def login(self):
      Login(self)
      if not current_user.is_authenticated():
            return app.login_manager.unauthorized()

      return jsonify(Login.get(self)), 200, {'Access-Control-Allow-Origin':'*'}

@api.route("/auth", methods=['GET', 'POST'])
def auth(self):
      return jsonify(Auth.get(self)), 200, {'Access-Control-Allow-Origin':'*'}

@app.teardown_appcontext
def shutdown_session(exception=None):
    db_session.remove()
