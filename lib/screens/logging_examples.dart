import 'package:flutter/material.dart';
import '../utils/app_logger.dart';
import '../services/logger_service.dart';

/// Example of how to use logging in your screens
class LoggingExamples {
  
  // Example 1: Log navigation
  static void navigateToScreen(BuildContext context, Widget screen, String screenName) {
    AppLogger.screenOpened(screenName);
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  // Example 2: Log dialog opening
  static Future<T?> showDialogWithLogging<T>(
    BuildContext context, 
    Widget dialog, 
    String dialogName,
  ) {
    AppLogger.dialogOpened(dialogName);
    return showDialog<T>(
      context: context,
      builder: (_) => dialog,
    );
  }

  // Example 3: Log form submissions
  static void logFormSubmission(String formName, Map<String, dynamic> data) {
    LoggerService.info('📝 Form submitted: $formName');
    LoggerService.debug('Form data: $data');
  }

  // Example 4: Log errors with context
  static void logError(String operation, dynamic error, [StackTrace? stackTrace]) {
    AppLogger.error('Error in $operation', error, stackTrace);
    
    // You could also send to crash analytics here
    // FirebaseCrashlytics.instance.recordError(error, stackTrace);
  }

  // Example 5: Performance logging
  static Future<T> logPerformance<T>(String operation, Future<T> Function() task) async {
    final stopwatch = Stopwatch()..start();
    AppLogger.performanceStart(operation);
    
    try {
      final result = await task();
      stopwatch.stop();
      AppLogger.performanceEnd(operation, stopwatch.elapsed);
      return result;
    } catch (e) {
      stopwatch.stop();
      AppLogger.error('Performance test failed for $operation', e);
      rethrow;
    }
  }

  // Example 6: User interaction logging
  static void logUserInteraction(String interaction, [Map<String, dynamic>? context]) {
    LoggerService.info('👆 User interaction: $interaction');
    if (context != null) {
      LoggerService.debug('Context: $context');
    }
  }
}

/// Usage Examples in your widgets:
/// 
/// ```dart
/// // In a button press:
/// onPressed: () {
///   LoggingExamples.logUserInteraction('Add Project Button Pressed');
///   LoggingExamples.navigateToScreen(context, ProjectManagementScreen(), 'Project Management');
/// }
///
/// // In form submission:
/// void _saveTimeEntry() async {
///   final data = {'project': selectedProject, 'hours': hours};
///   LoggingExamples.logFormSubmission('Time Entry Form', data);
///   
///   try {
///     await LoggingExamples.logPerformance('Save Time Entry', () async {
///       await provider.addTimeEntry(entry);
///     });
///   } catch (e) {
///     LoggingExamples.logError('Save Time Entry', e);
///   }
/// }
/// ```