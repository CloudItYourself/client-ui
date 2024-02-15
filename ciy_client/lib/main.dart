import 'package:ciy_client/globals/vm_characteristics.dart';
import 'package:ciy_client/pages/settings/main_page/unified_page.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();


  VMCharacteristics();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(800, 400),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(CloudIY());
}

class CloudIY extends StatelessWidget {
  const CloudIY({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CloudIY Client',
      debugShowCheckedModeBanner: false,
      theme: FlexThemeData.dark(scheme: FlexScheme.blueM3),
      home: UnifiedPage(),
    );
  }
}