library feedManager;

import 'dart:html';
import 'dart:async';
import 'dart:convert';

class FeedManager {
  static var apiHost = 'http://afongmbprx8.cnet.cnwk:5000';
  static var feedsUrl = apiHost + '/feeds';
  static var topicsUrl = apiHost = '/topics';
  
  var topic, lastId = null, firstId = null;
  var feeds = [];
  var renderer;
  
  void init() {
    renderer = new FeedRenderer();
    getNext();
  }
  
  Future getFeeds([append = true, limit = 10]) {
    var url = feedsUrl;
    if (lastId != null && firstId != null) {
      if (append) {
        url += '/before' + firstId;
      } else {
        url += '/after' + lastId;
      }
      
      url += '/limit/' + limit;
    }
    
    //return HttpRequest.getString(url).then((response) => processFeeds(JSON.decode(response)['feeds'], append));
    processFeeds(JSON.decode('[{"id": 1, "title": "Test1"},{"id": 2, "title": "Test2"},{"id": 3, "title": "Test3"}]'), append);
  }
  
  void processFeeds(List data, append) { 
    if (data.length > 0) {
      if (append) {
        feeds.addAll(data);
      } else {
        feeds.insertAll(0, data);
      }
      
      feeds.forEach((feed) {
        if (firstId == null || firstId < feed['id']) { 
          firstId = feed['id'];  
        } else if (lastId == null || feed['id'] > lastId) {
          lastId = feed['id'];
        }
      });
      
      renderer.render(data, append ? 0 : feeds.length);
    }
  }
  
  Future refresh() {
    return getFeeds(false);
  }
  
  Future getNext() {
    return getFeeds();
  }
  
  void onFlip(index) {
    if (index >= feeds.length - 1) {
      getNext();
    } else if (index <= 0) {
      refresh();
    }
  }
}

class FeedRenderer {
  void render(feeds, index) {
    var element = querySelector('#testElement');
    feeds.forEach((feed) => element.innerHtml += '<li>' + feed['title'] + '</li>');
  }
}

void main() {
  var feedManager = new FeedManager();
  feedManager.init();
}