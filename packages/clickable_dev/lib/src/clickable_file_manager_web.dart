import 'dart:async';
import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:uuid/uuid.dart';

var uuid = Uuid();

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

  String get filePath {
    if (storage.containsKey(nameKey)) {
      // 获取文件内容
      String fileContent = storage[nameKey]!;
      print('222222: $nameKey, $fileContent');
      // 下载
      html.Blob blob = html.Blob([fileContent]);
      return html.Url.createObjectUrlFromBlob(blob);
    }
    return '';
  }

  html.Storage storage = html.window.localStorage;
  String nameKey = 'clickable_name_map';

  Future<Map<String, dynamic>> loadFile() async {
    if (storage.containsKey(nameKey)) {
      String fileContent = storage[nameKey]!;
      return json.decode(fileContent);
    } else {
      // 初始化
      var encoder = JsonEncoder.withIndent("    ");
      storage.addAll({nameKey: encoder.convert({})});
      return {};
    }
  }

  Future<void> saveFile(Map<String, dynamic> nameMap) async {
    var encoder = JsonEncoder.withIndent("    ");
    storage.addAll({nameKey: encoder.convert(nameMap)});
  }

  Widget exportFileWidget() {
    String uid = uuid.v1();
    return FutureBuilder(
      future: _registerHtml(uid),
      builder: (BuildContext context, _) {
        // print('333333: export_file_html_$uid');
        return Container(
          width: 40,
          height: 16,
          child: HtmlElementView(
            // key: widget?.key,
            viewType: 'export_file_html_$uid',
          ),
        );
      },
    );
  }

  Future<void> _registerHtml(String uid) {
    // print('333330: export_file_html_$uid');
    Completer _completer = Completer();
    ui.platformViewRegistry.registerViewFactory('export_file_html_$uid', (int viewId) {
      html.AnchorElement element = html.AnchorElement();
      element.href = filePath;
      element.innerText = '[下载]';
      element.download = 'report.json';

      element.style.color = "#4CAF50";
      element.style.fontSize = '12px';
      element.style.textDecoration = "auto";

      // print('333331: export_file_html_$uid');
      _completer.complete();
      return element;
    });
    return _completer.future;
  }

  // String _now() {
  //   DateTime now = DateTime.now();
  //   return '${now.year}${now.month}${now.day}${now.hour}${now.minute}${now.second}${now.millisecond}';
  // }
}
