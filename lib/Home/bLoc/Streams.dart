import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'events.dart';

class HomeScreenEventStream{
  HomeScreenEventsStream homeScreenEventsStream = HomeScreenEventsStream.getInstance();
  HomeScreenProjectsClickedStream homeScreenProjectClickedStream = HomeScreenProjectsClickedStream.getInstance();

}
class HomeScreenEventsStream{
  static HomeScreenEventsStream model =HomeScreenEventsStream();
  final StreamController<homeScreenEvents> _Controller = StreamController<homeScreenEvents>.broadcast();

  Stream<homeScreenEvents> get outData => _Controller.stream;

  Sink<homeScreenEvents> get inData => _Controller.sink;

  broadCast(homeScreenEvents v) {
    fetch().then((value) => inData.add(v));
  }
  void dispose() {
    _Controller.close();
  }
  static HomeScreenEventsStream getInstance() {
    if (model == null) {
      model = new HomeScreenEventsStream();
      return model;
    } else {
      return model;
    }
  }
  Future<void> fetch() async {
    return;
  }
}

class HomeScreenProjectsClickedStream{
  static HomeScreenProjectsClickedStream model =HomeScreenProjectsClickedStream();
  final StreamController<QueryDocumentSnapshot> _Controller = StreamController<QueryDocumentSnapshot>.broadcast();

  Stream<QueryDocumentSnapshot> get outData => _Controller.stream;

  Sink<QueryDocumentSnapshot> get inData => _Controller.sink;

  broadCast(QueryDocumentSnapshot v) {
    fetch().then((value) => inData.add(v));
  }
  void dispose() {
    _Controller.close();
  }
  static HomeScreenProjectsClickedStream getInstance() {
    if (model == null) {
      model = new HomeScreenProjectsClickedStream();
      return model;
    } else {
      return model;
    }
  }
  Future<void> fetch() async {
    return;
  }
}