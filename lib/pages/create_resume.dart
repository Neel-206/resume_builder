import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:resume_builder/pages/aboutme.dart';
import 'package:resume_builder/pages/award_page.dart';
import 'package:resume_builder/pages/education.dart';
import 'package:resume_builder/services/database_helper.dart';
import 'package:resume_builder/pages/experiance.dart';
import 'package:resume_builder/pages/hobbie.dart';
import 'package:resume_builder/pages/language.dart';
import 'package:resume_builder/pages/profile_pages.dart';
import 'package:resume_builder/pages/projects.dart';
import 'package:resume_builder/pages/references.dart';
import 'package:resume_builder/pages/skills.dart';
import 'package:resume_builder/services/func.dart';

class TabItem {
  final IconData icon;
  final String label;
  const TabItem({required this.icon, required this.label});
}

class CreateResume extends StatefulWidget {
  final int? resumeId;
  final String? originalFilePath;
  const CreateResume({super.key, this.resumeId, this.originalFilePath});

  @override
  State<CreateResume> createState() => _CreateResumeState();
}

class _CreateResumeState extends State<CreateResume> {
  int currentStep = 0;
  final PageController pageController = PageController();
  final dbHelper = DatabaseHelper.instance;
  late int _resumeId;

  @override
  void initState() {
    super.initState();
    _resumeId = widget.resumeId ?? DateTime.now().millisecondsSinceEpoch;
    _checkFilledPages();
  }

  void _checkFilledPages() async {
    // Check each page's data and unlock if filled
    final profile = await dbHelper.queryAllRows(DatabaseHelper.tableProfile, where: 'resumeId = ?', whereArgs: [_resumeId]);
    final awards = await dbHelper.queryAllRows(DatabaseHelper.tableAwards, where: 'resumeId = ?', whereArgs: [_resumeId]);
    final about = await dbHelper.queryAllRows(DatabaseHelper.tableAbout, where: 'resumeId = ?', whereArgs: [_resumeId]);
    final education = await dbHelper.queryAllRows(DatabaseHelper.tableEducation, where: 'resumeId = ?', whereArgs: [_resumeId]);
    final hobbies = await dbHelper.queryAllRows(DatabaseHelper.tableHobbies, where: 'resumeId = ?', whereArgs: [_resumeId]);
    final languages = await dbHelper.queryAllRows(DatabaseHelper.tableLanguages, where: 'resumeId = ?', whereArgs: [_resumeId]);
    final projects = await dbHelper.queryAllRows(DatabaseHelper.tableProjects, where: 'resumeId = ?', whereArgs: [_resumeId]);
    final references = await dbHelper.queryAllRows(DatabaseHelper.tableAppReferences, where: 'resumeId = ?', whereArgs: [_resumeId]);
    final experience = await dbHelper.queryAllRows(DatabaseHelper.tableExperience, where: 'resumeId = ?', whereArgs: [_resumeId]);
    final skills = await dbHelper.queryAllRows(DatabaseHelper.tableSkills, where: 'resumeId = ?', whereArgs: [_resumeId]);

    // Update func.index based on filled pages
    if (profile.isNotEmpty) {
      func.unlockpage(0);  // Profile
      func.unlockpage(1);  // Always unlock Awards (optional)
    }
    if (about.isNotEmpty) {
      func.unlockpage(2);    // About
      func.unlockpage(3);    // Education
    }
    if (education.isNotEmpty) {
      func.unlockpage(4);    // Hobbies
    }
    if (hobbies.isNotEmpty) {
      func.unlockpage(5);    // Languages
      func.unlockpage(6);    // Always unlock Projects (optional)
    }
    if (languages.isNotEmpty) {
      func.unlockpage(7);    // Always unlock References (optional)
      func.unlockpage(8);    // Always unlock Experience (optional)
    }
    
    // These are the required pages that need to be filled
    if (profile.isNotEmpty && about.isNotEmpty && education.isNotEmpty && 
        hobbies.isNotEmpty && languages.isNotEmpty) {
      func.unlockpage(9);    // Skills
    }
    
    // Also unlock if any optional pages are filled
    if (awards.isNotEmpty) func.unlockpage(2);
    if (projects.isNotEmpty) func.unlockpage(7);
    if (references.isNotEmpty) func.unlockpage(8);
    if (experience.isNotEmpty) func.unlockpage(9);

    if (mounted) setState(() {});
  }

  final List<TabItem> tabs = const [
    TabItem(icon: Icons.account_box_rounded, label: 'Profile'),
    TabItem(icon: Icons.emoji_events_outlined, label: 'Awards'),
    TabItem(icon: Icons.info_outline, label: 'About me'),
    TabItem(icon: Icons.school_outlined, label: 'Education'),
    TabItem(icon: Icons.emoji_emotions_outlined, label: 'Hobbies'),
    TabItem(icon: Icons.language_outlined, label: 'Languages'),
    TabItem(icon: Icons.checklist_outlined, label: 'Projects'),
    TabItem(icon: Icons.book_outlined, label: 'References'),
    TabItem(icon: Icons.work_outline, label: 'Experience'),
    TabItem(icon: Icons.code_outlined, label: 'Skills'),
  ];
  final ScrollController tabScrollController = ScrollController();
  final List<GlobalKey> tabKeys = List.generate(11, (index) => GlobalKey());

