import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:logging/logging.dart';

import 'clickable_file_manager.dart'
    if (dart.library.io) 'clickable_file_manager.dart' // dart:io implementation
    if (dart.library.html) 'clickable_file_manager_web.dart'; // dart:html implementation

final _log = Logger('ClickableNameManager');

class ClickableNameManager {
  /// Return singleton object
  factory ClickableNameManager() {
    return _instance;
  }

  ClickableNameManager._internal() {
    loadFile();
  }

  static final ClickableNameManager _instance = ClickableNameManager._internal();

  Map<String, dynamic> nameMap = {};

  StreamController<bool> _updateStreamController = StreamController<bool>.broadcast();

  Stream<bool> get clickableNameChangedListener => _updateStreamController.stream;

  String get filePath {
    return '';
  }

  void dispose() {
    _updateStreamController.close();
  }

  Future<void> loadFile() async {
    nameMap = await ClickableFileManager().loadFile();
    _updateStreamController.add(true);
  }

  Future<void> saveFile() async {
    await ClickableFileManager().saveFile(nameMap);
  }

  Future<void> addName(String uuid, String name, String comment) async {
    nameMap[uuid] = {
      'name': name,
      'comment': comment,
    };

    _updateStreamController.add(true);
    await ClickableFileManager().saveFile(nameMap);
  }

  dynamic getName(String uuid) {
    return nameMap[uuid];
  }

  Widget exportFileWidget() {
    return ClickableFileManager().exportFileWidget();
  }
}
