import 'package:cloud_firestore/cloud_firestore.dart';

class MarkSubjectModel {
  final String subjectName;
  final int maxMark;
  final int studentMark;

  MarkSubjectModel({
    required this.subjectName,
    this.maxMark = 50,
    required this.studentMark,
  });

  factory MarkSubjectModel.fromMap(Map<String, dynamic> map) {
    return MarkSubjectModel(
      subjectName: map['subjectName'] ?? '',
      maxMark: map['maxMark'] ?? 50,
      studentMark: map['studentMark'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'subjectName': subjectName,
      'maxMark': maxMark,
      'studentMark': studentMark,
    };
  }
}

class MarkStudentModel {
  final String participantId;
  final String name;
  final String currentClass;
  final String currentDiv;
  int rank;
  final List<MarkSubjectModel> subjects;

  MarkStudentModel({
    required this.participantId,
    required this.name,
    required this.currentClass,
    required this.currentDiv,
    this.rank = 1,
    required this.subjects,
  });

  int get totalMarks {
    int sum = 0;
    for (var s in subjects) {
      sum += s.studentMark;
    }
    return sum;
  }

  int get maxTotalMarks {
    int sum = 0;
    for (var s in subjects) {
      sum += s.maxMark;
    }
    return sum > 0 ? sum : 100;
  }

  String get grade {
    final maxM = maxTotalMarks;
    if (maxM <= 0) return 'C';
    final pct = (totalMarks / maxM * 100);
    if (pct >= 90) return 'A+';
    if (pct >= 80) return 'A';
    if (pct >= 70) return 'B+';
    if (pct >= 60) return 'B';
    return 'C';
  }

  factory MarkStudentModel.fromMap(Map<String, dynamic> map) {
    final rawSubjects = map['subjects'] as List<dynamic>? ?? [];
    final subjectList = rawSubjects
        .map((sub) => MarkSubjectModel.fromMap(Map<String, dynamic>.from(sub)))
        .toList();

    return MarkStudentModel(
      participantId: map['participantId'] ?? '',
      name: map['name'] ?? '',
      currentClass: map['currentClass'] ?? '',
      currentDiv: map['currentDiv'] ?? 'A',
      rank: map['rank'] ?? 1,
      subjects: subjectList,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'participantId': participantId,
      'name': name,
      'currentClass': currentClass,
      'currentDiv': currentDiv,
      'rank': rank,
      'subjects': subjects.map((s) => s.toMap()).toList(),
    };
  }
}

class MarkModel {
  final String docId; // e.g. "Class 5_A"
  final String studentClass; // e.g. "Class 5"
  final String division; // e.g. "A"
  final int totalStudents;
  final List<MarkStudentModel> students;

  MarkModel({
    required this.docId,
    required this.studentClass,
    required this.division,
    required this.totalStudents,
    required this.students,
  });

  int get maxTotalMarks {
    if (students.isNotEmpty) {
      return students.first.maxTotalMarks;
    }
    return 100;
  }

  factory MarkModel.fromMap(Map<String, dynamic> map, {String id = ''}) {
    final rawStudents = map['students'] as List<dynamic>? ?? [];
    final studentList = rawStudents
        .map((s) => MarkStudentModel.fromMap(Map<String, dynamic>.from(s)))
        .toList();

    // Calculate Tied Ranks (Same totalMarks = Same rank)
    calculateTiedRanks(studentList);

    return MarkModel(
      docId: id.isNotEmpty ? id : (map['docId'] ?? ''),
      studentClass: map['studentClass'] ?? map['class'] ?? '',
      division: map['division'] ?? map['div'] ?? 'A',
      totalStudents: map['totalStudents'] ?? studentList.length,
      students: studentList,
    );
  }

  factory MarkModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return MarkModel.fromMap(data, id: doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'docId': docId,
      'studentClass': studentClass,
      'division': division,
      'totalStudents': totalStudents,
      'students': students.map((s) => s.toMap()).toList(),
    };
  }

  /// Calculates tied ranks: If multiple students have the exact same total marks,
  /// they receive the SAME rank!
  static void calculateTiedRanks(List<MarkStudentModel> studentList) {
    studentList.sort((a, b) => b.totalMarks.compareTo(a.totalMarks));

    if (studentList.isEmpty) return;

    int currentRank = 1;
    studentList[0].rank = 1;

    for (int i = 1; i < studentList.length; i++) {
      if (studentList[i].totalMarks == studentList[i - 1].totalMarks) {
        studentList[i].rank = studentList[i - 1].rank;
      } else {
        currentRank = i + 1;
        studentList[i].rank = currentRank;
      }
    }
  }
}
