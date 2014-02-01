from flask import Flask
from flask.ext.sqlalchemy import SQLAlchemy
from sqlalchemy import create_engine, Table, Column, String, Integer, ForeignKey, DateTime
from sqlalchemy.orm import relationship, scoped_session, sessionmaker
from sqlalchemy.ext.declarative import declarative_base

engine = create_engine('sqlite:////tmp/api.db', convert_unicode=True)
db_session = scoped_session(sessionmaker(autocommit=False,
					 autoflush=False,
					 bind=engine))
Base = declarative_base()
Base.query = db_session.query_property()

def init_db():
    Base.metadata.create_all(bind=engine)


#user_topic_table = Table('user_topic', Base.metadata,
#    Column('user_id', Integer, ForeignKey('user.id')),
#    Column('topic_id', Integer, ForeignKey('topic.id'))
#)

class UserTopic(Base):
    __tablename__ = 'user_topic'
    user_id = Column(Integer, ForeignKey('user.id'), primary_key=True)
    topic_id = Column(Integer, ForeignKey('topic.id'), primary_key=True)
    topic = relationship("Topic")

    def __init__(self, user_id=None, topic_id=None):
 	self.user_id = user_id
	self.topic_id = topic_id

    @property
    def serialize(self):
	return {
	    'user_id'	: self.user_id,
	    'topic_id'  : self.topic_id
        }

class FeedTopic(Base):
    __tablename__ = 'feed_topic'
    feed_id = Column(Integer, ForeignKey('feed.id'), primary_key=True)
    topic_id = Column(Integer, ForeignKey('topic.id'), primary_key=True)
    topic = relationship("Topic")

    def __init__(self, feed_id=None, topic_id=None):
        self.feed_id = feed_id
        self.topic_id = topic_id

    @property
    def serialize(self):
        return {
            'feed_id'   : self.feed_id,
            'topic_id'  : self.topic_id
        }  

#class FeedEntry(Base):
#    __tablename__ = 'feed_entry'
#    feed_id = Column(Integer, ForeignKey('feed.id'), primary_key=True)
#    entry_id = Column(Integer, ForeignKey('entry.id'), primary_key=True)
#    entry = relationship("Entry")
#
#    def __init__(self, feed_id=None, entry_id=None):
#        self.feed_id = feed_id
#        self.entry_id = entry_id
#
#    @property
#    def serialize(self):
#        return {
#            'feed_id'   : self.feed_id,
#            'entry_id'  : self.entry_id
#        }  

class User(Base):
    __tablename__ = 'user'
    id = Column(Integer, primary_key=True)
    name = Column(String(50))
    email = Column(String(120))
    token = Column(String(255))
    #topics = relationship("Topic", secondary = user_topic_table)
    topics = relationship("UserTopic")

    def __init__(self, name=None, email=None, token=None):
        self.name = name
        self.email = email
   	self.token = token

    def __repr__(self):
        return '<User %r>' % (self.name)

    @property
    def serialize(self):
        return {
            'id'        : self.id,
            'name'      : self.name,
	    'email'	: self.email,
	    'token'	: self.token,
	    'topics'	: [i.serialize for i in self.topics]
        }

    @classmethod
    def get_or_create(cls, data):
        """
        data contains:
            {u'family_name': u'Surname',
            u'name': u'Name Surname',
            u'picture': u'https://link.to.photo',
            u'locale': u'en',
            u'gender': u'male',
            u'email': u'propper@email.com',
            u'birthday': u'0000-08-17',
            u'link': u'https://plus.google.com/id',
            u'given_name': u'Name',
            u'id': u'Google ID',
            u'verified_email': True}
        """
        try:
            #.one() ensures that there would be just one user with that email.
            # Although database should prevent that from happening -
            # lets make it buletproof
            user = Session.query(cls).filter_by(email=data['email']).one()
        except NoResultFound:
            user = cls(
                    email=data['email'],
                    username=data['given_name'],
                )
            Session.add(user)
            Session.commit()
        return user

    def is_active(self):
        return True

    def is_authenticated(self):
        """
        Returns `True`. User is always authenticated. Herp Derp.
        """
        return True

    def is_anonymous(self):
        """
        Returns `False`. There are no Anonymous here.
        """
        return False

    def get_id(self):
        """
        Assuming that the user object has an `id` attribute, this will take
        that and convert it to `unicode`.
        """
        try:
            return unicode(self.id)
        except AttributeError:
            raise NotImplementedError("No `id` attribute - override get_id")

    def __eq__(self, other):
        """
        Checks the equality of two `UserMixin` objects using `get_id`.
        """
        if isinstance(other, UserMixin):
            return self.get_id() == other.get_id()
        return NotImplemented

    def __ne__(self, other):
        """
        Checks the inequality of two `UserMixin` objects using `get_id`.
        """
        equal = self.__eq__(other)
        if equal is NotImplemented:
            return NotImplemented
        return not equal

class Topic(Base):
    __tablename__ = 'topic'
    id = Column(Integer, primary_key=True)
    name = Column(String(80))
    image = Column(String(255))

    def __init__(self, name=None, image=None):
        self.name = name
        self.image = image

    def __repr__(self):
        return '<Topic %r>' % (self.name)

    @property
    def serialize(self):
        return {
            'id'        : self.id,
            'image'     : self.image,
            'name'      : self.name
        }   

class Feed(Base):
    __tablename__ = 'feed'
    id = Column(Integer, primary_key=True)
    title = Column(String(255))
    category = Column(String(80))
    image = Column(String(255))
    link = Column(String(255))
    description = Column(String(255))
    topics = relationship("FeedTopic")
    #entries = relationship("FeedEntry")

    def __init__(self, title=None, category=None, image=None, link=None, description=None):
	self.title = title
	self.category = category
	self.image = image
	self.link = link
	self.description = description

    def __repr__(self):
	return '<Feed %r>' % (self.title)

    @property
    def serialize(self):
	return {
	    'id' 	: self.id,
	    'title'	: self.title,
	    'category'	: self.category,
	    'image'	: self.image,
	    'link'	: self.link,
	    'description' : self.description,
	    'topics'	: [i.serialize for i in self.topics],
            #'entries'   : [i.serialize for i in self.entries]
 	}

class Entry(Base):
    __tablename__ = 'entry'
    id = Column(Integer, primary_key=True)
    title = Column(String(255))
    image = Column(String(255))
    body = Column(String(255))
    link = Column(String(255))
    date = Column(String(100))
    description = Column(String(255))
    feed_id = Column(Integer)

    def __init__(self, title=None, image=None, body=None, link=None, date=None, description=None, feed_id=None):
        self.title = title
        self.image = image
        self.body = body
        self.link = link
        self.date = date
        self.description = description
        self.feed_id = feed_id

    def __repr__(self):
        return '<Entry %r>' % (self.title)

    @property
    def serialize(self):
        return {
            'id'        : self.id,
            'title'     : self.title,
            'image'     : self.image,
            'body'      : self.body,
            'link'      : self.link,
            'date'      : self.date,
            'description' : self.description,
	    'feed_id'   : self.feed_id
        }

Base.metadata.create_all(engine)
