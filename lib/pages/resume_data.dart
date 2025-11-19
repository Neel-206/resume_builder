import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:resume_builder/pages/choose_template.dart';
import 'package:resume_builder/pages/create_resume.dart';
import 'package:resume_builder/pages/pdf_preview_page.dart';
import 'package:resume_builder/services/database_helper.dart';
import 'package:resume_builder/services/pdf_service.dart';

class ResumeData extends StatefulWidget {
  const ResumeData({super.key});

  @override
  State<ResumeData> createState() => _ResumeDataState();
}

class _ResumeDataState extends State<ResumeData> {
  List<int> _resumeIds = [];
  int? _selectedResumeId;
  Map<String, List<Map<String, dynamic>>> _selectedResumeData = {};

  @override
  void initState() {
    super.initState();
    _loadResumeIds();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff5f56ee), Color(0xffe4d8fd), Color(0xff9b8fff)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Container(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: EdgeInsets.only(top: screenHeight * 0.07),
            child: Column(
              children: [
                Text(
                  'Resume Data',
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                      color: Colors.white,
                      fontSize: screenWidth * 0.08,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.015),
                Container(
                  width: screenWidth * 0.33,
                  height: 5,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Color(0xffffb300),
                        Color.fromARGB(255, 255, 255, 255),
                        Color(0xffffb300),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                SizedBox(height: screenHeight * 0.04),
                _buildSubtitle(screenWidth),
                SizedBox(height: screenHeight * 0.03),
                Expanded(child: _buildResumeList(screenWidth, screenHeight)),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Container(
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
                  onTap: _showAddResumeDialog,
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
                      child: const Icon(
                        Icons.add_rounded,
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
      ),
    );
  }

  Widget _buildSubtitle(double screenWidth) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
      child: Text(
        'Update your resume data effortlessly—edit any section anytime.',
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(
          textStyle: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: screenWidth * 0.04,
            fontWeight: FontWeight.w400,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  void _showAddResumeDialog() {
    final formKey = GlobalKey<FormState>();
    final firstNameController = TextEditingController();
    final lastNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Create New Resume'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: firstNameController,
                  decoration: const InputDecoration(labelText: 'First Name'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a first name.';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: lastNameController,
                  decoration: const InputDecoration(labelText: 'Last Name'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  Navigator.of(dialogContext).pop(); // Close dialog

                  final newResumeId = DateTime.now().millisecondsSinceEpoch;
                  final dbHelper = DatabaseHelper.instance;

                  await dbHelper.insert(DatabaseHelper.tableProfile, {
                    'resumeId': newResumeId,
                    'firstName': firstNameController.text.trim(),
                    'lastName': lastNameController.text.trim(),
                  });

                  // final result = await Navigator.of(context).push(
                  //   MaterialPageRoute(
                  //     builder: (context) => CreateResume(resumeId: newResumeId),
                  //   ),
                  // );

                  if (mounted) {
                    _loadResumeIds();
                    _showSnackBar('New resume created!');
                  }
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  void _loadResumeIds() async {
    final dbHelper = DatabaseHelper.instance;
    final profiles =
        await dbHelper.queryAllRows(DatabaseHelper.tableProfile, orderBy: 'id');
    final ids = profiles.map((p) => p['resumeId'] as int).toSet().toList();
    ids.sort((a, b) => b.compareTo(a)); // Show newest first
    if (mounted) {
      setState(() {
        _resumeIds = ids;
      });
    }
  }

  Future<void> _loadDataForResume(int resumeId) async {
    final dbHelper = DatabaseHelper.instance;
    final whereClause = 'resumeId = ?';
    final whereArgs = [resumeId];

    final data = {
      "Profile": await dbHelper.queryAllRows(
        DatabaseHelper.tableProfile,
        where: whereClause,
        whereArgs: whereArgs,
        orderBy: 'id',
      ),
      "About": await dbHelper.queryAllRows(
        DatabaseHelper.tableAbout,
        where: whereClause,
        whereArgs: whereArgs,
        orderBy: 'id',
      ),
      "Education": await dbHelper.queryAllRows(
        DatabaseHelper.tableEducation,
        where: whereClause,
        whereArgs: whereArgs,
        orderBy: 'id',
      ),
      "Experience": await dbHelper.queryAllRows(
        DatabaseHelper.tableExperience,
        where: whereClause,
        whereArgs: whereArgs,
        orderBy: 'id',
      ),
      "Projects": await dbHelper.queryAllRows(
        DatabaseHelper.tableProjects,
        where: whereClause,
        whereArgs: whereArgs,
        orderBy: 'id',
      ),
      "Awards": await dbHelper.queryAllRows(
        DatabaseHelper.tableAwards,
        where: whereClause,
        whereArgs: whereArgs,
        orderBy: 'id',
      ),
      "Languages": await dbHelper.queryAllRows(
        DatabaseHelper.tableLanguages,
        where: whereClause,
        whereArgs: whereArgs,
        orderBy: 'id',
      ),
      "Hobbies": await dbHelper.queryAllRows(
        DatabaseHelper.tableHobbies,
        where: whereClause,
        whereArgs: whereArgs,
        orderBy: 'id',
      ),
      "References": await dbHelper.queryAllRows(
        DatabaseHelper.tableAppReferences,
        where: whereClause,
        whereArgs: whereArgs,
        orderBy: 'id',
      ),
      "Skills": await dbHelper.queryAllRows(
        DatabaseHelper.tableSkills,
        where: whereClause,
        whereArgs: whereArgs,
        orderBy: 'id',
      ),
    };

    if (mounted) {
      setState(() {
        _selectedResumeData = data;
      });
    }
  }

  Widget _buildResumeList(double screenWidth, double screenHeight) {
    if (_resumeIds.isEmpty) {
      return Center(
        child: Text(
          'No resumes found.',
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
      itemCount: _resumeIds.length,
      itemBuilder: (context, index) {
        final resumeId = _resumeIds[index];

        return FutureBuilder<List<Map<String, dynamic>>>(
          future: DatabaseHelper.instance.queryAllRows(
            DatabaseHelper.tableProfile,
            where: 'resumeId = ?',
            whereArgs: [resumeId],
            orderBy: 'id',
          ),
          builder: (context, snapshot) {
            final resumeDate = DateTime.fromMillisecondsSinceEpoch(resumeId);
            final formattedDate = DateFormat(
              'MMM d, yyyy, h:mm a',
            ).format(resumeDate);
            String titleText = 'Resume from $formattedDate';

            if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              final profile = snapshot.data!.first;
              final firstName = profile['firstName'] ?? '';
              final lastName = profile['lastName'] ?? '';
              if (firstName.isNotEmpty || lastName.isNotEmpty) {
                titleText = '$firstName $lastName'.trim();
              }
            }

            final isSelected = _selectedResumeId == resumeId;

            return Padding(
              padding: EdgeInsets.only(bottom: screenHeight * 0.02),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ExpansionTile(
                  key: PageStorageKey('resume_$resumeId'),
                  onExpansionChanged: (expanded) {
                    setState(() {
                      if (expanded) {
                        _selectedResumeId = resumeId;
                        _loadDataForResume(resumeId);
                      } else {
                        _selectedResumeId = null;
                        _selectedResumeData.clear();
                      }
                    });
                  },
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          titleText,
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(
                              color: Colors.white,
                              fontSize: screenWidth * 0.045,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.style_outlined,
                            color: Colors.white.withOpacity(0.8)),
                        onPressed: () => _changeTemplate(resumeId),
                        tooltip: 'Change Template',
                        splashRadius: 20,
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outline_rounded,
                            color: Colors.white.withOpacity(0.8)),
                        onPressed: () => _showDeleteDialog(resumeId, titleText),
                        tooltip: 'Delete Resume Data',
                        splashRadius: 20,
                      ),
                    ],
                  ),
                  iconColor: Colors.white,
                  collapsedIconColor: Colors.white,
                  tilePadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  children: isSelected
                      ? _selectedResumeData.entries.map((entry) {
                          return _buildSectionExpansionTile(
                            entry.key,
                            entry.value,
                            screenWidth,
                          );
                        }).toList()
                      : [],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showDeleteDialog(int resumeId, String resumeTitle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white.withOpacity(0.95),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.all(24),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.red.shade400, Colors.red.shade600],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.warning_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'Delete Resume?',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'This will permanently delete "$resumeTitle" and all its data. This action cannot be undone.',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey.shade700,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteResume(resumeId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
            ),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  // Helper function to show snackbar messages
  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _deleteResume(int resumeId) async {
    final dbHelper = DatabaseHelper.instance;

    // Find and delete all associated saved PDF files
    final savedResumes = await dbHelper.queryAllRows(
      DatabaseHelper.tableSavedResumes,
      where: 'resumeId = ?',
      whereArgs: [resumeId],
    );

    for (final resumeFile in savedResumes) {
      try {
        await File(resumeFile['filePath']).delete();
      } catch (e) {
        print('Could not delete file ${resumeFile['filePath']}: $e');
      }
    }

    // Delete all data from all tables for this resumeId
    await dbHelper.deleteAllDataForResume(resumeId);

    _showSnackBar('Resume data deleted successfully.');
    _loadResumeIds(); // Refresh the list
  }

  Future<void> _regeneratePdfForResume(int resumeId) async {
    final dbHelper = DatabaseHelper.instance;
    final pdfService = PdfService();

    // Find all saved resume files associated with this resumeId
    final savedResumes = await dbHelper.queryAllRows(
      DatabaseHelper.tableSavedResumes,
      where: 'resumeId = ?',
      whereArgs: [resumeId],
    );

    if (savedResumes.isNotEmpty) {
      _showSnackBar('Updating saved resume(s)...');
      for (final resumeInfo in savedResumes) {
        try {
          final templateName = resumeInfo['templateName'] as String;
          final filePath = resumeInfo['filePath'] as String;
          final pdfData =
              await pdfService.createResume(templateName, resumeId);
          await File(filePath).writeAsBytes(pdfData);
        } catch (e) {
          _showSnackBar('Failed to update ${resumeInfo['fileName']}: $e',
              isError: true);
        }
      }
      _showSnackBar('Saved resume(s) updated successfully!');
    }
  }

  void _changeTemplate(int resumeId) async {
    final dbHelper = DatabaseHelper.instance;
    final savedResumes = await dbHelper.queryAllRows(
      DatabaseHelper.tableSavedResumes,
      where: 'resumeId = ?',
      whereArgs: [resumeId],
      orderBy: 'createdAt DESC',
      limit: 1,
    );

    if (savedResumes.isNotEmpty && mounted) {
      // If a resume PDF already exists, show it in the preview page.
      final resumeInfo = savedResumes.first;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PdfPreviewPage(
            path: resumeInfo['filePath'],
            resumeId: resumeId,
            templateName: resumeInfo['templateName'],
            originalFilePath: resumeInfo['filePath'],
            isViewingOnly: false,
          ),
        ),
      );
    } else if (mounted) {
      // If no resume PDF exists, go to the template chooser.
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => ChooseTemplate(resumeId: resumeId)),
      );
    }

    // After returning from the template selection and preview,
    // check if any PDFs were updated and reflect the changes.
    if (mounted) {
      _regeneratePdfForResume(resumeId);
    }
  }

  void _navigateToEdit(String sectionTitle) async {
    final Map<String, int> sectionPageIndex = {
      'Profile': 0,
      'Awards': 1,
      'About': 2,
      'Education': 3,
      'Hobbies': 4,
      'Languages': 5,
      'Projects': 6,
      'References': 7,
      'Experience': 8,
      'Skills': 9,
    };

    final pageIndex = sectionPageIndex[sectionTitle] ?? 0;

    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CreateResume(
            resumeId: _selectedResumeId,
            initialPage: pageIndex,
            singlePageMode: true),
      ),
    );

    // If result is true, it means data was saved. Reload the data.
    if (result == true && _selectedResumeId != null && mounted) {
      _loadDataForResume(_selectedResumeId!);
      _regeneratePdfForResume(_selectedResumeId!);
    }
  }

  Widget _buildSectionExpansionTile(
    String title,
    List<Map<String, dynamic>> data,
    double screenWidth,
  ) {
    if (data.isEmpty) {
      if (title == 'Experience') {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          child: Container(
            padding: const EdgeInsets.only(left: 16, right: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                title,
                style: GoogleFonts.poppins(
                  textStyle: TextStyle(
                    color: Colors.white,
                    fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              subtitle: Text(
                'Fresher',
                style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.9), fontSize: 14),
              ),
              trailing: IconButton(
                icon: Icon(Icons.edit_rounded,
                    color: Colors.white.withOpacity(0.8)),
                onPressed: () => _navigateToEdit(title),
                splashRadius: 20,
              ),
            ),
          ),
        );
      }
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        child: Container(
          padding: const EdgeInsets.only(left: 16, right: 8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              title,
              style: GoogleFonts.poppins(
                textStyle: TextStyle(
                  color: Colors.white,
                  fontSize: screenWidth * 0.045,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            subtitle: Text(
              'No data available',
              style: GoogleFonts.poppins(
                  color: Colors.white.withOpacity(0.7), fontSize: 12),
            ),
            trailing: IconButton(
              icon: Icon(Icons.edit_rounded,
                  color: Colors.white.withOpacity(0.8)),
              onPressed: () => _navigateToEdit(title),
              splashRadius: 20,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: ExpansionTile(
          key: PageStorageKey('${_selectedResumeId}_$title'),
          tilePadding: EdgeInsets.only(left: 16, right: 8),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                      color: Colors.white,
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.edit_rounded,
                  color: Colors.white.withOpacity(0.8),
                ),
                onPressed: () => _navigateToEdit(title),
                splashRadius: 20,
              ),
            ],
          ),
          iconColor: Colors.white,
          collapsedIconColor: Colors.white,
          children: data.map((item) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(screenWidth * 0.04),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  item.entries
                      .where((e) => e.key != 'id' && e.key != 'resumeId')
                      .map((e) => '${e.key}: ${e.value}')
                      .join('\n'),
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: screenWidth * 0.038,
                      fontWeight: FontWeight.w400,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
