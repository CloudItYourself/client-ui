import 'dart:io';
import 'package:path/path.dart' as path;

import 'package:ciy_client/widgets/bloc/additional_settings_bloc.dart';
import 'package:ciy_client/widgets/bloc/launch_vm_bloc.dart';
import 'package:ciy_client/widgets/bloc/login_bloc.dart';
import 'package:ciy_client/widgets/bloc/vm_installation_bloc.dart';
import 'package:ciy_client/widgets/view/additional_settings.dart';
import 'package:ciy_client/widgets/view/app_bar.dart';
import 'package:ciy_client/widgets/view/installation_status.dart';
import 'package:ciy_client/widgets/view/login.dart';
import 'package:ciy_client/widgets/view/run_vm_button.dart';
import 'package:ciy_client/widgets/view/vm_parameters.dart';
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

  @override
  void initState() {
    super.initState();
    initSystemTray();
  }

  Future<void> initSystemTray() async {
    final appHomeDir = path.dirname(Platform.script.toFilePath()).toString();

    String icoPath =  '$appHomeDir/assets/app_icon_windows.ico';
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
    return MultiBlocProvider(
      providers: [
        BlocProvider<VMInstallationBloc>(
          create: (context) => VMInstallationBloc(),
        ),
        BlocProvider<VMRunBloc>(create: ((context) => VMRunBloc())),
        BlocProvider<AdditionalSettingsBloc>(
            create: ((context) => AdditionalSettingsBloc())),
        BlocProvider<LoginBloc>(create: ((context) => LoginBloc())),
      ],
      child: Scaffold(
        appBar: PreferredSize(
            preferredSize: const Size.fromHeight(kWindowCaptionHeight),
            child: CiyWindowCaption(
                brightness: Theme.of(context).brightness,
                backgroundColor: Theme.of(context).colorScheme.background,
                title: Text("Cloud IY")
                )),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              SizedBox(
                width: 380,
                child: Column(children: [
                  VmSettingsMenu(),
                  Padding(
                    padding: const EdgeInsets.only(top: 40.0, left: 20.0),
                    child: InstallationStatusWidget(),
                  ),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: SizedBox(
                  width: 380,
                  child: Column(children: [
                    LoginWidget(),
                    Padding(
                      padding: const EdgeInsets.only(top: 60.0),
                      child: SizedBox(
                          width: 380,
                          height: 160,
                          child: AdditionalSettigsWidget()),
                    ),
                    RunVMButton(),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
