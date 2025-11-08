import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:resume_builder/services/func.dart';
import 'package:resume_builder/widgets/app_text_field.dart';
import 'package:resume_builder/services/database_helper.dart';

class References extends StatefulWidget {
  final VoidCallback? onNext;

  const References({super.key, this.onNext});

  @override
  State<References> createState() => _ReferencesState();
}

class _ReferencesState extends State<References> {
  final List<Map<String, dynamic>> referencesList = [];
  final dbHelper = DatabaseHelper.instance;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController relationshipController = TextEditingController();
  final TextEditingController companyController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final int pageindex = 7;
  @override
  void initState() {
    super.initState();
    _loadReferences();
  }

  void _loadReferences() async {
    final allRows = await dbHelper.queryAllRows(
      DatabaseHelper.tableAppReferences,
    );
    if (mounted) {
      setState(() {
        referencesList.clear();
        referencesList.addAll(allRows);
      });
    }
  }

  void _addReference() async {
    if (nameController.text.trim().isNotEmpty) {
      Map<String, dynamic> row = {
        'name': nameController.text,
        'relationship': relationshipController.text,
        'company': companyController.text,
        'phone': phoneController.text,
        'email': emailController.text,
      };
      final id = await dbHelper.insert(DatabaseHelper.tableAppReferences, row);
      row['id'] = id;
      setState(() {
        referencesList.add(row);
        nameController.clear();
        relationshipController.clear();
        companyController.clear();
        phoneController.clear();
        emailController.clear();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reference added successfully!')),
        );
      }
    }
  }

  void _deleteReference(int id, int index) async {
    await dbHelper.delete(DatabaseHelper.tableAppReferences, id);
    setState(() {
      referencesList.removeAt(index);
    });
  }

  void _saveAndNext() {
    _addReference(); // Save any pending data
    bool next = func.unlockpage(pageindex);

    if (next && widget.onNext != null) {
      widget.onNext?.call(); // Navigate to next page
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    relationshipController.dispose();
    companyController.dispose();
    phoneController.dispose();
    emailController.dispose();
    super.dispose();
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
                children: [
                  Container(
                    alignment: Alignment.center,
                    child: const Text(
                      'References',
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
                    'Provide details of your references here.',
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
                              label: 'Name',
                              controller: nameController,
                            ),
                            const SizedBox(height: 12),
                            AppTextField(
                              label: 'Relationship',
                              controller: relationshipController,
                            ),
                            const SizedBox(height: 12),
                            AppTextField(
                              label: 'Company',
                              controller: companyController,
                            ),
                            const SizedBox(height: 12),
                            AppTextField(
                              label: 'Phone',
                              controller: phoneController,
                              keyboardType: TextInputType.phone,
                            ),
                            const SizedBox(height: 12),
                            AppTextField(
                              label: 'Email',
                              controller: emailController,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 20),
                            if (referencesList.isNotEmpty) ...[
                              Text(
                                'Added References',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 12),
                              for (var i = 0; i < referencesList.length; i++)
                                Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(16),
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
                                              referencesList[i]['name'],
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              referencesList[i]['relationship'] ??
                                                  '',
                                              style: TextStyle(
                                                color: Colors.white.withOpacity(
                                                  0.7,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              referencesList[i]['company'] ??
                                                  '',
                                              style: TextStyle(
                                                color: Colors.white.withOpacity(
                                                  0.7,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              referencesList[i]['phone'] ?? '',
                                              style: TextStyle(
                                                color: Colors.white.withOpacity(
                                                  0.7,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              referencesList[i]['email'] ?? '',
                                              style: TextStyle(
                                                color: Colors.white.withOpacity(
                                                  0.7,
                                                ),
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
                                          _deleteReference(
                                            referencesList[i]['id'],
                                            i,
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
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
                  _saveAndNext();
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
                        onTap: _addReference,
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
