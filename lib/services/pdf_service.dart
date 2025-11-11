import 'dart:typed_data';
import 'package:resume_builder/Template/normal_template.dart';
import 'package:resume_builder/Template/professional_template.dart';
import 'package:resume_builder/Template/unique_template.dart';
import 'package:resume_builder/models/resume_model.dart';
import 'package:resume_builder/services/database_helper.dart';
import 'package:resume_builder/Template/classic_template.dart';
import 'package:resume_builder/Template/modern_template.dart';

class PdfService {
  final dbHelper = DatabaseHelper.instance;

  Future<Uint8List> createResume(String templateName, int resumeId) async {
    // Fetch all data from the database and map it to model classes.
    final profileRows = await dbHelper.queryAllRows(
      DatabaseHelper.tableProfile,
      where: 'resumeId = ?', whereArgs: [resumeId],
    );
    final aboutRows = await dbHelper.queryAllRows(DatabaseHelper.tableAbout, where: 'resumeId = ?', whereArgs: [resumeId]);

    final educationList = (await dbHelper.queryAllRows(
      DatabaseHelper.tableEducation,
      where: 'resumeId = ?', whereArgs: [resumeId]
    )).map((row) => Education.fromMap(row)).toList();
    final experienceList = (await dbHelper.queryAllRows(
      DatabaseHelper.tableExperience,
      where: 'resumeId = ?', whereArgs: [resumeId]
    )).map((row) => Experience.fromMap(row)).toList();
    final skillsList = (await dbHelper.queryAllRows(
      DatabaseHelper.tableSkills,
      where: 'resumeId = ?', whereArgs: [resumeId]
    )).map((row) => Skill.fromMap(row)).toList();
    final projectsList = (await dbHelper.queryAllRows(
      DatabaseHelper.tableProjects,
      where: 'resumeId = ?', whereArgs: [resumeId]
    )).map((row) => Project.fromMap(row)).toList();
    final awardsList = (await dbHelper.queryAllRows(DatabaseHelper.tableAwards, where: 'resumeId = ?', whereArgs: [resumeId]))
        .map((row) => Award.fromMap(row))
        .toList();
    final languagesList = (await dbHelper.queryAllRows(DatabaseHelper.tableLanguages, where: 'resumeId = ?', whereArgs: [resumeId]))
 .map((row) => Language.fromMap(row)).toList();
    final hobbiesList = (await dbHelper.queryAllRows(DatabaseHelper.tableHobbies, where: 'resumeId = ?', whereArgs: [resumeId]))
        .map((row) => Hobby.fromMap(row)).toList();
    final referencesList = (await dbHelper.queryAllRows(DatabaseHelper.tableAppReferences, where: 'resumeId = ?', whereArgs: [resumeId])).map((row) => AppReference.fromMap(row)).toList();

    // Safely create model instances for single-row tables.
    final profileData = profileRows.isNotEmpty
        ? Profile.fromMap(profileRows.first)
        : null;
    final aboutData = aboutRows.isNotEmpty
        ? About.fromMap(aboutRows.first)
        : null;

    // Route to the correct template generation method.
    if (templateName == 'Classic') {
      final classicTemplate = ClassicTemplate();
      return classicTemplate.create(
        profileData: profileData,
        aboutData: aboutData,
        educationList: educationList,
        experienceList: experienceList,
        skillsList: skillsList,
        awardsList: awardsList,
        projectsList: projectsList,
        languagesList: languagesList,
        hobbiesList: hobbiesList,
        referencesList: referencesList,
      );
    } else if (templateName == 'Modern') {
      final modernTemplate = ModernTemplate();
      return modernTemplate.create(
        profileData: profileData,
        aboutData: aboutData,
        educationList: educationList,
        experienceList: experienceList,
        skillsList: skillsList,
        awardsList: awardsList,
        projectsList: projectsList,
        languagesList: languagesList,
        hobbiesList: hobbiesList,
        referencesList: referencesList,
      );
    } else if (templateName == 'Unique') {
      final uniqueTemplate = UniqueTemplate();

      return uniqueTemplate.create(
        profileData: profileData,
        aboutData: aboutData,
        educationList: educationList,
        experienceList: experienceList,
        skillsList: skillsList,
        projectsList: projectsList,
        awardsList: awardsList,
        languagesList: languagesList,
        hobbiesList: hobbiesList,
        referencesList: referencesList,
      );
    } else if (templateName == 'Professional') {
      final profTemplate = ProfessionalTemplate();

      return profTemplate.create(
        profileData: profileData,
        aboutData: aboutData,
        educationList: educationList,
        experienceList: experienceList,
        skillsList: skillsList,
        projectsList: projectsList,
        awardsList: awardsList,
        languagesList: languagesList,
        hobbiesList: hobbiesList,
        referencesList: referencesList,
      );
    } else if(templateName == 'Normal'){
      final normalTemplate = NormalTemplate();
      return normalTemplate.create(
        profileData: profileData,
        aboutData: aboutData,
        educationList: educationList,
        experienceList: experienceList,
        skillsList: skillsList,
        projectsList: projectsList,
        awardsList: awardsList,
        languagesList: languagesList,
        hobbiesList: hobbiesList,
        referencesList: referencesList,
      );
    }else {
      throw Exception('Unknown template name: $templateName');
    }
  }
}
