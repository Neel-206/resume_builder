import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:resume_builder/pages/aboutme.dart';
import 'package:resume_builder/pages/award_page.dart';
import 'package:resume_builder/pages/choose_template.dart';
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
  final int initialPage;
  final bool singlePageMode;
  const CreateResume({
    super.key,
    this.resumeId,
    this.originalFilePath,
    this.initialPage = 0,
    this.singlePageMode = false,
  });

  @override
  State<CreateResume> createState() => _CreateResumeState();
}

class _CreateResumeState extends State<CreateResume> {
  late int currentStep;
  late final PageController pageController;
  final dbHelper = DatabaseHelper.instance;
  late int _resumeId;

  @override
  void initState() {
    super.initState();
    currentStep = widget.initialPage;
    pageController = PageController(initialPage: widget.initialPage);
    _resumeId = widget.resumeId ?? DateTime.now().millisecondsSinceEpoch;
    _checkFilledPages();
  }

  void _checkFilledPages() async {
    final profile = await dbHelper.queryAllRows(
      DatabaseHelper.tableProfile,
      where: 'resumeId = ?',
      whereArgs: [_resumeId],
      orderBy: 'id',
    );
    final awards = await dbHelper.queryAllRows(
      DatabaseHelper.tableAwards,
      where: 'resumeId = ?',
      whereArgs: [_resumeId],
      orderBy: 'id',
    );
    final about = await dbHelper.queryAllRows(
      DatabaseHelper.tableAbout,
      where: 'resumeId = ?',
      whereArgs: [_resumeId],
      orderBy: 'id',
    );
    final education = await dbHelper.queryAllRows(
      DatabaseHelper.tableEducation,
      where: 'resumeId = ?',
      whereArgs: [_resumeId],
      orderBy: 'id',
    );
    final hobbies = await dbHelper.queryAllRows(
      DatabaseHelper.tableHobbies,
      where: 'resumeId = ?',
      whereArgs: [_resumeId],
      orderBy: 'id',
    );
    final languages = await dbHelper.queryAllRows(
      DatabaseHelper.tableLanguages,
      where: 'resumeId = ?',
      whereArgs: [_resumeId],
      orderBy: 'id',
    );
    final projects = await dbHelper.queryAllRows(
      DatabaseHelper.tableProjects,
      where: 'resumeId = ?',
      whereArgs: [_resumeId],
      orderBy: 'id',
    );
    final references = await dbHelper.queryAllRows(
      DatabaseHelper.tableAppReferences,
      where: 'resumeId = ?',
      whereArgs: [_resumeId],
      orderBy: 'id',
    );
    final experience = await dbHelper.queryAllRows(
      DatabaseHelper.tableExperience,
      where: 'resumeId = ?',
      whereArgs: [_resumeId],
      orderBy: 'id',
    );

    if (profile.isNotEmpty) {
      func.unlockpage(0);
      func.unlockpage(1);
    }
    if (about.isNotEmpty) {
      func.unlockpage(2);
      func.unlockpage(3);
    }
    if (education.isNotEmpty) {
      func.unlockpage(4);
    }
    if (hobbies.isNotEmpty) {
      func.unlockpage(5);
      func.unlockpage(6);
    }
    if (languages.isNotEmpty) {
      func.unlockpage(7);
      func.unlockpage(8);
    }

    if (profile.isNotEmpty &&
        about.isNotEmpty &&
        education.isNotEmpty &&
        hobbies.isNotEmpty &&
        languages.isNotEmpty) {
      func.unlockpage(9);
    }

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

  @override
  void dispose() {
    tabScrollController.dispose();
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff5f56ee), Color(0xffe4d8fd), Color(0xff9b8fff)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(top: screenHeight * 0.015),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Text(
                'BUILD RESUME',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: screenWidth * 0.08,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: screenWidth * 0.35,
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

              if (!widget.singlePageMode)
                Container(
                  height: 72,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                  ), // ✅ Reduced outer padding
                  child: SingleChildScrollView(
                    controller: tabScrollController,
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: List.generate(tabs.length, (i) {
                        final selected = currentStep == i;

                       
                        Widget tabInnerContent = Row(
                          mainAxisSize: MainAxisSize.min, 
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              tabs[i].icon,
                              color: func.index >= i
                                  ? selected
                                        ? Colors.white
                                        : Colors.white70
                                  : Colors.white10,
                              size: 22, 
                            ),
                            const SizedBox(width: 4), 
                            Flexible(
                              child: Text(
                                tabs[i].label,
                                style: TextStyle(
                                  color: func.index >= i
                                      ? selected
                                            ? Colors.white
                                            : Colors.white70
                                      : Colors.white10,
                                  fontWeight: selected
                                      ? FontWeight.w700
                                      : FontWeight.w600,
                                  fontSize: 18,
                                  letterSpacing:
                                      0.2, 
                                ),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        );

                        Widget tabContent;

                        if (selected) {
                          tabContent = Container(
                            margin: const EdgeInsets.only(
                              right: 12,
                            ), 
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                
                                LiquidGlassLayer(
                                  settings: LiquidGlassSettings(
                                    thickness: 28,
                                    lightAngle: 45,
                                    lightIntensity: 2.0,
                                    ambientStrength: 0.9,
                                    saturation: 1.3,
                                    visibility: 1.0,
                                  ),
                                  child: LiquidGlass(
                                    shape: LiquidRoundedSuperellipse(
                                      borderRadius: 18,
                                    ),
                                    glassContainsChild: false,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(18),
                                      child: Container(
                                        width: 200,
                                        height: 58, 
                                        decoration: BoxDecoration(
                                          color: Colors.transparent,
                                          borderRadius: BorderRadius.circular(
                                            18,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                // Content layer
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(18),
                                  child: Container(
                                    width: 200,
                                    height: 58,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 18,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    child: tabInnerContent,
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else {
                          tabContent = Container(
                            margin: const EdgeInsets.only(right: 12),
                            width: 200,
                            height: 58,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 12,
                            ),
                            child: tabInnerContent,
                          );
                        }

                        return GestureDetector(
                          key: tabKeys[i],
                          behavior: HitTestBehavior.opaque,
                          onTap: func.index >= i
                              ? () {
                                  setState(() => currentStep = i);
                                  animateToTab(i);
                                  pageController.animateToPage(
                                    i,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                }
                              : null,
                          child: SizedBox(
                            width: 200,
                            height: 58,
                            child: tabContent,
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              Expanded(
                child: GestureDetector(
                  onHorizontalDragEnd: widget.singlePageMode
                      ? null
                      : (DragEndDetails details) {
                          final velocity = details.primaryVelocity ?? 0;
                          if (velocity < 0) {
                            final target = currentStep + 1;
                            final isAwardsPage = currentStep == 1;
                            final isProjectsPage = currentStep == 6;
                            final isReferencesPage = currentStep == 7;
                            final isExperiencePage = currentStep == 8;
                            final isOptionalPage =
                                isAwardsPage ||
                                isProjectsPage ||
                                isReferencesPage ||
                                isExperiencePage;

                            if (target < tabs.length &&
                                (func.index >= target || isOptionalPage)) {
                              pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                              if (isOptionalPage && func.index < target) {
                                func.unlockpage(currentStep);
                                func.unlockpage(target);
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Please complete the current section before proceeding',
                                  ),
                                ),
                              );
                            }
                          }

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
                            singlePageMode: widget.singlePageMode,
                            onNext: () {
                              if (widget.singlePageMode) {
                                Navigator.of(context).pop(true);
                              } else {
                                pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              }
                            },
                          );
                        case 1:
                          return awardpage(
                            resumeId: _resumeId,
                            singlePageMode: widget.singlePageMode,
                            onNext: () {
                              if (widget.singlePageMode) {
                                Navigator.of(context).pop(true);
                              } else {
                                pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              }
                            },
                          );
                        case 2:
                          return Aboutme(
                            resumeId: _resumeId,
                            singlePageMode: widget.singlePageMode,
                            onNext: () {
                              if (widget.singlePageMode) {
                                Navigator.of(context).pop(true);
                              } else {
                                pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              }
                            },
                          );
                        case 3:
                          return Education(
                            resumeId: _resumeId,
                            singlePageMode: widget.singlePageMode,
                            onNext: () {
                              if (widget.singlePageMode) {
                                Navigator.of(context).pop(true);
                              } else {
                                pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              }
                            },
                          );
                        case 4:
                          return Hobbies(
                            resumeId: _resumeId,
                            singlePageMode: widget.singlePageMode,
                            onNext: () {
                              if (widget.singlePageMode) {
                                Navigator.of(context).pop(true);
                              } else {
                                pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              }
                            },
                          );
                        case 5:
                          return Languages(
                            resumeId: _resumeId,
                            singlePageMode: widget.singlePageMode,
                            onNext: () {
                              if (widget.singlePageMode) {
                                Navigator.of(context).pop(true);
                              } else {
                                pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              }
                            },
                          );
                        case 6:
                          return Projects(
                            resumeId: _resumeId,
                            singlePageMode: widget.singlePageMode,
                            onNext: () {
                              if (widget.singlePageMode) {
                                Navigator.of(context).pop(true);
                              } else {
                                pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              }
                            },
                          );
                        case 7:
                          return References(
                            resumeId: _resumeId,
                            singlePageMode: widget.singlePageMode,
                            onNext: () {
                              if (widget.singlePageMode) {
                                Navigator.of(context).pop(true);
                              } else {
                                pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              }
                            },
                          );
                        case 8:
                          return Experience(
                            resumeId: _resumeId,
                            singlePageMode: widget.singlePageMode,
                            onNext: () {
                              if (widget.singlePageMode) {
                                Navigator.of(context).pop(true);
                              } else {
                                pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              }
                            },
                          );
                        case 9:
                          return Skills(
                            resumeId: _resumeId,
                            originalFilePath: widget.originalFilePath,
                            singlePageMode: widget.singlePageMode,
                            onNext: () {
                              if (widget.singlePageMode) {
                                Navigator.of(context).pop(true);
                              } else {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ChooseTemplate(resumeId: _resumeId),
                                  ),
                                );
                                Navigator.of(context).pop(true);
                              }
                            },
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
      ),
    );
  }
}
