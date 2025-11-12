/// Model for the 'profile' table.
class Profile {
  int? id;
  String? firstName;
  String? lastName;
  String? email;
  String? phone;
  String? country;
  String? city;
  String? address;
  String? pincode;
  String? jobTitle;
  String? linkedin;
  String? github;


  Profile({
    this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.country,
    this.city,
    this.address,
    this.pincode,
    this.jobTitle,
    this.linkedin,
    this.github,
  });

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      id: map['id'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      email: map['email'],
      phone: map['phone'],
      country: map['country'],
      city: map['city'],
      address: map['address'],
      pincode: map['pincode'],
      jobTitle: map['jobTitle'],
      linkedin: map['linkedin'],
      github: map['github'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'country': country,
      'city': city,
      'address': address,
      'pincode': pincode,
      'jobTitle': jobTitle,
    };
  }
}

/// Model for the 'about' table.
class About {
  int? id;
  String? aboutText;

  About({this.id, this.aboutText});

  factory About.fromMap(Map<String, dynamic> map) {
    return About(
      id: map['id'],
      aboutText: map['aboutText'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'aboutText': aboutText,
    };
  }
}

/// Model for the 'awards' table.
class Award {
  int? id;
  String? title;
  String? issuer;
  String? year;
  String? month;
  String? description;

  Award({this.id, this.title, this.issuer, this.year, this.month, this.description});

  factory Award.fromMap(Map<String, dynamic> map) {
    return Award(
      id: map['id'],
      title: map['title'],
      issuer: map['issuer'],
      year: map['year'],
      month: map['month'],
      description: map['description'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'issuer': issuer,
      'year': year,
      'month': month,
      'description': description,
    };
  }
}

/// Model for the 'education' table.
class Education {
  int? id;
  String? school;
  String? field;
  String? degree;
  String? place;
  String? country;
  String? fromYear;
  String? toYear;
  String? description;
  String? marks;

  var resumeId;

  Education({
    this.id,
    this.school,
    this.field,
    this.degree,
    this.place,
    this.country,
    this.fromYear,
    this.toYear,
    this.description,
    this.marks,
  });

  factory Education.fromMap(Map<String, dynamic> map) {
    return Education(
      id: map['id'],
      school: map['school'],
      field: map['field'],
      degree: map['degree'],
      place: map['place'],
      country: map['country'],
      fromYear: map['fromYear'],
      toYear: map['toYear'],
      description: map['description'],
      marks: map['marks'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'school': school,
      'field': field,
      'degree': degree,
      'place': place,
      'country': country,
      'fromYear': fromYear,
      'toYear': toYear,
      'description': description,
      'marks': marks,
    };
  }
}

/// Model for the 'experience' table.
class Experience {
  int? id;
  String? company;
  String? position;
  String? fromYear;
  String? fromMonth;
  String? toYear;
  String? toMonth;
  String? description;

  var jobTitle;

  var place;

  var resumeId;

  Experience({
    this.id,
    this.company,
    this.position,
    this.fromYear,
    this.fromMonth,
    this.toYear,
    this.toMonth,
    this.description,
  });

  factory Experience.fromMap(Map<String, dynamic> map) {
    return Experience(
      id: map['id'],
      company: map['company'],
      position: map['position'],
      fromYear: map['fromYear'],
      fromMonth: map['fromMonth'],
      toYear: map['toYear'],
      toMonth: map['toMonth'],
      description: map['description'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'company': company,
      'position': position,
      'fromYear': fromYear,
      'fromMonth': fromMonth,
      'toYear': toYear,
      'toMonth': toMonth,
      'description': description,
    };
  }
}

/// Model for the 'hobbies' table.
class Hobby {
  int? id;
  String name;

  Hobby({this.id, required this.name});

  factory Hobby.fromMap(Map<String, dynamic> map) {
    return Hobby(
      id: map['id'],
      name: map['name'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }
}

/// Model for the 'languages' table.
class Language {
  int? id;
  String name;
  bool canRead;
  bool canWrite;
  bool canSpeak;

  Language({
    this.id,
    required this.name,
    this.canRead = false,
    this.canWrite = false,
    this.canSpeak = false,
  });

  factory Language.fromMap(Map<String, dynamic> map) {
    return Language(
      id: map['id'],
      name: map['name'],
      canRead: map['canRead'] == 1,
      canWrite: map['canWrite'] == 1,
      canSpeak: map['canSpeak'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'canRead': canRead ? 1 : 0,
      'canWrite': canWrite ? 1 : 0,
      'canSpeak': canSpeak ? 1 : 0,
    };
  }
}

/// Model for the 'projects' table.
class Project {
  int? id;
  String? name;
  String? role;
  String? description;
  String? technologies;
  String? link;
  String? year;

  var resumeId;

  Project({
    this.id,
    this.name,
    this.role,
    this.description,
    this.technologies,
    this.link,
    this.year,
  });

  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      id: map['id'],
      name: map['name'],
      role: map['role'],
      description: map['description'],
      technologies: map['technologies'],
      link: map['link'],
      year: map['year'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'description': description,
      'technologies': technologies,
      'link': link,
      'year': year,
    };
  }
}

/// Model for the 'app_references' table.
class AppReference {
  int? id;
  String? name;
  String? relationship;
  String? company;
  String? phone;
  String? email;

  var resumeId;

  AppReference({
    this.id,
    this.name,
    this.relationship,
    this.company,
    this.phone,
    this.email,
  });

  factory AppReference.fromMap(Map<String, dynamic> map) {
    return AppReference(
      id: map['id'],
      name: map['name'],
      relationship: map['relationship'],
      company: map['company'],
      phone: map['phone'],
      email: map['email'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'relationship': relationship,
      'company': company,
      'phone': phone,
      'email': email,
    };
  }
}

/// Model for the 'skills' table.
class Skill {
  int? id;
  String name;
  String proficiency;

  var resumeId;

  Skill({this.id, required this.name, required this.proficiency});

  factory Skill.fromMap(Map<String, dynamic> map) {
    return Skill(
      id: map['id'],
      name: map['name'],
      proficiency: map['proficiency'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'proficiency': proficiency,
    };
  }
}
