import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:resume_builder/services/func.dart';
import 'package:resume_builder/widgets/app_text_field.dart';
import 'package:resume_builder/services/database_helper.dart';

class Aboutme extends StatefulWidget {
  final VoidCallback? onNext;

  const Aboutme({super.key, this.onNext});

  @override
  State<Aboutme> createState() => _AboutmeState();
}

class _AboutmeState extends State<Aboutme> {
  final TextEditingController aboutController = TextEditingController();
  final form_Key = GlobalKey<FormState>();
  final dbHelper = DatabaseHelper.instance;
  int pageindex = 2;
  @override
  void initState() {
    super.initState();
    _loadAboutData();
  }

  void _loadAboutData() async {
    final allRows = await dbHelper.queryAllRows(DatabaseHelper.tableAbout);
    if (allRows.isNotEmpty) {
      setState(() {
        aboutController.text = allRows.first['aboutText'] ?? '';
      });
    }
  }

  void _saveAboutData() async {
    Map<String, dynamic> row = {
      'aboutText': aboutController.text,
    };

    final allRows = await dbHelper.queryAllRows(DatabaseHelper.tableAbout);
    if (allRows.isEmpty) {
      await dbHelper.insert(DatabaseHelper.tableAbout, row);
    } else {
      row['id'] = allRows.first['id'];
      await dbHelper.update(DatabaseHelper.tableAbout, row);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('About me saved successfully!')),
      );
    }
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
                      'About me',
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
                    'Add thoughtful narratives representing your Carrear goals, vision, and strengths clearly.',
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
                            Form(
                              key: form_Key,
                              child: AppTextField(
                                controller: aboutController,
                                label: 'About me',
                                maxLines: 5,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your About yourself';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(height: 15),
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
        child: ElevatedButton(

          onPressed: (){
            if (form_Key.currentState?.validate() ?? false) {
              _saveAboutData();
               bool next = func.unlockpage(pageindex);
              
              if(next && widget.onNext != null){
                widget.onNext?.call();// Navigate to next page
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content:Text('Please fill required fields correctly.')),
              );
            }
          },
          child: Text('Next'),
          style: ElevatedButton.styleFrom(
            minimumSize: Size(double.infinity, 62),
            backgroundColor: Color.fromARGB(255, 111, 101, 247),
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 26, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(56),
            ),
            elevation: 8,
            shadowColor: Colors.deepPurpleAccent.withOpacity(0.6),
            textStyle: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
