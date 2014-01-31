import 'dart:html';
import 'dart:js';
import 'dart:math';

int boundsChange = 100;
String query = '';
List<String> myFeeds = const [ 'my feeds','my feeds','my feeds','my feeds','my feeds'];

/**
 * For non-trivial uses of the Chrome apps API, please see the
 * [chrome](http://pub.dartlang.org/packages/chrome).
 * 
 * * http://developer.chrome.com/apps/api_index.html
 */

class swipe{
  num startX, endX, startY, endY;
  String direction;
  bool _isHorizontal;
  
  Element _elm;
  swipe(Element elm, [bool isHorizontal=true]){
    this._elm = elm;
    this._isHorizontal = isHorizontal;
    this._initTouchSwipe();
  }
  _initTouchSwipe(){
    _elm.onTouchStart.listen(this._startT);
    _elm.onTouchCancel.listen(this._endT);
    _elm.onMouseDown.listen(this._startD);
    _elm.onMouseUp.listen(this._endD);
  }
  void _startD(MouseEvent event){
    event.preventDefault();
    this.startX = event.page.x;
    this.startY = event.page.y;
    
  }
  void _endD(MouseEvent event){
    event.preventDefault();
    this.endX = event.page.x;
    this.endY = event.page.y;
    if(this.startX > this.endX){
      this.direction = 'lf';
    }else{
      this.direction = 'rt';
    }
    
    if(!this._isHorizontal){
      if(this.startY > this.endY){
        this.direction = 'down';
      }else{
        this.direction = 'up';
      }
    }
    print(direction);
  }
  
  void _startT(TouchEvent event) {
    event.preventDefault();
    event.touches.forEach((touch) {
      this.startX = touch.page.x;
      this.startY = touch.page.y;
    });
  }
  
  void _endT(TouchEvent event) {
    event.preventDefault();
    event.touches.forEach((touch) {
      this.endX = touch.page.x;
      this.endY = touch.page.y;
      if(this.startX > this.endX){
        this.direction = 'lf';
      }else{
        this.direction = 'rt';
      }
      if(!this._isHorizontal){
        if(this.startY > this.endY){
          this.direction = 'down';
        }else{
          this.direction = 'up';
        }
      }
      
      print(direction);
    });
  }
}

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
  num _current = 0, _flipSpeed = 900, _currentPage, _state, _flipPagesCount;
  String _flipTimingFunction = 'linear', _flipSide, _flipDirection;
  List<Element> _pages, _flipPages; 
  num _pagesCount;
  History _history;
  windowProp _winProp;
  

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
    swipe Swipe = new swipe(querySelector(".page"));
    if (!_self._isAnimating()) {

     // (Swipe.startX < _self._winProp.width / 2) ? _self.flipSide = 'l2r' : _self.flipSide = 'r2l';
      if(Swipe.direction == 'rt'){
        _self._flipSide = 'l2r';
        _self._turnPage(0);
        _self._updatePage();
      }else{
        _self._flipSide = 'r2l';
        _self._turnPage(180);
        _self._updatePage();
      }

    }
    if (Swipe.direction == 'u' || direction == 'd') {
        _self._removeOverlays();
        return false;
    }
    _self._flipDirection = Swipe.direction;

    // on the first & last page neighbors we don't flip
    if (_self._currentPage == 0 && _self._flipSide == 'l2r' || _self._currentPage == _self._flipPagesCount && _self._flipSide == 'r2l') {
      return false;
    } 
  }
  
  
  

  
  
   
}

void main() {
  //querySelector("#sample_text_id")
   // ..text = "Click me! test"
   // ..onClick.listen(resizeWindow);
  swipe Swipe = new swipe(querySelector("body"));

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
