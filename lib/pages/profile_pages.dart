import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:resume_builder/services/database_helper.dart';
import 'package:resume_builder/services/func.dart';

class profilepage extends StatefulWidget {
  final VoidCallback? onNext;
  const profilepage({super.key, this.onNext});

  @override
  State<profilepage> createState() => _profilepageState();
}

class _profilepageState extends State<profilepage> {
  final form_Key = GlobalKey<FormState>();

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController jobTitleController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();
  final TextEditingController linkedinController = TextEditingController();
  final TextEditingController githubController = TextEditingController();
  final int pageindex = 0;
  
  bool showAdditionalFields = false;
  final dbHelper = DatabaseHelper.instance;
  final TextInputType? keyboardType = null;
  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  void _loadProfileData() async {
    final allRows = await dbHelper.queryAllRows(DatabaseHelper.tableProfile);
    if (allRows.isNotEmpty) {
      if (mounted) {
        final profile = allRows.first;
        setState(() {
          firstNameController.text = profile['firstName'] ?? '';
          lastNameController.text = profile['lastName'] ?? '';
          jobTitleController.text = profile['jobTitle'] ?? '';
          emailController.text = profile['email'] ?? '';
          phoneController.text = profile['phone'] ?? '';
          countryController.text = profile['country'] ?? '';
          cityController.text = profile['city'] ?? '';
          addressController.text = profile['address'] ?? '';
          pincodeController.text = profile['pincode'] ?? '';
          linkedinController.text = profile['linkedin'] ?? '';
          githubController.text = profile['github'] ?? '';
        });
      }
    }
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    jobTitleController.dispose();
    emailController.dispose();
    phoneController.dispose();
    countryController.dispose();
    cityController.dispose();
    addressController.dispose();
    pincodeController.dispose();
    linkedinController.dispose();
    githubController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
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
                    'Profile',
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
                  'Add your up-to-date contact information so employers and recruiters can easily reach you.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 15,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                ClipRRect(
                  borderRadius: BorderRadius.circular(36),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 32,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(36),
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
                            _buildTextField(
                              'First Name',
                              firstNameController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your first name';
                                }
                                return null;
                              },
                              keyboardType: TextInputType.text,
                            ),
                            const SizedBox(height: 12),
                            _buildTextField(
                              'Last Name',
                              lastNameController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your last name';
                                }
                                return null;
                              },
                              keyboardType: TextInputType.text,
                            ),
                            const SizedBox(height: 12),
                            _buildTextField(
                              'Job Title',
                              jobTitleController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your job title';
                                }
                                return null;
                              },
                              keyboardType: TextInputType.text,
                            ),
                            const SizedBox(height: 12),
                            _buildTextField(
                              'Email',
                              emailController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                }
                                final emailRegex = RegExp(
                                  r'^[^@]+@[^@]+\.[^@]+',
                                );
                                if (!emailRegex.hasMatch(value)) {
                                  return 'Enter a valid email';
                                }
                                return null;
                              },
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 12),
                            _buildTextField(
                              'Phone Number',
                              phoneController,
                              keyboardType: TextInputType.phone,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your phone number';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 18),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  showAdditionalFields = !showAdditionalFields;
                                });
                              },
                              child: Row(
                                children: [
                                  Container(
                                    alignment: Alignment.bottomLeft,
                                    child: Text(
                                      'Additional Information',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  AnimatedRotation(
                                    duration: const Duration(milliseconds: 600),
                                    turns: showAdditionalFields ? 0.5 : 0.0,
                                    child: Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color: Colors.white.withOpacity(0.8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ClipRect(
                              child: AnimatedSize(
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeInOut,
                                child: showAdditionalFields
                                    ? Column(
                                        children: [
                                          Divider(
                                            color: Colors.white.withOpacity(
                                              0.3,
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          buildAdditionalFields(
                                            'Country',
                                            countryController,
                                            keyboardType: TextInputType.text,
                                          ),
                                          const SizedBox(height: 12),
                                          buildAdditionalFields(
                                            'City',
                                            cityController,
                                            keyboardType: TextInputType.text,
                                          ),
                                          const SizedBox(height: 12),
                                          buildAdditionalFields(
                                            'Address',
                                            addressController,
                                            keyboardType: TextInputType.text,
                                          ),
                                          const SizedBox(height: 12),
                                          buildAdditionalFields(
                                            'Pincode',
                                            pincodeController,
                                            keyboardType: TextInputType.number,
                                          ),
                                          const SizedBox(height: 12),
                                          buildAdditionalFields(
                                            'Linkdin',
                                            linkedinController,
                                            keyboardType: TextInputType.url,
                                          ),
                                          const SizedBox(height: 12),
                                          buildAdditionalFields(
                                            'Github',
                                            githubController,
                                            keyboardType: TextInputType.url,
                                          ),
                                          const SizedBox(height: 10),
                                        ],
                                      )
                                    : SizedBox.shrink(),
                              ),
                            ),
                            SizedBox(height: 20),
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
      floatingActionButton: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: ElevatedButton(
          onPressed: () {
            if (form_Key.currentState?.validate() ?? false) {
              _saveProfileData();
             bool next = func.unlockpage(pageindex);
              
              if(next && widget.onNext != null){
                widget.onNext?.call();// Navigate to next page
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Please fill all required fields correctly.'),
                ),
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

  void _saveProfileData() async {
    Map<String, dynamic> row = {
      'firstName': firstNameController.text,
      'lastName': lastNameController.text,
      'jobTitle': jobTitleController.text,
      'email': emailController.text,
      'phone': phoneController.text,
      'country': countryController.text,
      'city': cityController.text,
      'address': addressController.text,
      'pincode': pincodeController.text,
      'linkedin': linkedinController.text,
      'github': githubController.text,
    };

    final allRows = await dbHelper.queryAllRows(DatabaseHelper.tableProfile);
    if (allRows.isEmpty) {
      await dbHelper.insert(DatabaseHelper.tableProfile, row);
    } else {
      // There should only be one profile, so we update it.
      row['id'] = allRows.first['id'];
      await dbHelper.update(DatabaseHelper.tableProfile, row);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile data saved successfully!')),
      );
    }
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    String? Function(String?)? validator,
    required TextInputType keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: ' $label',
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
        ),
      ),
      style: const TextStyle(color: Colors.white),
    );
  }

  Widget buildAdditionalFields(
    String label,
    TextEditingController controller, {
    required TextInputType keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: ' $label',
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
        ),
      ),
      style: const TextStyle(color: Colors.white),
    );
  }
}
