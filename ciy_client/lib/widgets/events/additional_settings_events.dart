sealed class AdditionalSettingsEvent {}

final class SelfManagerEvent extends AdditionalSettingsEvent {
  SelfManagerEvent(this.status);
  bool status;
}

final class RunOnStartupEvent extends AdditionalSettingsEvent {
  RunOnStartupEvent(this.status);
  bool status;
}

final class StartInTrayEvent extends AdditionalSettingsEvent {
  StartInTrayEvent(this.status);
  bool status;
}