import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:resume_builder/services/func.dart';
import 'package:resume_builder/widgets/app_text_field.dart';
import 'package:resume_builder/services/database_helper.dart';

class Languages extends StatefulWidget {
  final VoidCallback? onNext;
  final int resumeId;
  const Languages({super.key, this.onNext, required this.resumeId});

  @override
  State<Languages> createState() => _LanguagesState();
}

class _LanguagesState extends State<Languages> {
  final TextEditingController languageController = TextEditingController();
  final List<Map<String, dynamic>> languagesList = [];
  final dbHelper = DatabaseHelper.instance;
  bool canRead = false;
  bool canWrite = false;
  bool canSpeak = false;
  final int pageindex = 5;
  
  @override
  void initState() {
    super.initState();
    _loadLanguages();
  }

  void _loadLanguages() async {
    final allRows = await dbHelper.queryAllRows(DatabaseHelper.tableLanguages, where: 'resumeId = ?', whereArgs: [widget.resumeId]);
    if (mounted) {
      setState(() {
        languagesList.clear();
        for (var row in allRows) {
          languagesList.add({
            'id': row['id'],
            'name': row['name'],
            'read': row['canRead'] == 1,
            'write': row['canWrite'] == 1,
            'speak': row['canSpeak'] == 1,
          });
        }
      });
    }
  }

  void addLanguage() async {
    if (languageController.text.trim().isNotEmpty) {
      Map<String, dynamic> row = {
        'name': languageController.text.trim(),
        'canRead': canRead ? 1 : 0,
        'canWrite': canWrite ? 1 : 0,
        'canSpeak': canSpeak ? 1 : 0,
 'resumeId': widget.resumeId,
      };
      final id = await dbHelper.insert(DatabaseHelper.tableLanguages, row);
      row['id'] = id;
      setState(() {
        languagesList.add(
          row
            ..['read'] = canRead
            ..['write'] = canWrite
            ..['speak'] = canSpeak,
        );
        languageController.clear();
        canRead = false;
        canWrite = false;
        canSpeak = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Language added successfully!')),
        );
      }
    }
  }

  void _deleteLanguage(int id, int index) async {
    await dbHelper.delete(DatabaseHelper.tableLanguages, id);
    setState(() {
      languagesList.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(color: Colors.transparent),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    alignment: Alignment.center,
                    child: const Text(
                      'Language',
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
                    'Specify languages you understand, articulate, and write clearly and effectively in.',
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
                            Container(
                              child: Column(
                                children: [
                                  AppTextField(
                                    label: 'Language',
                                    controller: languageController,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Row(
                                          children: [
                                            Checkbox(
                                              activeColor: Colors.white54,
                                              side: BorderSide(
                                                color: Colors.white54,
                                              ),
                                              value: canRead,
                                              onChanged: (value) {
                                                setState(() {
                                                  canRead = value ?? false;
                                                });
                                              },
                                            ),
                                            Text(
                                              'Read',
                                              style: TextStyle(
                                                color: Colors.white54,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Row(
                                          children: [
                                            Checkbox(
                                              activeColor: Colors.white54,
                                              side: BorderSide(
                                                color: Colors.white54,
                                              ),
                                              value: canWrite,
                                              onChanged: (value) {
                                                setState(() {
                                                  canWrite = value ?? false;
                                                });
                                              },
                                            ),
                                            Text(
                                              'Write',
                                              style: TextStyle(
                                                color: Colors.white54,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Row(
                                          children: [
                                            Checkbox(
                                              activeColor: Colors.white54,
                                              side: BorderSide(
                                                color: Colors.white54,
                                              ),
                                              value: canSpeak,
                                              onChanged: (value) {
                                                setState(() {
                                                  canSpeak = value ?? false;
                                                });
                                              },
                                            ),
                                            Text(
                                              'Speak',
                                              style: TextStyle(
                                                color: Colors.white54,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (languagesList.isNotEmpty) ...[
                    for (var i = 0; i < languagesList.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(25),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 25,
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
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      languagesList[i]['name'],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      if (languagesList[i]['read'])
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(7),
                                          child: BackdropFilter(
                                            filter: ImageFilter.blur(
                                              sigmaX: 20,
                                              sigmaY: 20,
                                            ),
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 10,
                                                vertical: 5,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.green.withOpacity(
                                                  0.25,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(7),
                                                border: Border.all(
                                                  color: Colors.green.withOpacity(
                                                    0.3,
                                                  ),
                                                  width: 1.5,
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.lightGreen
                                                        .withOpacity(0.2),
                                                    blurRadius: 30,
                                                    offset: const Offset(0, 12),
                                                  ),
                                                ],
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Colors.green.withOpacity(1),
                                                    Colors.green.withOpacity(
                                                      0.50,
                                                    ),
                                                  ],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                              ),
                                              child: Text(
                                                'Read',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      SizedBox(width: 5),
                                      if (languagesList[i]['write'])
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(7),
                                          child: BackdropFilter(
                                            filter: ImageFilter.blur(
                                              sigmaX: 20,
                                              sigmaY: 20,
                                            ),
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 10,
                                                vertical: 5,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.lightBlue
                                                    .withOpacity(0.25),
                                                borderRadius:
                                                    BorderRadius.circular(7),
                                                border: Border.all(
                                                  color: Colors.lightBlue
                                                      .withOpacity(0.3),
                                                  width: 1.5,
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.blue
                                                        .withOpacity(0.2),
                                                    blurRadius: 30,
                                                    offset: const Offset(0, 12),
                                                  ),
                                                ],
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Colors.lightBlue.withOpacity(
                                                      1,
                                                    ),
                                                    Colors.lightBlue.withOpacity(
                                                      0.50,
                                                    ),
                                                  ],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                              ),
                                              child: Text(
                                                'write',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      SizedBox(width: 5),
                                      if (languagesList[i]['speak'])
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(7),
                                          child: BackdropFilter(
                                            filter: ImageFilter.blur(
                                              sigmaX: 20,
                                              sigmaY: 20,
                                            ),
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 10,
                                                vertical: 5,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.deepPurple
                                                    .withOpacity(0.25),
                                                borderRadius:
                                                    BorderRadius.circular(7),
                                                border: Border.all(
                                                  color: Colors.deepPurple
                                                      .withOpacity(0.3),
                                                  width: 1.5,
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.purple
                                                        .withOpacity(0.2),
                                                    blurRadius: 30,
                                                    offset: const Offset(0, 12),
                                                  ),
                                                ],
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Colors.deepPurple.withOpacity(
                                                      1,
                                                    ),
                                                    Colors.deepPurple.withOpacity(
                                                      0.50,
                                                    ),
                                                  ],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                              ),
                                              child: Text(
                                                'Speak',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      IconButton(
                                        onPressed: () {
                                          setState(() {
                                            _deleteLanguage(
                                              languagesList[i]['id'],
                                              i,
                                            );
                                          });
                                        },
                                        icon: const Icon(
                                          Icons.close_rounded,
                                          color: Colors.white70,
                                          size: 20,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                  SizedBox(height: languagesList.isNotEmpty ? 80 : 0),
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
                  if (languagesList.isNotEmpty) {
                    bool next = func.unlockpage(pageindex);

                    if (next && widget.onNext != null) {
                      widget.onNext?.call(); // Navigate to next page
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please add at least one language.'),
                      ),
                    );
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
                child: const Text('Next'),
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
                        onTap: addLanguage,
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
