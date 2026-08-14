import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

/// Instrumentacao temporaria para diagnosticar builds e processamentos no
/// DevTools. Em release, todos os metodos abaixo viram no-ops.
final class PerformanceProbe {
  PerformanceProbe._();

  static const Duration _frameBudget60Hz = Duration(microseconds: 16667);
  static bool _installed = false;
  static int _nextInteractionId = 0;
  static int _interactionHandlerDepth = 0;
  static final List<_InteractionSample> _pendingInteractions = [];

  static void install() {
    if (kReleaseMode || _installed) return;
    _installed = true;
    SchedulerBinding.instance.addTimingsCallback(_reportSlowFrames);
  }

  static void _reportSlowFrames(List<FrameTiming> timings) {
    for (final timing in timings) {
      final ui = timing.buildDuration;
      final raster = timing.rasterDuration;
      final slowUi = ui > _frameBudget60Hz;
      final slowRaster = raster > _frameBudget60Hz;
      if (!slowUi && !slowRaster) continue;

      final source = slowUi && slowRaster
          ? 'UI+Raster'
          : slowUi
          ? 'UI'
          : 'Raster';
      final arguments = <String, Object>{
        'frameNumber': timing.frameNumber,
        'source': source,
        'uiMs': _milliseconds(ui),
        'rasterMs': _milliseconds(raster),
        'totalMs': _milliseconds(timing.totalSpan),
      };
      developer.Timeline.instantSync(
        'Splitfoot.slowFrame.$source',
        arguments: arguments,
      );
      debugPrint(
        '[Splitfoot perf] frame ${timing.frameNumber} acima de 16,7 ms '
        '($source): UI=${arguments['uiMs']} ms, '
        'Raster=${arguments['rasterMs']} ms, '
        'total=${arguments['totalMs']} ms',
      );
    }
  }

  static double _milliseconds(Duration duration) =>
      duration.inMicroseconds / Duration.microsecondsPerMillisecond;

  static T timeSync<T>(
    String name,
    T Function() callback, {
    Map<String, Object>? arguments,
  }) {
    if (kReleaseMode) return callback();

    return developer.Timeline.timeSync<T>(
      'Splitfoot.$name',
      callback,
      arguments: arguments,
    );
  }

  static T interaction<T>(String name, T Function() callback) {
    if (kReleaseMode) return callback();

    if (_interactionHandlerDepth > 0) {
      final parent = _pendingInteractions.last;
      return timeSync(
        'interactionHandler.$name',
        callback,
        arguments: <String, Object>{
          'interactionId': parent.id,
          'nestedIn': parent.name,
        },
      );
    }

    final sample = _InteractionSample(++_nextInteractionId, name);
    _pendingInteractions.add(sample);
    developer.Timeline.instantSync(
      'Splitfoot.interaction.$name',
      arguments: {'interactionId': sample.id},
    );

    SchedulerBinding.instance.addPostFrameCallback((_) {
      final counts = sample.buildCounts.entries
          .map((entry) => '${entry.key}=${entry.value}')
          .join(', ');
      final summary = counts.isEmpty ? 'nenhum probe reconstruido' : counts;

      developer.Timeline.instantSync(
        'Splitfoot.rebuilds.$name',
        arguments: <String, Object>{
          'interactionId': sample.id,
          'total': sample.totalBuilds,
          'widgets': summary,
        },
      );
      debugPrint(
        '[Splitfoot perf] #${sample.id} $name: '
        '${sample.totalBuilds} rebuild(s) - $summary',
      );

      _pendingInteractions.remove(sample);
    });

    _interactionHandlerDepth += 1;
    try {
      return timeSync(
        'interactionHandler.$name',
        callback,
        arguments: {'interactionId': sample.id},
      );
    } finally {
      _interactionHandlerDepth -= 1;
    }
  }

  static void recordBuild(String widgetName) {
    if (kReleaseMode) return;

    for (final sample in _pendingInteractions) {
      sample.buildCounts.update(
        widgetName,
        (count) => count + 1,
        ifAbsent: () => 1,
      );
    }
  }
}

final class _InteractionSample {
  _InteractionSample(this.id, this.name);

  final int id;
  final String name;
  final Map<String, int> buildCounts = <String, int>{};

  int get totalBuilds =>
      buildCounts.values.fold(0, (sum, count) => sum + count);
}
