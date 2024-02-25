sealed class InstallationEvent {}

final class VirtualizationInstalledFinishedEvent extends InstallationEvent {
  VirtualizationInstalledFinishedEvent(this.status);
  final bool status;
}

final class VMInstallationFinishedEvent extends InstallationEvent {
  VMInstallationFinishedEvent(this.status);
  final bool status;
}

final class BackendInstallationFinishedEvent extends InstallationEvent {
  BackendInstallationFinishedEvent(this.status);
  final bool status;
}