import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';

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

  Future<String> _filePath() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String filePath = appDocDir.path + '/report.json';
    return filePath;
  }

  void dispose() {
    _updateStreamController.close();
  }

  Future<void> loadFile() async {
    String filePath = await _filePath();
    _log.info('load report file: $filePath');

    File file = File(filePath);
    if (await file.exists()) {
      String fileContent = await file.readAsString();
      nameMap = json.decode(fileContent);
    }
    _updateStreamController.add(true);
  }

  Future<void> saveFile() async {
    String filePath = await _filePath();

    File file = File(filePath);
    var encoder = JsonEncoder.withIndent("    ");
    file.writeAsStringSync(encoder.convert(nameMap));
  }

  Future<void> shareFile() async {
    String filePath = await _filePath();
    Share.shareFiles([filePath]);
  }

  Future<void> addName(String uuid, String name, String comment) async {
    nameMap[uuid] = {
      'name': name,
      'comment': comment,
    };

    _updateStreamController.add(true);
    await saveFile();
  }

  dynamic getName(String uuid) {
    return nameMap[uuid];
  }
}