  void animateToTab(int i) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final context = tabKeys[i].currentContext;
      if (context == null) return;

      final RenderBox currentTabBox = context.findRenderObject() as RenderBox;
      final Size tabSize = currentTabBox.size;
      final Offset tabPosition = currentTabBox.localToGlobal(
        Offset.zero,
        ancestor: this.context.findRenderObject(),
      );

      final double tabCenter = tabPosition.dx + tabSize.width / 2;
      final double screenWidth = MediaQuery.of(this.context).size.width;
      final double desiredOffset = tabCenter - screenWidth / 2;

      tabScrollController.animateTo(
        desiredOffset + tabScrollController.offset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  void dispose() {
    tabScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff5f56ee), Color(0xffe4d8fd), Color(0xff9b8fff)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 40),
            const Text(
              'BUILD RESUME',
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
            const SizedBox(height: 20),
            SingleChildScrollView(
              controller: tabScrollController,
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(tabs.length, (i) {
                  final selected = currentStep == i;
                  Widget tabInnerContent = Row(
                    children: [
                      Icon(
                        tabs[i].icon,
                        color: func.index >= i ? selected ? Colors.white : Colors.white70 : Colors.white10,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        tabs[i].label,
                        style: TextStyle(
                          color: func.index >= i ? selected ? Colors.white : Colors.white70 : Colors.white10,
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  );
                  Widget tabContent = Container(
                    margin: EdgeInsets.only(left: i == 0 ? 12 : 16),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    child: tabInnerContent,
                  );
                  if (selected) {
                    tabContent = ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                        child: Container(
                          margin: EdgeInsets.only(left: i == 0 ? 12 : 16),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration( 
                            color: Colors.white.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(12),
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
                          child: tabInnerContent,
                        ),
                      ),
                    );
                  }
                  return GestureDetector(
                    key: tabKeys[i],
                    onTap: func.index >= i ?  () {
                      setState(() => currentStep = i);
                      animateToTab(i);
                      if (currentStep == 1) {
                        pageController.jumpToPage(i);
                      } else {
                        pageController.animateToPage(
                          i,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    } : null,
                    child: tabContent,
                  );
                }),
              ),
            ),

            const SizedBox(height: 20),
            Expanded(
              child: GestureDetector(
                onHorizontalDragEnd: (DragEndDetails details) {
                  final velocity = details.primaryVelocity ?? 0;
                  // Negative velocity -> user swiped left (forward)
                  if (velocity < 0) {
                    final target = currentStep + 1;
                    final isAwardsPage = currentStep == 1;      // Index 1 is Awards page
                    final isProjectsPage = currentStep == 6;    // Index 6 is Projects page
                    final isReferencesPage = currentStep == 7;  // Index 7 is References page
                    final isExperiencePage = currentStep == 8;  // Index 8 is Experience page
                    final isOptionalPage = isAwardsPage || isProjectsPage || isReferencesPage || isExperiencePage;
                    
                    if (target < tabs.length && (func.index >= target || isOptionalPage)) {
                      pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                      // If skipping optional pages, unlock the next page
                      if (isOptionalPage && func.index < target) {
                        func.unlockpage(currentStep); // This will unlock the next page
                        func.unlockpage(target); // Also unlock the next page
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please complete the current section before proceeding'),
                        ),
                      );
                    }
                  }

                  // Positive velocity -> user swiped right (back)
                  if (velocity > 0) {
                    if (currentStep > 0) {
                      pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  }
                },
                child: PageView.builder(
                  // Disable the default scroll physics so our GestureDetector can
                  // control navigation and enforce validation rules.
                  physics: const NeverScrollableScrollPhysics(),
                  controller: pageController,
                  onPageChanged: (index) {
                    setState(() => currentStep = index);
                    animateToTab(index);
                  },
                  itemCount: tabs.length,
                  itemBuilder: (context, index) {
                  switch (index) {
                    case 0:
                      return profilepage(
                        resumeId: _resumeId,
                        onNext: () => pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        ),
                      );
                    case 1:
                      return awardpage(
                        resumeId: _resumeId,
                        onNext: () => pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        ),
                      );
                    case 2:
                      return Aboutme(
                        resumeId: _resumeId,
                        onNext: () => pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        ),
                      );
                    case 3:
                      return Education(
                        resumeId: _resumeId,
                        onNext: () => pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        ),
                      );
                    case 4:
                      return Hobbies(
                        resumeId: _resumeId,
                        onNext: () => pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        ),
                      );
                    case 5:
                      return Languages(
                        resumeId: _resumeId,
                        onNext: () => pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        ),
                      );
                    case 6:
                      return Projects(
                        resumeId: _resumeId,
                        onNext: () => pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        ),
                      );
                    case 7:
                      return References(
                        resumeId: _resumeId,
                        onNext: () => pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        ),
                      );
                    case 8:
                      return Experience(
                        resumeId: _resumeId,
                        onNext: () => pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        ),
                      );
                    case 9:
                      return Skills(
                        resumeId: _resumeId,
                        originalFilePath: widget.originalFilePath,
                        onNext: () => pageController.nextPage(
                          duration: const Duration(milliseconds: 300), 
                          curve: Curves.easeInOut,
                        ),
                      );
                    default:
                      return Center(child: Text('Page not found'));
                  }
                },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
