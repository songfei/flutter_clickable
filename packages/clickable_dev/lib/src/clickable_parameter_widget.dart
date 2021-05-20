import 'package:flutter/material.dart';

class ClickableParameterWidget extends InheritedWidget {
  ClickableParameterWidget({
    required this.parameter,
    required Widget child,
    Key? key,
  }) : super(key: key, child: child);

  final Map<String, dynamic> parameter;

  static Map<String, dynamic> of(BuildContext context) {
    Map<String, dynamic> result = {};
    List<Map<String, dynamic>> parameterList = [];

    context.visitAncestorElements((ancestor) {
      var parameterWidget = ancestor.widget;
      if (parameterWidget is ClickableParameterWidget) {
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
