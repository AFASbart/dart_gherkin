import '../configuration.dart';
import '../gherkin/steps/step_run_result.dart';
import '../gherkin/steps/world.dart';
import '../reporters/messages/messages.dart';
import 'hook.dart';

class AggregatedHook extends Hook {
  Iterable<Hook>? _orderedHooks;

  void addHooks(Iterable<Hook> hooks) {
    _orderedHooks = hooks.toList()
      ..sort(
        (a, b) => b.priority - a.priority,
      );
  }

  @override
  Future<void> onBeforeRun(TestConfiguration config) =>
      _invokeHooks((h) => h.onBeforeRun(config));

  /// Run after all scenarios in a test run have completed
  @override
  Future<void> onAfterRun(TestConfiguration config) =>
      _invokeHooks((h) => h.onAfterRun(config));

  @override
  Future<void> onAfterScenarioWorldCreated(
    World world,
    String scenario,
    Iterable<Tag> tags,
  ) =>
      _invokeHooks(
        (h) => h.onAfterScenarioWorldCreated(
          world,
          scenario,
          tags,
        ),
      );

  /// Run before a scenario and it steps are executed
  @override
  Future<void> onBeforeScenario(
    TestConfiguration config,
    String scenario,
    Iterable<Tag> tags,
  ) =>
      _invokeHooks(
        (h) => h.onBeforeScenario(
          config,
          scenario,
          tags,
        ),
      );

  /// Run after a scenario has executed
  @override
  Future<void> onAfterScenario(
    TestConfiguration config,
    String scenario,
    Iterable<Tag> tags,
    bool passed,
  ) async =>
      await _invokeHooks(
        (h) => h.onAfterScenario(
          config,
          scenario,
          tags,
          passed,
        ),
      );

  /// Run before a step is executed
  @override
  Future<void> onBeforeStep(
    World world,
    String step,
  ) =>
      _invokeHooks((h) => h.onBeforeStep(world, step));

  /// Run after a step has executed
  @override
  Future<void> onAfterStep(
    World world,
    String step,
    StepResult result,
  ) =>
      _invokeHooks((h) => h.onAfterStep(world, step, result));

  Future<void> _invokeHooks(
    Future<void> Function(Hook h) invoke,
  ) async {
    if (_orderedHooks != null && _orderedHooks!.isNotEmpty) {
      for (final hook in _orderedHooks!) {
        await invoke(hook);
      }
    }
  }
}
