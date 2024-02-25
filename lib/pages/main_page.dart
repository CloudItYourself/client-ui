import 'dart:io';
import 'package:ciy_client/pages/home.dart';
import 'package:ciy_client/pages/settings.dart';
import 'package:ciy_client/widgets/bloc/cluster_url_bloc.dart';
import 'package:ciy_client/widgets/bloc/cpu_slider_bloc.dart';
import 'package:ciy_client/widgets/bloc/ram_slider_bloc.dart';
import 'package:path/path.dart' as path;

import 'package:ciy_client/widgets/bloc/additional_settings_bloc.dart';
import 'package:ciy_client/widgets/bloc/launch_vm_bloc.dart';
import 'package:ciy_client/widgets/bloc/login_bloc.dart';
import 'package:ciy_client/widgets/bloc/vm_installation_bloc.dart';
import 'package:ciy_client/widgets/view/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:system_tray/system_tray.dart';

class UnifiedPage extends StatefulWidget {
  @override
  State<UnifiedPage> createState() => _UnifiedPageState();
}

class _UnifiedPageState extends State<UnifiedPage> {
  final AppWindow _appWindow = AppWindow();
  final SystemTray _systemTray = SystemTray();
  var selectedPageIndex = 0;

  @override
  void initState() {
    super.initState();
    initSystemTray();
  }

  Future<void> initSystemTray() async {
    final appHomeDir = path.dirname(Platform.script.toFilePath()).toString();

    String icoPath = '$appHomeDir/assets/app_icon_windows.ico';
    if (!File(icoPath).existsSync()) {
      icoPath = '$appHomeDir/data/flutter_assets/assets/app_icon_windows.ico';
    }
    // We first init the systray menu
    await _systemTray.initSystemTray(
      title: "CloudIY",
      iconPath: icoPath,
    );

    // create context menu
    final Menu menu = Menu();
    await menu.buildFrom([
      MenuItemLabel(label: 'Show', onClicked: (menuItem) => _appWindow.show()),
      MenuItemLabel(label: 'Exit', onClicked: (menuItem) => _appWindow.close()),
    ]);

    // set context menu
    await _systemTray.setContextMenu(menu);

    // handle system tray event
    _systemTray.registerSystemTrayEventHandler((eventName) {
      if (eventName == kSystemTrayEventClick) {
        Platform.isWindows ? _appWindow.show() : _systemTray.popUpContextMenu();
      } else if (eventName == kSystemTrayEventRightClick) {
        Platform.isWindows ? _systemTray.popUpContextMenu() : _appWindow.show();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedPageIndex) {
      case 0:
        page = HomePage();
      case 1:
        page = SettingsPage();
      default:
        throw UnimplementedError('no widget for $selectedPageIndex');
    }
    return MultiBlocProvider(
      providers: [
        BlocProvider<VMInstallationBloc>(
          create: (context) => VMInstallationBloc(),
        ),
        BlocProvider<VMRunBloc>(create: ((context) => VMRunBloc())),
        BlocProvider<AdditionalSettingsBloc>(
            create: ((context) => AdditionalSettingsBloc())),
        BlocProvider<LoginBloc>(create: ((context) => LoginBloc())),
        BlocProvider<CPUValueBloc>(
          create: (context) => CPUValueBloc(),
        ),
        BlocProvider<RAMValuesBloc>(
          create: (context) => RAMValuesBloc(),
        ),
        BlocProvider<CurrentURLBloc>(
          create: (context) => CurrentURLBloc(),
        ),
      ],
      child: Scaffold(
        appBar: PreferredSize(
            preferredSize: const Size.fromHeight(kWindowCaptionHeight),
            child: CiyWindowCaption(
                brightness: Theme.of(context).brightness,
                backgroundColor: Theme.of(context).colorScheme.background,
                title: Text("Cloud IY"))),
        body: Row(
          children: [
            SafeArea(
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
                ],
                selectedIndex: selectedPageIndex, // ← Change to this.
                onDestinationSelected: (value) {
                  // ↓ Replace print with this.
                  setState(() {
                    selectedPageIndex = value;
                  });
                },
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
      ),
    );
  }
}
