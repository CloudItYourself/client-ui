import 'package:ciy_client/globals/vm_characteristics.dart';
import 'package:ciy_client/pages/settings/main_page/unified_page.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:windows_single_instance/windows_single_instance.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  await WindowsSingleInstance.ensureSingleInstance(
    args,
    "ciy-ui",
    onSecondWindow: (args) {
    });

  await windowManager.ensureInitialized();

  VMCharacteristics();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(800, 400),
    minimumSize: Size(800, 400),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    if (VMCharacteristics().startInTray ?? true) {
      await windowManager.hide();
    } else {
      await windowManager.show();
      await windowManager.focus();
    }
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
