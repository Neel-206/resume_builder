import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:resume_builder/services/resume_storage.dart';

class PdfPreviewPage extends StatelessWidget {
  final String path;
  final String templateName;
  final int resumeId;
  final String? originalFilePath;
  final bool isViewingOnly;

  const PdfPreviewPage({
    super.key, 
    required this.path,
    this.templateName = 'Default', 
    required this.resumeId,
    this.originalFilePath,
    this.isViewingOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xff5f56ee), Color(0xffe4d8fd), Color(0xff9b8fff)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            const SizedBox(height: 40),
            const Text(
              'Resume Preview',
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: 150,
              height: 5,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xffffb300),
                    Color.fromARGB(255, 255, 255, 255),
                    Color(0xffffb300),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.deepPurple.withOpacity(0.2),
                          blurRadius: 30,
                          offset: const Offset(0, 12),
                        ),
                      ],
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.40),
                          Colors.white.withOpacity(0.15),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: 210 / 297, // A4 paper aspect ratio
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: PDFView(
                            filePath: path,
                            autoSpacing: false,
                            enableSwipe: true,
                            pageSnap: true,
                            swipeHorizontal: false,
                            fitPolicy: FitPolicy.BOTH,
                            nightMode: false,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Share Button
              _buildActionButton(
                context: context,
                icon: Icons.share,
                onTap: () async {
                  final file = XFile(path);
                  await Share.shareXFiles([file], text: 'Here is my resume!');
                },
              ),
              // Show the correct second button based on the context
              if (isViewingOnly)
                _buildPrintButton(context) // For viewing existing resumes
              else if (originalFilePath == null)
                _buildDownloadAndSaveButton(context) // For new resumes
              else
                _buildSaveChangesButton(context), // For edited resumes
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildDownloadAndSaveButton(BuildContext context) {
    return _buildActionButton(
      context: context,
      icon: Icons.download_rounded,
      onTap: () async {
        try {
          // Save as new resume
          final savedPath = await ResumeStorage.saveResume(path, templateName, resumeId);

          // Then trigger the print/download action
          final file = File(savedPath);
          final Uint8List bytes = await file.readAsBytes();
          await Printing.layoutPdf(
            onLayout: (format) async => bytes,
            name: 'resume.pdf',
          );

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Resume saved to library!')),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to save or download resume: $e')),
            );
          }
        }
      },
    );
  }

  Widget _buildSaveChangesButton(BuildContext context) {
    return _buildActionButton(
      context: context,
      icon: Icons.save_alt_rounded,
      onTap: () async {
        try {
          // Update existing resume
          await ResumeStorage.updateResume(path, originalFilePath!, templateName, resumeId);

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Resume updated successfully!')),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to update resume: $e')),
            );
          }
        }
      },
    );
  }

  Widget _buildPrintButton(BuildContext context) {
    return _buildActionButton(
      context: context,
      icon: Icons.print_rounded,
      onTap: () async {
        try {
          final file = File(path);
          final Uint8List bytes = await file.readAsBytes();
          await Printing.layoutPdf(
            onLayout: (format) async => bytes,
            name: 'resume.pdf',
          );
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to print resume: $e')),
            );
          }
        }
      },
    );
  }


  // Helper widget to create the glassmorphic icon buttons
  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 62,
      height: 62,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(56),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 30,
            offset: const Offset(0, 15),
            spreadRadius: -5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(56),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(56),
              color: Colors.white.withOpacity(0.1),
              border: Border.all(
                color: Colors.white.withOpacity(0.60),
                width: 0.5,
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.5),
                  Colors.white.withOpacity(0.1),
                ],
                stops: const [0.0, 1.0],
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                splashFactory: InkRipple.splashFactory,
                splashColor: Colors.white.withOpacity(0.2),
                highlightColor: Colors.white.withOpacity(0.1),
                child: Center(
                  child: ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(1),
                          Colors.white.withOpacity(0.8),
                        ],
                      ).createShader(bounds);
                    },
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
