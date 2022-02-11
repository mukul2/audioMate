import 'dart:async';

import 'AuthStatus.dart';

class UserAuthStream{
  static UserAuthStream model =UserAuthStream();
  final StreamController<AuthState> _Controller = StreamController<AuthState>.broadcast();

  Stream<AuthState> get outData => _Controller.stream;

  Sink<AuthState> get inData => _Controller.sink;

  broadCast(AuthState v) {
    fetch().then((value) => inData.add(v));
  }
  void dispose() {
    _Controller.close();
  }
  static UserAuthStream getInstance() {
    if (model == null) {
      model = new UserAuthStream();
      return model;
    } else {
      return model;
    }
  }
  Future<void> fetch() async {
    return;
  }
}

class UserLoggedInData{
  static UserLoggedInData model =UserLoggedInData();
  final StreamController<dynamic> _Controller = StreamController<dynamic>.broadcast();

  Stream<dynamic> get outData => _Controller.stream;

  Sink<dynamic> get inData => _Controller.sink;

  broadCast(dynamic v) {
    fetch().then((value) => inData.add(v));
  }
  void dispose() {
    _Controller.close();
  }
  static UserLoggedInData getInstance() {
    if (model == null) {
      model = new UserLoggedInData();
      return model;
    } else {
      return model;
    }
  }
  Future<void> fetch() async {
    return;
  }
}