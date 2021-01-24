import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import 'clickable_normal_widget.dart' as real;
import 'report_parameter_widget.dart';

Logger _log = Logger('Clickable');

typedef ClickableBuilder = Widget Function(BuildContext context, bool isHighlight, bool isHover);

class ClickableWidget extends StatelessWidget {
  ClickableWidget({
    @required this.builder,
    Key key,
    this.name,
    this.parameter,
    this.touchGroup,
    this.onTap,
    this.onTapDown,
    this.onDoubleTap,
  }) : super(key: key);

  final ClickableBuilder builder;

  final GestureTapCallback onTap;
  final GestureTapDownCallback onTapDown;
  final GestureTapCallback onDoubleTap;

  /// Report name
  final String name;

  /// Report parameter
  final Map<String, dynamic> parameter;

  /// Touch group
  final String touchGroup;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.passthrough,
      overflow: Overflow.visible,
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.red, width: 0.3),
            color: Colors.red.withOpacity(0.1),
          ),
          child: GestureDetector(
            onLongPress: () {
              Map<String, dynamic> parameter = ReportParameterWidget.of(context);
              _log.info('[$name] ${json.encode(parameter)}');
            },
            child: real.ClickableWidget(
              key: key,
              builder: builder,
              name: name,
              parameter: parameter,
              touchGroup: touchGroup,
              onTap: onTap,
              onTapDown: onTapDown,
              onDoubleTap: onDoubleTap,
            ),
          ),
        ),
        Positioned(
          top: -5.0,
          left: 0.0,
          child: Container(
            color: Colors.red,
            padding: EdgeInsets.symmetric(horizontal: 2.0),
            child: Text(
              name ?? '',
              style: TextStyle(
                fontSize: 7.0,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
