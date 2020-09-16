import 'package:flutter/material.dart';

class ReportParameterWidget extends InheritedWidget {
  ReportParameterWidget({
    @required this.parameter,
    @required Widget child,
    Key key,
  })  : assert(parameter != null),
        assert(child != null),
        super(key: key, child: child);

  final Map<String, dynamic> parameter;

  static Map<String, dynamic> of(BuildContext context) {
    Map<String, dynamic> result = {};
    List<Map<String, dynamic>> parameterList = [];

    context.visitAncestorElements((ancestor) {
      var parameterWidget = ancestor.widget;
      if (parameterWidget is ReportParameterWidget) {
        parameterList.add(parameterWidget.parameter);
      }
      return true;
    });

    for (final parameter in parameterList.reversed) {
      result.addAll(parameter);
    }

    return result;
  }

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    return false;
  }
}
