import 'package:flutter/widgets.dart';

typedef ClickableBuilder = Widget Function(BuildContext context, ClickableBuilderInfo info);

typedef ClickableOnTapCallback = void Function(ClickableTapInfo detail);
typedef ClickableOnTapDownCallback = void Function(ClickableTapDownInfo detail);

class ClickableTapInfo {
  ClickableTapInfo({
    this.name,
    this.parameter,
  });

  final String? name;
  final Map<String, dynamic>? parameter;
}

class ClickableTapDownInfo {
  ClickableTapDownInfo({
    required this.tapDownDetails,
    this.name,
    this.parameter,
  });

  final TapDownDetails tapDownDetails;
  final String? name;
  final Map<String, dynamic>? parameter;
}

class ClickableBuilderInfo {
  ClickableBuilderInfo({
    required this.isHighlight,
    required this.isHover,
  });

  final bool isHighlight;
  final bool isHover;
}
