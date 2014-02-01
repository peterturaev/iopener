from flask import Flask
from time import mktime
from datetime import datetime
import feedparser

from api.models import Feed, User, Entry, Topic, UserTopic, FeedTopic, db_session

app = Flask(__name__)

def parseXml(url):

     x = feedparser.parse(str(url))

     length = len(x['entries'])

     try:
     	title = x.feed.title
     except AttributeError:
        title = None

     category = None

     try:     
     	image = x.feed.image.url
     except AttributeError:
 	image = None

     try:
     	link = x.feed.link
     except AttributeError:
  	link = None

     try:
        description = x.feed.description
     except AttributeError:
   	description = None

     f = Feed(title, category, image, link, description)
     db_session.add(f)
     db_session.commit()

     for entry in x.entries:
  	try:
     	    etitle = entry.title
    	except AttributeError:
	    etitle = None

	eimage = None
	try:
	    eimage = entry.image
	except AttributeError:
	    try:
	        if len(entry.enclosures) != 0:
	     	    eimage = entry.enclosures[0].url
            except AttributeError:
		try:
		    if len(entry.media_content) != 0:
			eimage = entry.media_content[0]['url']
		except AttributeError:
	    	    if "<img" in entry.description:
		    	d = feedparser.parse(entry.description)
		    	eimage = d.feed.img['src']

	ebody = None

	try:
	    elink = entry.link
	except AttributeError:
	    elink = None

        try:
	    #edate = DateTime.fromtimestamp(mktime(entry.published))
	    edate = entry.published
	except AttributeError:
	    edate = None

	try:
  	    edescription = entry.description
	except AttributeError:
	    edescription = None

	efid = f.id
	e = Entry(etitle, eimage, ebody, elink, edate, edescription, efid)
	db_session.add(e)

     db_session.commit()
     return f
