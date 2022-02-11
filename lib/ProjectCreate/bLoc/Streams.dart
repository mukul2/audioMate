import 'dart:async';

import 'events.dart';

class HomeScreenEventStream{
  HomeScreenEventsStream homeScreenEventsStream = HomeScreenEventsStream.getInstance();

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

