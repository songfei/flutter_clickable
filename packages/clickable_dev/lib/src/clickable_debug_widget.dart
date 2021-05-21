import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import 'clickable_info.dart';
import 'clickable_name_manager.dart';
import 'clickable_parameter_widget.dart';
import 'clickable_widget.dart' as real;

Logger _log = Logger('Clickable');

class ClickableWidget extends StatelessWidget {
  ClickableWidget({
    required this.builder,
    Key? key,
    this.name,
    this.uuid,
    this.parameter,
    this.touchGroup,
    this.onTap,
    this.onTapDown,
    this.onDoubleTap,
  }) : super(key: key);

  final ClickableBuilder builder;

  final ClickableOnTapCallback? onTap;
  final ClickableOnTapDownCallback? onTapDown;
  final ClickableOnTapCallback? onDoubleTap;

  /// Report name
  final String? name;

  /// Report uuid
  final String? uuid;

  /// Report parameter
  final Map<String, dynamic>? parameter;

  /// Touch group
  final String? touchGroup;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: ClickableNameManager().clickableNameChangedListener,
      builder: (BuildContext content, _) {
        String realName = name ?? '';
        Color backgroundColor = Colors.green.withOpacity(0.2);
        Color color = Colors.green;

        if (uuid != null) {
          var item = ClickableNameManager().getName(uuid!);
          if (item != null) {
            if (realName != item['name']) {
              realName = '*${item['name']}';
            }
          }
        }

        if (realName.isEmpty) {
          realName = '<empty>';
          color = Colors.red;
          backgroundColor = Colors.red.withOpacity(0.1);
        }

        if (uuid == null) {
          color = Colors.orange;
          backgroundColor = Colors.orange.withOpacity(0.2);
        }

        return Stack(
          clipBehavior: Clip.none,
          fit: StackFit.passthrough,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: color, width: 0.2),
                color: backgroundColor,
              ),
              child: GestureDetector(
                onLongPress: () {
                  Map<String, dynamic> allParameter = ClickableParameterWidget.of(context);
                  if (parameter != null) {
                    allParameter.addAll(parameter!);
                  }

                  Navigator.of(context).push(ReportInfoOverlayRoute(
                    name: name,
                    uuid: uuid,
                    parameter: allParameter,
                  ));

                  _log.info('[$name] ${json.encode(parameter)}');
                },
                child: real.ClickableWidget(
                  key: key,
                  builder: builder,
                  name: realName,
                  uuid: uuid,
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
              child: Transform.scale(
                scale: 0.5,
                alignment: Alignment.topLeft,
                child: Container(
                  color: color,
                  padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 1.0),
                  child: Text(
                    realName,
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class ReportInfoOverlayRoute extends ModalRoute {
  ReportInfoOverlayRoute({
    this.name,
    this.uuid,
    this.parameter,
  });

  final String? name;
  final String? uuid;
  final Map<String, dynamic>? parameter;

  @override
  Color? get barrierColor => Colors.black.withOpacity(0.2);

  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel => 'NameEditor';

  @override
  bool get maintainState => true;

  @override
  bool get opaque => false;

  @override
  Duration get transitionDuration => Duration(milliseconds: 300);

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    return DraggableWidget(
      child: ReportInfoWidget(
        name: name,
        uuid: uuid,
        parameter: parameter,
      ),
    );
  }
}

class DraggableWidget extends StatefulWidget {
  DraggableWidget({
    required this.child,
  });

  final Widget child;
  @override
  State<StatefulWidget> createState() {
    return DraggableWidgetState();
  }
}

class DraggableWidgetState extends State<DraggableWidget> {
  Offset offset = Offset(50.0, 150.0);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: offset.dy,
          left: offset.dx,
          child: Draggable(
            onDragEnd: (DraggableDetails details) {
              setState(() {
                offset = details.offset;
              });
            },
            feedback: widget.child,
            child: widget.child,
            childWhenDragging: Container(),
            ignoringFeedbackSemantics: false,
          ),
        ),
      ],
    );
  }
}

class ReportInfoWidget extends StatelessWidget {
  ReportInfoWidget({
    this.name,
    this.uuid,
    this.parameter,
  });

