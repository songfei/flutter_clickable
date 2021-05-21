import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';

final _log = Logger('ClickableNameManager');

class ClickableFileManager {
  /// Return singleton object
  factory ClickableFileManager() {
    return _instance;
  }

  ClickableFileManager._internal() {
    loadFile();
  }

  static final ClickableFileManager _instance = ClickableFileManager._internal();

  Future<String> _filePath() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String filePath = appDocDir.path + '/report.json';
    return filePath;
  }

  Future<Map<String, dynamic>> loadFile() async {
    String filePath = await _filePath();
    _log.info('load report file: $filePath');

    File file = File(filePath);
    if (await file.exists()) {
      String fileContent = await file.readAsString();
      return json.decode(fileContent);
    }
    return {};
  }

  Future<void> saveFile(Map<String, dynamic> nameMap) async {
    String filePath = await _filePath();

    File file = File(filePath);
    var encoder = JsonEncoder.withIndent("    ");
    file.writeAsStringSync(encoder.convert(nameMap));
  }

  Future<void> shareFile() async {
    String filePath = await _filePath();
    Share.shareFiles([filePath]);
  }

  Widget exportFileWidget() {
    return GestureDetector(
      onTap: () {
        shareFile();
      },
      child: Text(
        '[导出]',
        style: TextStyle(
          fontSize: 12.0,
          color: Colors.green,
          fontWeight: FontWeight.normal,
          decoration: TextDecoration.none,
        ),
      ),
    );
  }
}
