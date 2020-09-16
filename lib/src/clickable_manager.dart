import 'dart:async';
import 'dart:convert';

class ClickableReportData {
  ClickableReportData({
    this.time,
    this.page,
    this.gestureType,
    this.name,
    this.parameter,
  });

  final DateTime time;
  final String page;
  final String gestureType;
  final String name;
  final Map<String, dynamic> parameter;

  @override
  String toString() {
    return '$gestureType [$page] $name ${json.encode(parameter)}';
  }
}

class ClickableManager {
  factory ClickableManager() {
    return _instance;
  }

  ClickableManager._internal();

  static final ClickableManager _instance = ClickableManager._internal();

  StreamController<ClickableReportData> _reportStreamController = StreamController<ClickableReportData>.broadcast();

  bool canTouch = true;
  String currentPage = '';

  Stream<ClickableReportData> get onTouchReport => _reportStreamController.stream;

  void sendTouchReport({String gestureType, String name, Map<String, dynamic> parameter}) {
    _reportStreamController.add(ClickableReportData(
      time: DateTime.now(),
      page: currentPage,
      gestureType: gestureType,
      name: name,
      parameter: parameter,
    ));
  }

  void dispose() {
    _reportStreamController.close();
  }
}