  final String? name;
  final String? uuid;
  final Map<String, dynamic>? parameter;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: ClickableNameManager().clickableNameChangedListener,
        builder: (BuildContext context, _) {
          var encoder = JsonEncoder.withIndent("    ");
          var textStyle = TextStyle(
            fontSize: 10.0,
            color: Colors.white,
            fontWeight: FontWeight.normal,
            decoration: TextDecoration.none,
          );

          String realName = name ?? '';
          String comment = '';

          if (uuid != null) {
            var item = ClickableNameManager().getName(uuid!);
            if (item != null) {
              realName = '*${item['name']}';
              comment = '${item['comment']}';
            }
          }

          return Stack(
            children: [
              Opacity(
                opacity: 0.6,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    boxShadow: [
                      BoxShadow(
                        offset: Offset(2.0, 4.0),
                        // color: Colors.red,
                        color: Colors.black.withOpacity(0.6),
                        blurRadius: 8.0,
                      ),
                    ],
                  ),
                  width: 260.0,
                  height: 150.0,
                ),
              ),
              Positioned(
                top: 0.0,
                left: 0.0,
                right: 0.0,
                height: 25.0,
                child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 5.0),
                    color: Colors.black.withOpacity(0.5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              '上报详情',
                              style: TextStyle(
                                fontSize: 12.0,
                                color: Colors.green,
                                fontWeight: FontWeight.normal,
                                decoration: TextDecoration.none,
                              ),
                            ),
                            SizedBox(
                              width: 10.0,
                            ),
                            ClickableNameManager().exportFileWidget(),
                          ],
                        ),
                        uuid == null
                            ? Container()
                            : GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      fullscreenDialog: true,
                                      builder: (BuildContext context) {
                                        return NameEditorWidget(
                                          name: name,
                                          uuid: uuid,
                                          parameter: parameter,
                                        );
                                      },
                                    ),
                                  );
                                },
                                child: Text(
                                  '[编辑]',
                                  style: TextStyle(
                                    fontSize: 12.0,
                                    color: Colors.green,
                                    fontWeight: FontWeight.normal,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                              ),
                      ],
                    )),
              ),
              Positioned(
                top: 25.0,
                left: 0.0,
                right: 0.0,
                height: 125.0,
                child: ListView(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.0,
                    vertical: 10.0,
                  ),
                  children: [
                    Text('uuid: ${uuid ?? ''}', style: textStyle),
                    SizedBox(
                      height: 5.0,
                    ),
                    Text(
                      'name: ${realName}',
                      style: textStyle,
                    ),
                    SizedBox(
                      height: 5.0,
                    ),
                    Text(
                      'parameter: ${encoder.convert(parameter ?? {})}',
                      style: textStyle,
                    ),
                    SizedBox(
                      height: 5.0,
                    ),
                    if (comment.isNotEmpty)
                      Text(
                        'comment: $comment',
                        style: textStyle,
                      ),
                  ],
                ),
              )
            ],
          );
        });
  }
}

class NameEditorWidget extends StatefulWidget {
  NameEditorWidget({
    this.name,
    this.uuid,
    this.parameter,
  });

  final String? name;
  final String? uuid;
  final Map<String, dynamic>? parameter;

  @override
  State<StatefulWidget> createState() {
    return NameEditorWidgetState();
  }
}

class NameEditorWidgetState extends State<NameEditorWidget> {
  ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    var encoder = JsonEncoder.withIndent("    ");
    var textStyle = TextStyle(
      fontSize: 14.0,
      color: Colors.black,
      fontWeight: FontWeight.normal,
      decoration: TextDecoration.none,
    );

    String realName = widget.name ?? '';
    String comment = '';

    if (widget.uuid != null) {
      var item = ClickableNameManager().getName(widget.uuid!);
      if (item != null) {
        realName = '*${item['name']}';
        comment = '${item['comment']}';
      }
    }

    var nameController = TextEditingController(text: realName);
    var commentController = TextEditingController(text: comment);

    return Scaffold(
      appBar: AppBar(
        title: Text('编辑上报名称'),
        actions: [
          Center(
            child: GestureDetector(
              onTap: () {
                if (widget.uuid != null) {
                  var name = nameController.text;
                  var comment = commentController.text;
                  if (name.startsWith('*')) {
                    name = name.substring(1);
                  }

                  ClickableNameManager().addName(widget.uuid!, name, comment);
                  Navigator.of(context).pop();
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text('保存'),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        controller: scrollController,
        padding: EdgeInsets.zero,
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text('uuid: ${widget.uuid ?? ''}', style: textStyle),
          ),
          Container(
            height: 0.5,
            color: Colors.black.withOpacity(0.1),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              'parameter: ${encoder.convert(widget.parameter ?? {})}',
              style: textStyle,
            ),
          ),
          Container(
            height: 0.5,
            color: Colors.black.withOpacity(0.1),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Text(
                  'name:  ',
                  style: textStyle,
                ),
                Expanded(
                  child: TextField(
                    controller: nameController,
                    scrollPadding: EdgeInsets.zero,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 0.5,
            color: Colors.black.withOpacity(0.1),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'comment:  ',
                  style: textStyle,
                ),
                Expanded(
                  child: TextField(
                    controller: commentController,
                    scrollPadding: EdgeInsets.zero,
                    maxLines: 5,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 0.5,
            color: Colors.black.withOpacity(0.1),
          ),
        ],
      ),
    );
  }
}
