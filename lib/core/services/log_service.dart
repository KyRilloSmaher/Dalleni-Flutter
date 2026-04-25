import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

class LogService {
  static const String _logFileName = 'api_logs.txt';
  final List<String> _webLogs = <String>[];

  Future<String> get _logFilePath async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/$_logFileName';
  }

  Future<void> log(String message) async {
    final timestamp = DateTime.now().toIso8601String();
    final logMessage = '[$timestamp] $message\n---\n';

    debugPrint(logMessage);

    if (kIsWeb) {
      _webLogs.add(logMessage);
      return;
    }

    try {
      final path = await _logFilePath;
      final file = File(path);

      await file.writeAsString(logMessage, mode: FileMode.append);
    } catch (e) {
      debugPrint('Error writing to log file: $e');
    }
  }

  Future<void> clearLogs() async {
    if (kIsWeb) {
      _webLogs.clear();
      return;
    }

    try {
      final path = await _logFilePath;
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('Error clearing log file: $e');
    }
  }

  Future<String> readLogs() async {
    if (kIsWeb) {
      return _webLogs.join();
    }

    try {
      final path = await _logFilePath;
      final file = File(path);
      if (await file.exists()) {
        return await file.readAsString();
      }
    } catch (e) {
      debugPrint('Error reading log file: $e');
    }
    return '';
  }

  Future<File?> getLogFile() async {
    if (kIsWeb) {
      return null;
    }

    try {
      final path = await _logFilePath;
      return File(path);
    } catch (e) {
      debugPrint('Error getting log file: $e');
      return null;
    }
  }
}

final logServiceProvider = Provider<LogService>((ref) {
  return LogService();
});
