import 'dart:async';

import 'events.dart';


class LoginScreenEventsStream{
  static LoginScreenEventsStream model =LoginScreenEventsStream();
  final StreamController<loginEvents> _Controller = StreamController<loginEvents>.broadcast();

  Stream<loginEvents> get outData => _Controller.stream;

  Sink<loginEvents> get inData => _Controller.sink;

  broadCast(loginEvents v) {
    fetch().then((value) => inData.add(v));
  }
  void dispose() {
    _Controller.close();
  }
  static LoginScreenEventsStream getInstance() {
    if (model == null) {
      model = new LoginScreenEventsStream();
      return model;
    } else {
      return model;
    }
  }
  Future<void> fetch() async {
    return;
  }
}

class EmailFieldStream{
  static EmailFieldStream model =EmailFieldStream();
  final StreamController<String> _Controller = StreamController<String>.broadcast();

  Stream<String> get outData => _Controller.stream;

  Sink<String> get inData => _Controller.sink;

  broadCast(String v) {
    fetch().then((value) => inData.add(v));
  }
  void dispose() {
    _Controller.close();
  }
  static EmailFieldStream getInstance() {
    if (model == null) {
      model = new EmailFieldStream();
      return model;
    } else {
      return model;
    }
  }
  Future<void> fetch() async {
    return;
  }
}
class PasswordFieldStream{
  static PasswordFieldStream model =PasswordFieldStream();
  final StreamController<String> _Controller = StreamController<String>.broadcast();

  Stream<String> get outData => _Controller.stream;

  Sink<String> get inData => _Controller.sink;

  broadCast(String v) {
    fetch().then((value) => inData.add(v));
  }
  void dispose() {
    _Controller.close();
  }
  static PasswordFieldStream getInstance() {
    if (model == null) {
      model = new PasswordFieldStream();
      return model;
    } else {
      return model;
    }
  }
  Future<void> fetch() async {
    return;
  }
}