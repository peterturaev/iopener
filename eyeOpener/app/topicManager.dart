import 'dart:html';
import 'dart:async';
import 'dart:convert';

import 'settings.dart';

class TopicManager {
  static var topicsUrl = Settings.apiHost + '/topics';
  
  var auth;
  var topics = [];
  var rendered = false;
  
  TopicManager(this.auth);
  
  Future getTopics() {
    var url = topicsUrl;
    //return HttpRequest.getString(url).then((response) => processTopics(JSON.decode(response)['feeds']));
    render(JSON.decode('[{"title": "Music", "id": 1, "image": "/eyeOpener/app/assets/images/music.jpg"}, {"title": "News", "id": 2, "image": "/eyeOpener/app/assets/images/news.jpg"}, {"title": "Science", "id": 3, "image": "/eyeOpener/app/assets/images/science.jpg"},{"title": "Sports", "id": 4, "image": "/eyeOpener/app/assets/images/sports.jpg"},{"title": "Technology", "id": 5, "image": "/eyeOpener/app/assets/images/technology.jpg"},{"title": "Auto", "id": 6, "image": "/eyeOpener/app/assets/images/auto.jpg"}]'));
  }
  
  void render(List topics) {
    this.topics = topics;
    var list = querySelector('#topic-board');
    var result = '';
    topics.forEach((topic) {
      var html = '<img src="' + topic['image'] + '" /><span>' + topic['title'] +'</span>';
      
      if (rendered && topic["id"] != null) {
        list.querySelector('#topic_' + topic["id"]).innerHtml = html;
      } else {
        result += '<li>' + html + '</li>';
      }
    });
    
    if (result != '') {
      list.innerHtml = result;  
    }
    
    rendered = true;
  }
  
  void refresh() {
    getTopics();
  }
}

void main() {
  var storage = window.localStorage;
  var auth = false;
  if (storage.containsKey('usid')) {
    auth = true;
  } else {
    
  }
  
  var topicManager = new TopicManager(auth);
  topicManager.refresh();
}