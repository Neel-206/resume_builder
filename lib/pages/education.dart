import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:resume_builder/services/func.dart';
import 'package:resume_builder/widgets/app_text_field.dart';
import 'package:resume_builder/services/database_helper.dart';

class Education extends StatefulWidget {
  final VoidCallback? onNext;

  const Education({super.key, this.onNext});

  @override
  State<Education> createState() => _EducationState();
}

class _EducationState extends State<Education> {
  final TextEditingController schoolController = TextEditingController();
  final TextEditingController fieldController = TextEditingController();
  final TextEditingController degreeController = TextEditingController();
  final TextEditingController placeController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController fromController = TextEditingController();
  final TextEditingController toController = TextEditingController();
  final TextEditingController discriptionController = TextEditingController();
  final TextEditingController marksController = TextEditingController();
  final List<Map<String, dynamic>> educationList = [];
  final dbHelper = DatabaseHelper.instance;
  final form_Key = GlobalKey<FormState>();
  final int pageindex = 3;
  @override
  void initState() {
    super.initState();
    _loadEducation();
  }

  void _loadEducation() async {
    final allRows = await dbHelper.queryAllRows(DatabaseHelper.tableEducation);
    if (mounted) {
      setState(() {
        educationList.clear();
        educationList.addAll(allRows);
      });
    }
  }

  void _addEducation() async {
    if (schoolController.text.trim().isNotEmpty ||
        fieldController.text.trim().isNotEmpty ||
        degreeController.text.trim().isNotEmpty ||
        placeController.text.trim().isNotEmpty ||
        countryController.text.trim().isNotEmpty ||
        fromController.text.trim().isNotEmpty ||
        toController.text.trim().isNotEmpty ||
        discriptionController.text.trim().isNotEmpty ||
        marksController.text.trim().isNotEmpty) {
      Map<String, dynamic> row = {
        'school': schoolController.text.trim(),
        'field': fieldController.text.trim(),
        'degree': degreeController.text.trim(),
        'place': placeController.text.trim(),
        'country': countryController.text.trim(),
        'fromYear': fromController.text.trim(),
        'toYear': toController.text.trim(),
        'description': discriptionController.text.trim(),
        'marks': marksController.text.trim(),
      };
      final id = await dbHelper.insert(DatabaseHelper.tableEducation, row);
      row['id'] = id;
      setState(() {
        educationList.add(row);
        schoolController.clear();
        fieldController.clear();
        degreeController.clear();
        placeController.clear();
        countryController.clear();
        fromController.clear();
        toController.clear();
        discriptionController.clear();
        marksController.clear();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Education added successfully!')),
        );
      }
    }
  }

  void _deleteEducation(int id, int index) async {
    await dbHelper.delete(DatabaseHelper.tableEducation, id);
    setState(() {
      educationList.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(color: Colors.transparent),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 85),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    alignment: Alignment.center,
                    child: const Text(
                      'Education',
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
                    'Fill in your educational achievements and institution names in the designated area.',
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
                        child: Form(
                          key: form_Key,
                          child: Column(
                            children: [
                              AppTextField(
                                label: 'School/Collage Name',
                                controller: schoolController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter School/Collage Name';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: AppTextField(
                                      label: 'Field of Study',
                                      controller: fieldController,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter Field of Study';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: AppTextField(
                                      label: 'Degree',
                                      controller: degreeController,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter Degree';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: AppTextField(
                                      label: 'Place',
                                      controller: placeController,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter Place where you studied';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: AppTextField(
                                      label: 'Country',
                                      controller: countryController,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter Country where you studied';
                                        }
                                        return null;
                                      },
                                    ),
                          
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: AppTextField(
                                      label: 'From Year',
                                      controller: fromController,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter From Year';
                                        }
                                        return null;
                                      },
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: AppTextField(
                                      label: 'To Year',
                                      controller: toController,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter To Year';
                                        }
                                        return null;
                                      },  
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              AppTextField(
                                label: 'Description',
                                controller: discriptionController,
                                maxLines: 3,
                              ),
                              const SizedBox(height: 12),
                              AppTextField(
                                label: 'Marks(%)',
                                controller: marksController,
                                keyboardType: TextInputType.number,
                              ),
                              const SizedBox(height: 12),
                              if (educationList.isNotEmpty) ...[
                                Text(
                                  'Added Education',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                ...educationList.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final Edu = entry.value;
                          
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
                                                Edu['school'] ?? '',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                Edu['field'] ?? '',
                                                style: TextStyle(
                                                  color: Colors.white.withOpacity(
                                                    0.7,
                                                  ),
                                                  fontSize: 14,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                Edu['degree'] ?? '',
                                                style: TextStyle(
                                                  color: Colors.white.withOpacity(
                                                    0.7,
                                                  ),
                                                  fontSize: 14,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                Edu['place'] ?? '',
                                                style: TextStyle(
                                                  color: Colors.white.withOpacity(
                                                    0.7,
                                                  ),
                                                  fontSize: 14,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                Edu['country'] ?? '',
                                                style: TextStyle(
                                                  color: Colors.white.withOpacity(
                                                    0.7,
                                                  ),
                                                  fontSize: 14,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                Edu['fromYear'] ?? '',
                                                style: TextStyle(
                                                  color: Colors.white.withOpacity(
                                                    0.7,
                                                  ),
                                                  fontSize: 14,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                Edu['toYear'] ?? '',
                                                style: TextStyle(
                                                  color: Colors.white.withOpacity(
                                                    0.7,
                                                  ),
                                                  fontSize: 14,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                Edu['description'] ?? '',
                                                style: TextStyle(
                                                  color: Colors.white.withOpacity(
                                                    0.7,
                                                  ),
                                                  fontSize: 14,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                Edu['marks'] ?? '',
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
                                            _deleteEducation(Edu['id'], index);
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
                  if(educationList.isNotEmpty) {
                     bool next = func.unlockpage(pageindex);
                     if(next && widget.onNext != null){
                        widget.onNext?.call();// Navigate to next page
                     }
                  }else{
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text('Please add at least one education entry.'),
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
                        onTap: (){
                          if(form_Key.currentState?.validate() ?? false) {
                            _addEducation();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Please fill required fields correctly.'),
                              ),
                            );
                          }
                        },
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
