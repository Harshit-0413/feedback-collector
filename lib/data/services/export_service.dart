import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:local_auth/local_auth.dart';
import '../models/feedback_model.dart';

class ExportService {
  final LocalAuthentication _localAuth = LocalAuthentication();

  Future<bool> authenticateWithBiometric() async {
    try {
      final bool canAuthenticate =
          await _localAuth.canCheckBiometrics ||
          await _localAuth.isDeviceSupported();

      if (!canAuthenticate) return true;

      return await _localAuth.authenticate(
        localizedReason: 'Authenticate to export feedback data',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
    } catch (e) {
      return false;
    }
  }

  Future<String?> exportToCSV(List<FeedbackModel> feedbacks) async {
    try {
      final authenticated = await authenticateWithBiometric();
      if (!authenticated) return null;

      List<List<dynamic>> rows = [
        [
          'Device Owner',
          'User Name',
          'User Email',
          'User Contact',
          'Bug/Issue',
          'User Device',
          'Description and Media Links',
          'Submitted At',
        ],
      ];

      for (final feedback in feedbacks) {
        rows.add([
          feedback.deviceOwner,
          feedback.userName,
          feedback.userEmail,
          feedback.userContact,
          feedback.bugDescription,
          feedback.userDevice,
          feedback.mediaPaths.join(', '),
          feedback.createdAt.toIso8601String(),
        ]);
      }

      final csvData = const ListToCsvConverter().convert(rows);

      final directory = await getApplicationDocumentsDirectory();
      final exportDir = Directory('${directory.path}/exports');
      if (!await exportDir.exists()) {
        await exportDir.create(recursive: true);
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${exportDir.path}/feedback_export_$timestamp.csv';
      final file = File(filePath);
      await file.writeAsString(csvData);

      return filePath;
    } catch (e) {
      throw Exception('Export failed: $e');
    }
  }
}
