import 'dart:async';

import 'events.dart';

class ProjectScreenEventStream{
  MaxDurationFounndStream maxDurationFounndStream = MaxDurationFounndStream.getInstance();
  ProjectScreenStream projectScreenStream = ProjectScreenStream.getInstance();
  TrackReloadStream trackReloadStream = TrackReloadStream.getInstance();

}
class ProjectScreenStream{
  static ProjectScreenStream model =ProjectScreenStream();
  final StreamController<projectScreenEvents> _Controller = StreamController<projectScreenEvents>.broadcast();

  Stream<projectScreenEvents> get outData => _Controller.stream;

  Sink<projectScreenEvents> get inData => _Controller.sink;

  dataReload(projectScreenEvents v) {
    fetch().then((value) => inData.add(v));
  }

  void dispose() {
    _Controller.close();
  }

  static ProjectScreenStream getInstance() {
    if (model == null) {
      model = new ProjectScreenStream();
      return model;
    } else {
      return model;
    }
  }

  Future<void> fetch() async {
    return;
  }
}

class MaxDurationFounndStream{
  static MaxDurationFounndStream model =MaxDurationFounndStream();
  final StreamController<bool> _Controller = StreamController<bool>.broadcast();

  Stream<bool> get outData => _Controller.stream;

  Sink<bool> get inData => _Controller.sink;

  dataReload(bool v) {
    fetch().then((value) => inData.add(v));
  }

  void dispose() {
    _Controller.close();
  }

  static MaxDurationFounndStream getInstance() {
    if (model == null) {
      model = new MaxDurationFounndStream();
      return model;
    } else {
      return model;
    }
  }

  Future<void> fetch() async {
    return;
  }
}

class TrackReloadStream{
  static TrackReloadStream model =TrackReloadStream();
  final StreamController<bool> _Controller = StreamController<bool>.broadcast();

  Stream<bool> get outData => _Controller.stream;

  Sink<bool> get inData => _Controller.sink;

  dataReload(bool v) {
    fetch().then((value) => inData.add(v));
  }

  void dispose() {
    _Controller.close();
  }

  static TrackReloadStream getInstance() {
    if (model == null) {
      model = new TrackReloadStream();
      return model;
    } else {
      return model;
    }
  }

  Future<void> fetch() async {
    return;
  }
}