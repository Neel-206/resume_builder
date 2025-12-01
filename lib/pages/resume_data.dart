import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:glassmorphism_widgets/glassmorphism_widgets.dart';
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
  final Set<int> _expandedResumeIds = {};
  final Map<int, Map<String, List<Map<String, dynamic>>>> _resumesData = {};

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

      floatingActionButton: GlassContainer(
        width: 70,
        height: 70,
        borderRadius: BorderRadius.circular(35),
        linearGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.3),
            Colors.white.withOpacity(0.1),
          ],
        ),
        blur: 15,
        borderGradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.6),
            Colors.white.withOpacity(0.3),
          ],
        ),
        //borderWidth: 1.5,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(35),
            onTap: _showAddResumeDialog,
            splashFactory: InkRipple.splashFactory,
            splashColor: Colors.white.withOpacity(0.4),
            highlightColor: Colors.white.withOpacity(0.2),
            child: const Center(
              child: Icon(Icons.add_rounded, color: Colors.white, size: 30),
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
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 0.0, sigmaY: 0.0),
          child: AlertDialog(
            backgroundColor: Colors.white.withOpacity(
              0.3,
            ), // Semi-transparent background
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
              side: BorderSide(
                color: Colors.white.withOpacity(0.5),
                width: 1.0,
              ), // Optional border
            ),
            title: const Text('Create New Resume',style: TextStyle(color: Colors.white),),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: firstNameController,
                    decoration: InputDecoration(labelText: 'First Name',labelStyle: TextStyle(color: Colors.white)),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a first name.';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: lastNameController,
                    decoration: InputDecoration(labelText: 'Last Name',labelStyle: TextStyle(color: Colors.white)),
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
                    Navigator.of(dialogContext).pop();
                    final newResumeId = DateTime.now().millisecondsSinceEpoch;
                    final dbHelper = DatabaseHelper.instance;
                    await dbHelper.insert(DatabaseHelper.tableProfile, {
                      'resumeId': newResumeId,
                      'firstName': firstNameController.text.trim(),
                      'lastName': lastNameController.text.trim(),
                    });
                    if (mounted) {
                      _loadResumeIds();
                      _showSnackBar('New resume created!');
                    }
                  }
                },
                child: const Text('Create'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _loadResumeIds() async {
    final dbHelper = DatabaseHelper.instance;
    final profiles = await dbHelper.queryAllRows(
      DatabaseHelper.tableProfile,
      orderBy: 'id',
    );
    final ids = profiles.map((p) => p['resumeId'] as int).toSet().toList();
    ids.sort((a, b) => b.compareTo(a));
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
        _resumesData[resumeId] = data;
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

            final isExpanded = _expandedResumeIds.contains(resumeId);

            return Padding(
              padding: EdgeInsets.only(
                bottom: index == _resumeIds.length - 1
                    ? screenHeight * 0.1
                    : screenHeight * 0.01,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Theme(
                  data: Theme.of(
                    context,
                  ).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    collapsedShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),

                    key: PageStorageKey('resume_$resumeId'),
                    initiallyExpanded: isExpanded,
                    onExpansionChanged: (expanded) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        setState(() {
                          if (expanded) {
                            _expandedResumeIds.add(resumeId);
                            _loadDataForResume(resumeId);
                          } else {
                            _expandedResumeIds.remove(resumeId);
                          }
                        });
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
                        FutureBuilder<bool>(
                          future: _isResumeComplete(resumeId),
                          builder: (context, validationSnapshot) {
                            final bool isComplete =
                                validationSnapshot.data ?? false;
                            return IconButton(
                              icon: Icon(
                                Icons.style_outlined,
                                color: isComplete
                                    ? Colors.white.withOpacity(0.8)
                                    : Colors.white.withOpacity(0.3),
                              ),
                              onPressed: isComplete
                                  ? () => _changeTemplate(resumeId)
                                  : () {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Please fill all required fields (Profile, About, Education, Skills, Languages) to change template.',
                                          ),
                                        ),
                                      );
                                    },
                              tooltip: isComplete
                                  ? 'Change Template'
                                  : 'Fill required fields to change template',
                              splashRadius: 20,
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.delete_outline_rounded,
                            color: Colors.white.withOpacity(0.8),
                          ),
                          onPressed: () =>
                              _showDeleteDialog(resumeId, titleText),
                          tooltip: 'Delete Resume Data',
                          splashRadius: 20,
                        ),
                      ],
                    ),
                    iconColor: Colors.white,
                    collapsedIconColor: Colors.white,
                    tilePadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 0,
                    ),
                    children: isExpanded && _resumesData.containsKey(resumeId)
                        ? _resumesData[resumeId]!.entries.map((entry) {
                            return _buildSectionExpansionTile(
                              entry.key,
                              entry.value,
                              screenWidth,
                            );
                          }).toList()
                        : [],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<bool> _isResumeComplete(int resumeId) async {
    final dbHelper = DatabaseHelper.instance;
    final where = 'resumeId = ?';
    final whereArgs = [resumeId];

    final profileData = await dbHelper.queryAllRows(
      DatabaseHelper.tableProfile,
      where: where,
      whereArgs: whereArgs,
    );
    if (profileData.isEmpty) return false;

    final aboutData = await dbHelper.queryAllRows(
      DatabaseHelper.tableAbout,
      where: where,
      whereArgs: whereArgs,
    );
    if (aboutData.isEmpty) return false;

    final educationData = await dbHelper.queryAllRows(
      DatabaseHelper.tableEducation,
      where: where,
      whereArgs: whereArgs,
    );
    if (educationData.isEmpty) return false;

    final skillsData = await dbHelper.queryAllRows(
      DatabaseHelper.tableSkills,
      where: where,
      whereArgs: whereArgs,
    );
    if (skillsData.isEmpty) return false;

    final languagesData = await dbHelper.queryAllRows(
      DatabaseHelper.tableLanguages,
      where: where,
      whereArgs: whereArgs,
    );
    if (languagesData.isEmpty) return false;

    return true;
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

    final savedResumes = await dbHelper.queryAllRows(
      DatabaseHelper.tableSavedResumes,
      where: 'resumeId = ?',
      whereArgs: [resumeId],
    );

    for (final resumeFile in savedResumes) {
      try {
        await File(resumeFile['filePath']).delete();
      } catch (e) {}
    }

    await dbHelper.deleteAllDataForResume(resumeId);
    _showSnackBar('Resume data deleted successfully.');
    _loadResumeIds();
  }

  Future<void> _regeneratePdfForResume(int resumeId) async {
    final dbHelper = DatabaseHelper.instance;
    final pdfService = PdfService();

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
          final pdfData = await pdfService.createResume(templateName, resumeId);
          await File(filePath).writeAsBytes(pdfData);
        } catch (e) {
          _showSnackBar(
            'Failed to update ${resumeInfo['fileName']}: $e',
            isError: true,
          );
        }
      }
      _showSnackBar('Saved resume(s) updated successfully!');
    }
  }

  void _changeTemplate(int resumeId) async {
    bool changesMade = false;
    final dbHelper = DatabaseHelper.instance;
    final savedResumes = await dbHelper.queryAllRows(
      DatabaseHelper.tableSavedResumes,
      where: 'resumeId = ?',
      whereArgs: [resumeId],
      orderBy: 'createdAt DESC',
      limit: 1,
    );

    if (savedResumes.isNotEmpty && mounted) {
      final resumeInfo = savedResumes.first;
      final result = await Navigator.of(context).push(
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
      if (result == true) {
        changesMade = true;
      }
    } else if (mounted) {
      final result = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ChooseTemplate(resumeId: resumeId),
        ),
      );
      if (result == true) {
        changesMade = true;
      }
    }

    if (mounted && changesMade) {
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
          resumeId: _expandedResumeIds.first,
          initialPage: pageIndex,
          singlePageMode: true,
        ),
      ),
    );

    if (result == true && _expandedResumeIds.isNotEmpty && mounted) {
      _loadDataForResume(_expandedResumeIds.first);
      _regeneratePdfForResume(_expandedResumeIds.first);
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
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                ),
              ),
              trailing: IconButton(
                icon: Icon(
                  Icons.edit_rounded,
                  color: Colors.white.withOpacity(0.8),
                ),
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
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
            trailing: IconButton(
              icon: Icon(
                Icons.edit_rounded,
                color: Colors.white.withOpacity(0.8),
              ),
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
          key: PageStorageKey('${_expandedResumeIds.first}_$title'),
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
