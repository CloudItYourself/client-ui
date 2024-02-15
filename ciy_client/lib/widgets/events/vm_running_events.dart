sealed class VMRuntimeEvent {}

final class VMStartEvent extends VMRuntimeEvent {
  VMStartEvent();
}

final class VMRunningEvent extends VMRuntimeEvent {
  VMRunningEvent();
}

final class VMTerminateRequest extends VMRuntimeEvent {
  VMTerminateRequest();
}

final class VMStopEvent extends VMRuntimeEvent {
  VMStopEvent();
}
