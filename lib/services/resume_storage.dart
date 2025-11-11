import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:resume_builder/services/database_helper.dart';

class ResumeStorage {
  static final dbHelper = DatabaseHelper.instance;
  
  static Future<String> saveResume(String sourcePath, String templateName, int resumeId) async {
    try {
      // Get the application documents directory
      final directory = await getApplicationDocumentsDirectory();
      
      // Create a timestamp-based filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'resume_${templateName}_$timestamp.pdf';
      final targetPath = '${directory.path}/$fileName';

      // Copy the file to documents directory
      await File(sourcePath).copy(targetPath);

      // Store the reference in database
      await dbHelper.insert('saved_resumes', {
        'fileName': fileName,
        'filePath': targetPath,
        'resumeId': resumeId,
        'templateName': templateName,
        'createdAt': DateTime.now().toIso8601String(),
      });

      return targetPath;
    } catch (e) {
      print('Error saving resume: $e');
      rethrow;
    }
  }

  static Future<String> updateResume(String sourcePath, String targetPath, String templateName, int resumeId) async {
    try {
      // Overwrite the existing file with the new content from the temporary source path
      await File(sourcePath).copy(targetPath);

      // Update the reference in the database
      // We update the 'createdAt' timestamp to reflect the modification time.
      // A dedicated 'updatedAt' column would be even better for future improvements.
      await dbHelper.updateByResumeId('saved_resumes', {
        'templateName': templateName,
        'createdAt': DateTime.now().toIso8601String(),
      }, resumeId);

      return targetPath;
    } catch (e) {
      print('Error updating resume: $e');
      rethrow;
    }
  }


  static Future<List<Map<String, dynamic>>> getAllResumes() async {
    try {
      return await dbHelper.queryAllRows('saved_resumes');
    } catch (e) {
      print('Error getting resumes: $e');
      return [];
    }
  }

  static Future<void> deleteResume(String filePath) async {
    try {
      // Delete the file
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }

      // Delete from database
      await dbHelper.deleteByPath('saved_resumes', filePath);
    } catch (e) {
      print('Error deleting resume: $e');
      rethrow;
    }
  }
}