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


class windowProp {
 num width;
 num height;
}

class pageData{
  var theClass;
  var theContentFront;
  var theContentBack;
  var theStyle;
  var theContentStyleFront;
  var theContentStyleBack;
}

class Flip {
  Element _el;
  num _current = 0;
  num _currentPage;
  String _flipTimingFunction = 'linear';
  num _flipSpeed = 900;
  List<Element> _pages; 
  num _pagesCount;
  History _history;
  windowProp _winProp;
  num _state;
  num _flipPagesCount;
  List<Element> _flipPages;
  

  Flip(Element element, [num current=0, num flipSpeed=900, String flipTimingFunction='linear']) {
    this._el = element;
    if(current != null){
      this._current = current;
    }
    if(flipTimingFunction != null){
      this._flipTimingFunction = flipTimingFunction;
    }
    if(flipSpeed != null){
      this._flipSpeed = flipSpeed;
    }
    this._init();
  }
  
  void _init(){
    this._pages = element.children('div.f-page');
    this._pagesCount = this._pages.length;
    this._history = window.History;
    this._currentPage = this._current;
    this._validateOpts();
    this._getWinSize();
    this._getState();
    this._layout();
    this._initTouchSwipe();
    this._loadEvents();
    this._goto();
  }
  
  void _validateOpts(){
    if (this._currentPage < 0 || this._currentPage > this._pagesCount) {
      this._currentPage = 0;
    }
  }
  
  void _getWinSize(){
    _winProp.width = window.screen.available.width;
    _winProp.height =  window.screen.available.height;
  }
  
  void _goto(){
    num page;
    if(this._state == null){
      page = this._currentPage; 
    }else{
      page = this._state;
    }
    if (!this._isNumber(page) || page < 0 || page > this._flipPagesCount) {
      page = 0;
    }

    this._currentPage = page;
  }
  
  bool _isNumber(num n){
   return double.parse(n) == int.parse(n) && !n.isNaN && n.isFinite;
  }
  
  void _adjustLayout(num page){
    var _self = this;
    
    for (var i = 0; i < this._flipPages.length; i++) {
     // querySelector("#myFeeds").appendHtml("<li>"+ myFeeds[i] +"</li>");
      
      Element $page = this_flipPages[i];

      if (i == page - 1) {
        /// ??
        $page.style.transform = 'rotateY( -180deg )';
        $page.style.zIndex =  _self._flipPagesCount - 1 + i;
      } else if (i < page) {
        $page.style.transform = 'rotateY( -181deg )';
        $page.style.zIndex =  _self._flipPagesCount - 1 + i;
      } else {
        $page.style.transform = 'rotateY( 0deg )';
        $page.style.zIndex =  _self._flipPagesCount - 1 - i;
      }
      
    }
  }
  
  void _saveState(){
    var page = this._currentPage;
    //if (this._history.getState().url.queryStringToJSON().page != page) {
    if (this._history.state != page) {
      this._history.pushState(null, null, '?page=' + page);
    }
  }
  
  void _layout(){
    this._setLayoutSize();

    for (var i = 0; i <= this._pagesCount - 2; ++i) {
      Element $page = this._pages[i];
      pageData _pd;
      _pd.theClass = 'page';
      _pd.theContentFront =  $page.innerHtml;
      if(i != this._pagesCount){
        _pd.theContentBack = this._pages[i + 1].innerHtml;
      }else{
        _pd.theContentBack = '';
      }
      _pd.theStyle = 'z-index: ' + (this._pagesCount - i).toString()  + ';left: ' + (this._winProp.width / 2).toString()  + 'px;';
      _pd.theContentStyleFront = 'width:' + this._winProp.width.toString()  + 'px;';
      _pd.theContentStyleBack = 'width:' + this._winProp.width.toString()  + 'px';
      if (i == 0) {
        _pd.theClass += ' cover';
      } else {
        _pd.theContentStyleFront += 'left:-' + (this.windowProp.width / 2).toString() + 'px';
        if (i == this._pagesCount - 2) {
          _pd.theClass += ' cover-back';
        }
      }
      
      String html = "<div class="+ _pd.theClass +" style="+ _pd.theStyle +"><div class='front'><div class='outer'>";
      html += "<div class='content' style="+ _pd.theContentStyleFront + "><div class='inner'>"+_pd.theContentFront+"</div></div></div>";
      html += "</div><div class='back'><div class='outer'><div class='content' style="+_pd.theContentStyleBack+"><div class='inner'>"+ _pd.theContentBack + "</div></div></div></div></div>";
      //querySelector('#pageTmpl').tmpl(pageData).appendTo(this.$el);
      this._el.appendHtml(html);
    }

    this._pages.remove();
    this._flipPages = this._el.children('div.page');
    this._flipPagesCount = this._flipPages.length;
    num st;
    if(this._state == num){
      st = this._currentPage;
    }else{
      st = this._state;
    }
    this._adjustLayout(st);
  }
  
  void _setLayoutSize() {
    this._el.style.width = this._winProp.width;
    this._el.style.height = this._winProp.height;
  }
  
  void _initTouchSwipe(){
    var _self = this;
    
  }
  
  
  
  
  
  
}

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
