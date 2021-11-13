import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simple_logger/simple_logger.dart';

final logger = SimpleLogger();

void main() {
  logger.setLevel(Level.FINE, includeCallerInfo: true);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.from(
        colorScheme: const ColorScheme.light(),
      ),
      home: const HomePage(),
    );
  }
}

const _platform = MethodChannel(
  'com.tsuruoka.flutter_platform_channels_practice/battery',
);

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const unknownLabel = '---';
  var label = unknownLabel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Platform Channels Demo'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            OutlinedButton(
              onPressed: () async {
                final batteryLevel = await getBatteryLevel();
                setState(() {
                  label = batteryLevel == null
                      ? unknownLabel
                      : batteryLevel.toString();
                });
              },
              child: const Text('getBatteryLevel'),
            ),
            const SizedBox(
              height: 16,
            ),
            Text('BatteryLevel is $label%'),
          ],
        ),
      ),
    );
  }

  Future<int?> getBatteryLevel() async {
    try {
      final result = await _platform.invokeMethod<int>('getBatteryLevel');
      return result;
    } on MissingPluginException catch (e) {
      // invokeMethodsの受け口がネイティブコード側で用意されていない場合に到達する
      logger.warning(e);
      return null;
    } on PlatformException catch (e) {
      // ネイティブ側でresultに`FlutterError`を渡すとここに到達する
      logger.warning(e);
      return null;
    }
  }
}
