//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <flutter_desktop_sleep/flutter_desktop_sleep_plugin_c_api.h>
#include <flutter_secure_storage_windows/flutter_secure_storage_windows_plugin.h>
#include <screen_retriever/screen_retriever_plugin.h>
#include <system_tray/system_tray_plugin.h>
#include <url_launcher_windows/url_launcher_windows.h>
#include <window_manager/window_manager_plugin.h>
#include <window_to_front/window_to_front_plugin.h>
#include <windows_single_instance/windows_single_instance_plugin.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  FlutterDesktopSleepPluginCApiRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("FlutterDesktopSleepPluginCApi"));
  FlutterSecureStorageWindowsPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("FlutterSecureStorageWindowsPlugin"));
  ScreenRetrieverPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("ScreenRetrieverPlugin"));
  SystemTrayPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("SystemTrayPlugin"));
  UrlLauncherWindowsRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("UrlLauncherWindows"));
  WindowManagerPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("WindowManagerPlugin"));
  WindowToFrontPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("WindowToFrontPlugin"));
  WindowsSingleInstancePluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("WindowsSingleInstancePlugin"));
}
