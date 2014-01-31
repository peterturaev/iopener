import 'package:polymer/polymer.dart';

@CustomTag('my-example')
class MyExample extends PolymerElement {
  final List fruits = toObservable(['apple', 'banana', 'pear']);
  
  MyExample.created() : super.created();
}