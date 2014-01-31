import 'dart:html';
import 'dart:js';


int boundsChange = 100;
String query = '';
List<String> myFeeds = const [ 'my feeds','my feeds','my feeds','my feeds','my feeds'];

/**
 * For non-trivial uses of the Chrome apps API, please see the
 * [chrome](http://pub.dartlang.org/packages/chrome).
 * 
 * * http://developer.chrome.com/apps/api_index.html
 */
void main() {
  //querySelector("#sample_text_id")
   // ..text = "Click me! test"
   // ..onClick.listen(resizeWindow);
  for (var i = 0; i < myFeeds.length; i++) {
    querySelector("#myFeeds").appendHtml("<li>"+ myFeeds[i] +"</li>");
  }
}

void resizeWindow(MouseEvent event) {
  JsObject appWindow = 
      context['chrome']['app']['window'].callMethod('current', []);
  JsObject bounds = appWindow.callMethod('getBounds', []);
  
  bounds['width'] += boundsChange;
  bounds['left'] -= boundsChange ~/ 2;
  
  appWindow.callMethod('setBounds', [bounds]);
  
  boundsChange *= -1;
}
