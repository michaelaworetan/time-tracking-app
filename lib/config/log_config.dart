import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart';

class LogConfig {
  /// Configure logging based on build mode
  static Logger createLogger({Level? level}) {
    return Logger(
      printer: _getLogPrinter(),
      level: level ?? _getLogLevel(),
      filter: _getLogFilter(),
    );
  }

  /// Get appropriate log level based on build mode
  static Level _getLogLevel() {
    if (kDebugMode) {
      return Level.debug;  // Show all logs in debug mode
    } else if (kProfileMode) {
      return Level.info;   // Show info and above in profile mode
    } else {
      return Level.warning; // Show only warnings and errors in release mode
    }
  }

  /// Get log printer based on build mode
  static LogPrinter _getLogPrinter() {
    if (kDebugMode) {
      // Detailed logging for development
      return PrettyPrinter(
        methodCount: 3,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        printTime: true,
        excludeBox: const {},
      );
    } else {
      // Simple logging for production
      return SimplePrinter(
        colors: false,
        printTime: true,
      );
    }
  }

  /// Get log filter
  static LogFilter _getLogFilter() {
    return ProductionFilter();
  }

  /// Custom log tags for different modules
  static const String tagAuth = '🔐 AUTH';
  static const String tagStorage = '💾 STORAGE';
  static const String tagUI = '🎨 UI';
  static const String tagProvider = '🔄 PROVIDER';
  static const String tagNavigation = '🧭 NAV';
  static const String tagPerformance = '⚡ PERF';
  static const String tagError = '❌ ERROR';

  /// Tagged logging methods
  static void logAuth(String message, [Level level = Level.info]) {
    _logWithTag(tagAuth, message, level);
  }

  static void logStorage(String message, [Level level = Level.info]) {
    _logWithTag(tagStorage, message, level);
  }

  static void logUI(String message, [Level level = Level.debug]) {
    _logWithTag(tagUI, message, level);
  }

  static void logProvider(String message, [Level level = Level.info]) {
    _logWithTag(tagProvider, message, level);
  }

  static void logNavigation(String message, [Level level = Level.debug]) {
    _logWithTag(tagNavigation, message, level);
  }

  static void logPerformance(String message, [Level level = Level.info]) {
    _logWithTag(tagPerformance, message, level);
  }

  static void logError(String message, [dynamic error, StackTrace? stackTrace]) {
    final logger = createLogger();
    logger.e('$tagError $message', error: error, stackTrace: stackTrace);
  }

  static void _logWithTag(String tag, String message, Level level) {
    final logger = createLogger();
    final taggedMessage = '$tag $message';
    
    switch (level) {
      case Level.trace:
        logger.t(taggedMessage);
        break;
      case Level.debug:
        logger.d(taggedMessage);
        break;
      case Level.info:
        logger.i(taggedMessage);
        break;
      case Level.warning:
        logger.w(taggedMessage);
        break;
      case Level.error:
        logger.e(taggedMessage);
        break;
      case Level.fatal:
        logger.f(taggedMessage);
        break;
      case Level.all:
        // TODO: Handle this case.
        throw UnimplementedError();
      case Level.verbose:
        // TODO: Handle this case.
        throw UnimplementedError();
      case Level.wtf:
        // TODO: Handle this case.
        throw UnimplementedError();
      case Level.nothing:
        // TODO: Handle this case.
        throw UnimplementedError();
      case Level.off:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }
}