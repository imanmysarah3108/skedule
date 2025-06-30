import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PerformanceHelper {
  static void logPerformance(String message) {
    if (kDebugMode) {
      debugPrint('⏱️ $message');
    }
  }

  static Future<void> runInBackground(Function() task) async {
    if (kIsWeb) {
      await task();
    } else {
      await compute(_runTask, task);
    }
  }

  static void _runTask(Function() task) => task();

  static Widget buildLoadingPlaceholder() {
    return const Center(
      child: SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  static Widget buildErrorWidget(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
        ],
      ),
    );
  }
}