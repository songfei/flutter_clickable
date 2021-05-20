library clickable;

export 'src/clickable_debug_widget.dart';
export 'src/clickable_info.dart';
export 'src/clickable_manager.dart';
export 'src/clickable_name_manager.dart';
export 'src/clickable_parameter_widget.dart';

class Clickable {
  const Clickable({
    this.message = '',
  });

  final String message;
}
