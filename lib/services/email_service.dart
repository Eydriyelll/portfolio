import 'dart:async';
import 'package:js/js.dart';
import 'package:js/js_util.dart';

@JS('sendContactEmail')
external dynamic _sendContactEmail(
  String fromName,
  String fromEmail,
  String service,
  String message,
);

class EmailService {
  /// Sends email via EmailJS directly to araos.adriel06@gmail.com
  /// Returns null on success, error string on failure
  static Future<String?> sendEmail({
    required String fromName,
    required String fromEmail,
    required String service,
    required String message,
  }) async {
    try {
      final promise = _sendContactEmail(fromName, fromEmail, service, message);
      await promiseToFuture(promise);
      return null;
    } catch (e) {
      final msg = e.toString();
      // Extract readable message from JS error
      if (msg.contains('412') || msg.contains('Invalid')) {
        return 'Invalid EmailJS configuration. Check your template settings.';
      }
      if (msg.contains('network') || msg.contains('fetch')) {
        return 'Network error. Please check your connection.';
      }
      return 'Failed to send: $msg';
    }
  }
}
