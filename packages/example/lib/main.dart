import 'package:clickable/clickable.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

Logger _log = Logger('ClickableExample');

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    print('${record.time} [${record.loggerName}|${record.level.name}] ${record.message}');
  });

  ClickableManager().onTouchReport.listen(_log.info);
  // ClickableNameManager();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ClickableParameterWidget(
          parameter: {'p1': 'p1', 'p2': 'p2'},
          child: Scaffold(
            appBar: AppBar(
              title: Text('Clickable Demo'),
            ),
            body: ClickableParameterWidget(
              parameter: {'pp1': 'pp1', 'p2': 'pp2'},
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Builder(
                      builder: (BuildContext context) {
                        // TODO:
                        return ClickableWidget(
                          name: '',
                          uuid: '1db7a68f513b43d290404f18a85e1138',
                          parameter: {'pp1': 'ppp1', 'p2': 'ppp2', 'ppp3': 'ppp3'},
                          onTap: (_) {
                            Scaffold.of(context).showSnackBar(SnackBar(
                              content: Text('tap text'),
                              duration: Duration(seconds: 1),
                            ));
                          },
                          onDoubleTap: (_) {
                            Scaffold.of(context).showSnackBar(SnackBar(
                              content: Text('double tap text'),
                              duration: Duration(seconds: 1),
                            ));
                          },
                          builder: (BuildContext context, ClickableBuilderInfo info) {
                            return Container(
                              color: info.isHover ? Colors.blue : null,
                              child: Text(
                                'You can click \nthis text',
                                style: TextStyle(color: info.isHighlight ? Colors.red : Colors.black),
                                textAlign: TextAlign.center,
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ), // This trailing comma makes auto-formatting nicer for build methods.
          )),
    );
  }
}
