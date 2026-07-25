import 'dart:ui';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:resume_builder/widgets/app_text_field.dart';
import 'package:resume_builder/services/database_helper.dart';
import 'package:resume_builder/services/func.dart';

class awardpage extends StatefulWidget {
  final VoidCallback? onNext;
  final int resumeId;
  final bool singlePageMode;
  const awardpage({super.key, this.onNext, required this.resumeId, this.singlePageMode = false});

  @override
  State<awardpage> createState() => _awardpageState();
}

class _awardpageState extends State<awardpage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController issueController = TextEditingController();
  final TextEditingController yearController = TextEditingController();
  final TextEditingController discriptionController = TextEditingController();
  final List<Map<String, dynamic>> awards = [];
  final dbHelper = DatabaseHelper.instance;
  int pageindex = 1;
  final List<String> month = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  String? selectedMonth;
  bool isDropdownOpen = false;

  @override
  void initState() {
    super.initState();
    _loadAwards();
  }

  @override
  void didUpdateWidget(covariant awardpage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.resumeId != oldWidget.resumeId) {
      _clearControllersAndLists();
      _loadAwards();
    }
  }

  void _clearControllersAndLists() {
    titleController.clear();
    issueController.clear();
    yearController.clear();
    discriptionController.clear();
    awards.clear();
  }

  void _loadAwards() async {
    final allRows = await dbHelper.queryAllRows(DatabaseHelper.tableAwards, where: 'resumeId = ?', whereArgs: [widget.resumeId]);
    if (mounted) {
      setState(() {
        awards.clear();
        awards.addAll(allRows);
      });
    }
  }

  void _addAward() async {
    if (titleController.text.trim().isNotEmpty ||
        issueController.text.trim().isNotEmpty ||
        yearController.text.trim().isNotEmpty ||
        discriptionController.text.trim().isNotEmpty) {
      // Add resumeId to the row
      Map<String, dynamic> row = {
        'title': titleController.text.trim(),
        'issuer': issueController.text.trim(),
        'year': yearController.text.trim(),
        'month': selectedMonth,
        'description': discriptionController.text.trim(),
 'resumeId': widget.resumeId,
      };
      row['resumeId'] = widget.resumeId;
      final id = await dbHelper.insert(DatabaseHelper.tableAwards, row);
      row['id'] = id;
      setState(() {
        awards.add(row);
        titleController.clear();
        issueController.clear();
        yearController.clear();
        selectedMonth = null;
        discriptionController.clear();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Award added successfully!')),
        );
      }
    }
  }

  void _deleteAward(int id, int index) async {
    await dbHelper.delete(DatabaseHelper.tableAwards, id); // Assuming ID is unique enough for deletion
    setState(() {
      awards.removeAt(index);
    });
  }

    Future<void> selectYear(BuildContext context, TextEditingController controller, {bool isToYear = false}) async {
    final currentYear = DateTime.now().year;
    int? selectedYear;

    DateTime initialDate = DateTime.now();
    if (controller.text.isNotEmpty && controller.text != 'Present') {
      final parsedYear = int.tryParse(controller.text);
      if (parsedYear != null) {
        initialDate = DateTime(parsedYear);
      }
    }

    selectedYear = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Select Year"),
          content: Container(
            width: 300,
            height: 300,
            child: YearPicker(
              firstDate: DateTime(1950),
              lastDate: DateTime(currentYear + 10),
              initialDate: initialDate,
              selectedDate: initialDate,
              onChanged: (DateTime dateTime) {
                Navigator.of(context).pop(dateTime.year);
              },
            ),
          ),
          actions: <Widget>[
            if (isToYear)
              TextButton(
                child: const Text('Present'),
                onPressed: () {
                  Navigator.of(context).pop(-1); // Use -1 to signify "Present"
                },
              ),
          ],
        );
      },
    );

    if (selectedYear != null) {
      controller.text = selectedYear == -1 ? 'Present' : selectedYear.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(color: Colors.transparent),
        child: SingleChildScrollView(
          padding:  const EdgeInsets.fromLTRB(20, 20, 20, 85),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    alignment: Alignment.center,
                    child: const Text(
                      'Award',
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
                    'Add your proud achievement here to highlight your success and inspire others.',
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
                            AppTextField(
                              label: "Award Title",
                              controller: titleController,
                            ),
                            SizedBox(height: 12),
                            AppTextField(
                              label: "issuer Name",
                              controller: issueController,
                            ),
                            SizedBox(height: 12),
                            GestureDetector(
                              onTap: () => selectYear(context, yearController),
                              child: AbsorbPointer(
                                child: AppTextField(
                                  label: "Year",
                                  controller: yearController,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ),
                            SizedBox(height: 12),
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
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton2<String>(
                                        isExpanded: true,
                                        dropdownStyleData: DropdownStyleData(
                                          maxHeight: 200,
                                          elevation: 0,
                                          offset: const Offset(0, 4),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(18),
                                            gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                Colors.white.withOpacity(0.25),
                                                Colors.white.withOpacity(0.08),
                                              ],
                                            ),
                                            border: Border.all(
                                              color: Colors.white
                                                  .withOpacity(0.35),
                                              width: 1,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.deepPurple
                                                    .withOpacity(0.25),
                                                blurRadius: 24,
                                                offset: const Offset(0, 12),
                                              ),
                                            ],
                                          ),
                                          scrollbarTheme: ScrollbarThemeData(
                                            thickness:
                                                MaterialStateProperty.all(3),
                                            radius: const Radius.circular(3),
                                            thumbColor: MaterialStateProperty
                                                .all<Color>(
                                              const Color.fromARGB(
                                                  108, 255, 255, 255),
                                            ),
                                          ),
                                        ),
                                        hint: Text(
                                          'Select month',
                                          style: TextStyle(
                                            color:
                                                Colors.white.withOpacity(0.8),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        value: selectedMonth,
                                        items: month.map((m) {
                                          return DropdownMenuItem<String>(
                                            value: m,
                                            child: TweenAnimationBuilder<
                                                double>(
                                              tween: Tween(
                                                  begin: 0.0, end: 1.0),
                                              duration: Duration(
                                                  milliseconds: 350 +
                                                      (month.indexOf(m) *
                                                          40)),
                                              curve: Curves.easeOutBack,
                                              builder:
                                                  (context, value, child) {
                                                return Opacity(
                                                  opacity:
                                                      value.clamp(0.0, 1.0),
                                                  child: Transform.translate(
                                                    offset: Offset(
                                                        0, -10 * (1 - value)),
                                                    child: child,
                                                  ),
                                                );
                                              },
                                              child: Text(
                                                m,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: (val) => setState(
                                            () => selectedMonth = val),
                                        onMenuStateChange: (isOpen) {
                                          setState(() {
                                            isDropdownOpen = isOpen;
                                          });
                                        },
                                        iconStyleData: IconStyleData(
                                          icon: AnimatedRotation(
                                            turns: isDropdownOpen ? 0.5 : 0.0,
                                            duration: const Duration(
                                                milliseconds: 260),
                                            curve: Curves.easeOutCubic,
                                            child: const Icon(
                                              Icons
                                                  .keyboard_arrow_down_rounded,
                                              color: Colors.white,
                                              size: 22,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            AppTextField(
                              label: "Description",
                              controller: discriptionController,
                              maxLines: 3,
                            ),
                            SizedBox(height: 15),
                            if (awards.isNotEmpty) ...[
                              Text(
                                'Added Awards',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              ...awards.asMap().entries.map((entry) {
                                final index = entry.key;
                                final award = entry.value;

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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              award['title'] ?? '',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              award['issuer'] ?? '',
                                              style: TextStyle(
                                                color: Colors.white.withOpacity(
                                                  0.7,
                                                ),
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              award['year'] ?? '',
                                              style: TextStyle(
                                                color: Colors.white.withOpacity(
                                                  0.7,
                                                ),
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              award['month'] ?? '',
                                              style: TextStyle(
                                                color: Colors.white.withOpacity(
                                                  0.7,
                                                ),
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              award['description'] ?? '',
                                              style: TextStyle(
                                                color: Colors.white.withOpacity(
                                                  0.7,
                                                ),
                                                fontSize: 14,
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
                                          _deleteAward(award['id'], index);
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
                  if (widget.onNext != null) {
                    func.unlockpage(pageindex); // Unlock the page
                    widget.onNext?.call(); // Navigate to next page or pop
              }
                  // if (widget.onNext != null) {
                  //   widget.onNext!();
                  // }
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
                        onTap: _addAward,
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
