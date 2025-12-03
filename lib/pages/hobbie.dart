import 'dart:ui';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

import 'package:resume_builder/services/database_helper.dart';
import 'package:resume_builder/services/func.dart';

class Hobbies extends StatefulWidget {
  final VoidCallback? onNext;
  final int resumeId;
  final bool singlePageMode;

  const Hobbies({
    super.key,
    this.onNext,
    required this.resumeId,
    this.singlePageMode = false,
  });

  @override
  State<Hobbies> createState() => _HobbiesState();
}

class _HobbiesState extends State<Hobbies> {
  final List<Map<String, dynamic>> hobbiesList = [];
  final dbHelper = DatabaseHelper.instance;
  final List<String> hobbieOptions = [
    'None',
    'Art',
    'Blogging',
    'Cooking',
    'Dancing',
    'Film',
    'Marketing',
    'Music',
    'Painting',
    'Photography',
    'Reading',
    'Research',
    'Singing',
    'Sport',
    'Travel',
    'Video Game',
    'Writing',
    'Yoga',
    'Coding',
  ];
  String? selectedHobby;
  final int pageindex = 4;
  bool isDropdownOpen = false;

  @override
  void initState() {
    super.initState();
    selectedHobby = hobbieOptions[0];
    _loadHobbies();
  }

  void _loadHobbies() async {
    final allRows = await dbHelper.queryAllRows(
      DatabaseHelper.tableHobbies,
      where: 'resumeId = ?',
      whereArgs: [widget.resumeId],
    );
    if (mounted) {
      setState(() {
        hobbiesList
          ..clear()
          ..addAll(allRows);
      });
    }
  }

  void _addHobby() async {
    if (selectedHobby != null &&
        selectedHobby != 'None' &&
        !hobbiesList.any((h) => h['name'] == selectedHobby)) {
      Map<String, dynamic> row = {
        'name': selectedHobby,
        'resumeId': widget.resumeId,
      };
      final id = await dbHelper.insert(DatabaseHelper.tableHobbies, row);
      row['id'] = id;
      setState(() {
        hobbiesList.add(row);
        selectedHobby = 'None';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hobby added successfully!')),
        );
      }
    }
  }

  void _deleteHobby(int id, int index) async {
    await dbHelper.delete(DatabaseHelper.tableHobbies, id);
    setState(() {
      hobbiesList.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(color: Colors.transparent),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 85),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    alignment: Alignment.center,
                    child: const Text(
                      'Hobbies',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Choose personal interests that reflect your passions and enrich your lifestyle.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 15,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 32,
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
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isDropdownOpen 
                                            ? Colors.white.withOpacity(0.9) 
                                            : Colors.white.withOpacity(0.3),
                                        width: isDropdownOpen ? 1.5 : 1.0,
                                      ),
                                      // color: isDropdownOpen 
                                      //     ? Colors.white.withOpacity(0.1) 
                                      //     : Colors.transparent,
                                      // boxShadow: isDropdownOpen 
                                      //   ? [
                                      //       BoxShadow(
                                      //         color: Colors.white.withOpacity(0.2),
                                      //         blurRadius: 15,
                                      //         spreadRadius: 1,
                                      //       )
                                      //     ] 
                                      //   : [],
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton2<String>(
                                        isExpanded: true,
                                        hint: Text(
                                          'Select Hobbies',
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.8),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        value: selectedHobby,
                                        items: hobbieOptions.asMap().entries.map((entry) {
                                          int index = entry.key;
                                          String item = entry.value;

                                          return DropdownMenuItem<String>(
                                            value: item,
                                            child: TweenAnimationBuilder<double>(
                                              tween: Tween<double>(begin: 0.0, end: 1.0),
                                              duration: Duration(milliseconds: 350 + (index * 40)),
                                              curve: Curves.easeOutBack, 
                                              builder: (context, value, child) {
                                                return Opacity(
                                                  // FIX: .clamp(0.0, 1.0) prevents crash when easeOutBack overshoots > 1.0
                                                  opacity: value.clamp(0.0, 1.0), 
                                                  child: Transform.translate(
                                                    offset: Offset(0, -10 * (1 - value)),
                                                    child: child,
                                                  ),
                                                );
                                              },
                                              child: Text(
                                                item,
                                                style: TextStyle(
                                                  color: Colors.white.withOpacity(0.95),
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 14,
                                                  letterSpacing: 0.3,
                                                ),
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                   
                                        onChanged: (val) =>
                                            setState(() => selectedHobby = val),
                                        onMenuStateChange: (isOpen) {
                                          setState(() {
                                            isDropdownOpen = isOpen;
                                          });
                                        },
                                        iconStyleData: IconStyleData(
                                          icon: AnimatedRotation(
                                            turns: isDropdownOpen ? 0.5 : 0.0,
                                            duration: const Duration(milliseconds: 260),
                                            curve: Curves.easeOutCubic,
                                            child: const Icon(
                                              Icons.keyboard_arrow_down_rounded,
                                              color: Colors.white,
                                              size: 22,
                                            ),
                                          ),
                                        ),
                                        dropdownStyleData: DropdownStyleData(
                                          maxHeight: 260,
                                          elevation: 0,
                                          offset: const Offset(0, 6),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(18),
                                            gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                Colors.white.withOpacity(0.25),
                                                Colors.white.withOpacity(0.08),
                                              ],
                                            ),
                                            border: Border.all(
                                              color: Colors.white.withOpacity(0.35),
                                              width: 1,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.deepPurple.withOpacity(0.25),
                                                blurRadius: 24,
                                                offset: const Offset(0, 12),
                                              ),
                                            ],
                                          ),
                                          scrollbarTheme: ScrollbarThemeData(
                                            thickness: MaterialStateProperty.all(3),
                                            radius: const Radius.circular(3),
                                            thumbColor: MaterialStateProperty.all<Color>(
                                              const Color.fromARGB(108, 255, 255, 255),
                                            ),
                                          ),
                                        ),
                                        menuItemStyleData: MenuItemStyleData(
                                          height: 48,
                                          padding: const EdgeInsets.symmetric(horizontal: 18),
                                          overlayColor: MaterialStateProperty.resolveWith<Color?>(
                                            (states) {
                                              if (states.contains(MaterialState.hovered)) {
                                                return Colors.white.withOpacity(0.10);
                                              }
                                              if (states.contains(MaterialState.pressed)) {
                                                return Colors.white.withOpacity(0.15);
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (hobbiesList.isNotEmpty) ...[
                              Text(
                                'Added Hobbies',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 10),
                              ...hobbiesList.asMap().entries.map((entry) {
                                final index = entry.key;
                                final hobbie1 = entry.value;

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              hobbie1['name'],
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.close,
                                          color: Colors.white70,
                                        ),
                                        onPressed: () {
                                          _deleteHobby(hobbie1['id'], index);
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () async {
                  func.unlockpage(pageindex);

                  if (widget.singlePageMode) {
                    if (widget.onNext != null) {
                      widget.onNext!();
                    } else {
                      Navigator.of(context).pop(true);
                    }
                  } else if (widget.onNext != null) {
                    widget.onNext!.call();
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 62),
                  backgroundColor: const Color.fromARGB(255, 111, 101, 247),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 26,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(56),
                  ),
                  elevation: 8,
                  shadowColor: Colors.deepPurpleAccent.withOpacity(0.6),
                  textStyle: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                child: Text(widget.singlePageMode ? 'Save' : 'Next'),
              ),
            ),
            const SizedBox(width: 12),
            Container(
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
                        onTap: _addHobby,
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
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}