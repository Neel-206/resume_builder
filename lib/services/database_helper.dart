import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static const _databaseName = "ResumeMaker.db";
  static const _databaseVersion = 6; 

  // Table names
  static const tableProfile = 'profile';
  static const tableAbout = 'about';
  static const tableAwards = 'awards';
  static const tableEducation = 'education';
  static const tableExperience = 'experience';
  static const tableHobbies = 'hobbies';
  static const tableLanguages = 'languages';
  static const tableProjects = 'projects';
  static const tableAppReferences = 'app_references';
  static const tableSkills = 'skills';
  static const tableSavedResumes = 'saved_resumes';

  // Singleton class
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Opens the database (and creates it if it doesn't exist)
  _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // A map of table creation scripts for better organization
  static final Map<String, String> _tableCreationScripts = {
    tableProfile: '''
      CREATE TABLE $tableProfile (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        resumeId INTEGER,
        firstName TEXT,
        lastName TEXT,
        email TEXT,
        phone TEXT,
        country TEXT,
        city TEXT,
        address TEXT,
        pincode TEXT,
        jobTitle TEXT
        ,linkedin TEXT,
        github TEXT
      )
    ''',
    tableAbout: '''
      CREATE TABLE $tableAbout (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        resumeId INTEGER,
        aboutText TEXT
      )
    ''',
    tableAwards: '''
      CREATE TABLE $tableAwards (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        resumeId INTEGER,
        title TEXT,
        issuer TEXT,
        year TEXT,
        month TEXT,
        description TEXT
      )
    ''',
    tableEducation: '''
      CREATE TABLE $tableEducation (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        resumeId INTEGER,
        school TEXT,
        field TEXT,
        degree TEXT,
        place TEXT,
        country TEXT,
        fromYear TEXT,
        toYear TEXT,
        description TEXT,
        marks TEXT
      )
    ''',
    tableExperience: '''
      CREATE TABLE $tableExperience (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        resumeId INTEGER,
        company TEXT,
        position TEXT,
        fromYear TEXT,
        fromMonth TEXT,
        toYear TEXT,
        toMonth TEXT,
        description TEXT
      )
    ''',
    tableHobbies: '''
      CREATE TABLE $tableHobbies (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        resumeId INTEGER,
        name TEXT NOT NULL
      )
    ''',
    tableLanguages: '''
      CREATE TABLE $tableLanguages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        resumeId INTEGER,
        name TEXT NOT NULL,
        canRead INTEGER,
        canWrite INTEGER,
        canSpeak INTEGER
      )
    ''',
    tableProjects: '''
      CREATE TABLE $tableProjects (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        resumeId INTEGER,
        name TEXT,
        role TEXT,
        description TEXT,
        technologies TEXT,
        link TEXT,
        year TEXT
      )
    ''',
    tableAppReferences: '''
      CREATE TABLE $tableAppReferences (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        resumeId INTEGER,
        name TEXT,
        relationship TEXT,
        company TEXT,
        phone TEXT,
        email TEXT
      )
    ''',
    tableSkills: '''
      CREATE TABLE $tableSkills (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        resumeId INTEGER,
        name TEXT NOT NULL,
        proficiency TEXT NOT NULL
      )
    ''',
    tableSavedResumes: '''
      CREATE TABLE $tableSavedResumes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        resumeId INTEGER,
        fileName TEXT NOT NULL,
        filePath TEXT NOT NULL,
        templateName TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''',
  };

  // SQL code to create the database tables
  Future _onCreate(Database db, int version) async {
    final batch = db.batch();
    _tableCreationScripts.forEach((key, script) {
      batch.execute(script);
    });
    await batch.commit(noResult: true);
  }

  // This is called when the database version is increased.
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Robustly check if the column exists before adding it
      var tableInfo = await db.rawQuery('PRAGMA table_info($tableProfile)');
      bool jobTitleExists = tableInfo.any((col) => col['name'] == 'jobTitle');
      
      if (!jobTitleExists) {
        await db.execute('ALTER TABLE $tableProfile ADD COLUMN jobTitle TEXT');
      }
    }
    if (oldVersion < 3) {
      // Version 3 adds linkedin and github columns.
      // A robust way is to check and add them.
      var tableInfo = await db.rawQuery('PRAGMA table_info($tableProfile)');
      bool linkedinExists = tableInfo.any((col) => col['name'] == 'linkedin');
      bool githubExists = tableInfo.any((col) => col['name'] == 'github');
      if (!linkedinExists) await db.execute('ALTER TABLE $tableProfile ADD COLUMN linkedin TEXT');
      if (!githubExists) await db.execute('ALTER TABLE $tableProfile ADD COLUMN github TEXT');
    }
    if (oldVersion < 4) {
      // Version 4 adds the saved_resumes table
      try {
        await db.execute(_tableCreationScripts[tableSavedResumes]!);
      } catch (e) {
        print('Error creating saved_resumes table: $e');
        // Table might already exist, which is fine
      }
    }
    if (oldVersion < 5) {
      // Version 5 adds resumeId to all data tables
      final tablesToUpdate = [
        tableProfile, tableAbout, tableAwards, tableEducation, tableExperience,
        tableHobbies, tableLanguages, tableProjects, tableAppReferences, tableSkills,
        tableSavedResumes
      ];
      for (final table in tablesToUpdate) {
        var tableInfo = await db.rawQuery('PRAGMA table_info($table)');
        bool resumeIdExists = tableInfo.any((col) => col['name'] == 'resumeId');
        if (!resumeIdExists) {
          await db.execute('ALTER TABLE $table ADD COLUMN resumeId INTEGER');
        }
      }
    }
    // Add other migration logic for future versions here
  }

  // Helper methods to insert, query, update, and delete.

  /// Inserts a row into the specified [table]. Returns the new row's id.
  Future<int> insert(String table, Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(table, row, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Queries all rows from the specified [table].
  Future<List<Map<String, dynamic>>> queryAllRows(String table, {String? where, List<dynamic>? whereArgs}) async {
    Database db = await instance.database;
    return await db.query(table, where: where, whereArgs: whereArgs);
  }

  /// Updates a row in the specified [table]. The map must contain an 'id' key.
  Future<int> update(String table, Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = row['id'];
    return await db.update(table, row, where: 'id = ?', whereArgs: [id]);
  }

  /// Updates a row in the specified [table] by resumeId.
  Future<int> updateByResumeId(String table, Map<String, dynamic> row, int resumeId) async {
    Database db = await instance.database;
    return await db.update(table, row, where: 'resumeId = ?', whereArgs: [resumeId]);
  }

  /// Deletes the row with the specified [id] from the [table].
  Future<int> delete(String table, int id) async {
    Database db = await instance.database;
    return await db.delete(table, where: 'id = ?', whereArgs: [id]);
  }

  /// Deletes a row by file path from the saved_resumes table
  Future<int> deleteByPath(String table, String filePath) async {
    Database db = await instance.database;
    return await db.delete(table, where: 'filePath = ?', whereArgs: [filePath]);
  }

  /// A generic method to clear all data from a table.
  Future<void> clearTable(String table) async {
    Database db = await instance.database;
    await db.delete(table);
  }
}
