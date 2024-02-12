import 'dart:isolate';
import 'package:ciy_client/globals/vm_characteristics.dart';
import 'package:ciy_client/pages/settings/settings.dart';
import 'package:ciy_client/utilities/installer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();


  VMCharacteristics();
  
  WindowOptions windowOptions = const WindowOptions(
    size: Size(600, 400),
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
      theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue, brightness: Brightness.dark)),
      home: CloudIYHome(),
    );
  }
}

class CloudIYHome extends StatefulWidget {
  @override
  State<CloudIYHome> createState() => _CloudIYHomeState();
}

class _CloudIYHomeState extends State<CloudIYHome> {
  var selectedIndex = 0;
  Future<Isolate>? installationIsolate;

  @override
  void initState() {
    installationIsolate =
        Isolate.spawn(CiyInstaller.installCiyRequirements, [RootIsolateToken.instance!]);
    super.initState();
  }

  Widget buildMenuWhenAllFilesAreInstalled(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = Placeholder();
        break;
      case 1:
        page = SettingsPage();
        break;
      case 2:
        page = Placeholder();
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }
    return Scaffold(
      body: Row(
        children: [
          SafeArea(
            child: SizedBox(
              width: 80,
              child: NavigationRail(
                extended: false,
                destinations: [
                  NavigationRailDestination(
                    icon: Icon(Icons.home),
                    label: Text('Home'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.settings),
                    label: Text('Settings'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.check_circle),
                    label: Text('Settings'),
                  ),
                ],
                selectedIndex: selectedIndex, // ← Change to this.
                onDestinationSelected: (value) {
                  // ↓ Replace print with this.
                  setState(() {
                    selectedIndex = value;
                  });
                },
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: page,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return buildMenuWhenAllFilesAreInstalled(context);
  }
}
