import 'dart:async';

import 'events.dart';

class UploadAudioScreenEvents{
  UploadAudioScreenEventsStream stream = UploadAudioScreenEventsStream.getInstance();

}
class UploadAudioScreenEventsStream{
  static UploadAudioScreenEventsStream model =UploadAudioScreenEventsStream();
  final StreamController<uploadAudioScreenEvents> _Controller = StreamController<uploadAudioScreenEvents>.broadcast();

  Stream<uploadAudioScreenEvents> get outData => _Controller.stream;

  Sink<uploadAudioScreenEvents> get inData => _Controller.sink;

  broadCast(uploadAudioScreenEvents v) {
    fetch().then((value) => inData.add(v));
  }
  void dispose() {
    _Controller.close();
  }
  static UploadAudioScreenEventsStream getInstance() {
    if (model == null) {
      model = new UploadAudioScreenEventsStream();
      return model;
    } else {
      return model;
    }
  }
  Future<void> fetch() async {
    return;
  }
}

