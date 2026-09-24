import 'package:logger/logger.dart';

/// App-specific logger utility with predefined log messages
class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );

  // App startup logs
  static void appStarted() => _logger.i('🚀 Time Tracking App Started');
  static void appInitialized() => _logger.i('✅ App Initialization Complete');

  // Data loading logs  
  static void dataLoadStarted() => _logger.i('📖 Loading app data...');
  static void dataLoadCompleted(int projects, int tasks, int entries) => 
    _logger.i('✅ Data loaded: $projects projects, $tasks tasks, $entries entries');
  static void dataLoadFailed(dynamic error) => _logger.e('❌ Data loading failed', error: error);

  // CRUD operation logs
  static void projectAdded(String projectName) => _logger.i('➕ Project added: $projectName');
  static void projectDeleted(String projectName) => _logger.i('🗑️ Project deleted: $projectName');
  static void taskAdded(String taskName) => _logger.i('➕ Task added: $taskName');
  static void taskDeleted(String taskName) => _logger.i('🗑️ Task deleted: $taskName');
  static void timeEntryAdded(double hours, String projectName) => 
    _logger.i('⏱️ Time entry added: ${hours}h to $projectName');
  static void timeEntryDeleted() => _logger.i('🗑️ Time entry deleted');

  // Navigation logs
  static void screenOpened(String screenName) => _logger.d('📱 Opened screen: $screenName');
  static void dialogOpened(String dialogName) => _logger.d('💬 Opened dialog: $dialogName');

  // Error logs
  static void error(String message, [dynamic error, StackTrace? stackTrace]) => 
    _logger.e('❌ $message', error: error, stackTrace: stackTrace);
  
  // Warning logs
  static void warning(String message) => _logger.w('⚠️ $message');

  // Debug logs (only in debug mode)
  static void debug(String message) {
    if (Logger.level == Level.debug) {
      _logger.d('🐛 $message');
    }
  }

  // Performance logs
  static void performanceStart(String operation) => _logger.d('⚡ Started: $operation');
  static void performanceEnd(String operation, Duration duration) => 
    _logger.d('⚡ Completed: $operation in ${duration.inMilliseconds}ms');
}