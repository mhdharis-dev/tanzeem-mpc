import 'package:cloud_firestore/cloud_firestore.dart';

class PresentStudentModel {
  final String participantId;
  final String name;
  final int presentCount;
  final String currentClass;
  final String currentDiv;
  int rank;

  PresentStudentModel({
    required this.participantId,
    required this.name,
    required this.presentCount,
    required this.currentClass,
    required this.currentDiv,
    this.rank = 1,
  });

  factory PresentStudentModel.fromMap(Map<String, dynamic> map) {
    return PresentStudentModel(
      participantId: map['participantId'] ?? '',
      name: map['name'] ?? '',
      presentCount: map['presentCount'] ?? 0,
      currentClass: map['currentClass'] ?? '',
      currentDiv: map['currentDiv'] ?? 'A',
      rank: map['rank'] ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'participantId': participantId,
      'name': name,
      'presentCount': presentCount,
      'currentClass': currentClass,
      'currentDiv': currentDiv,
      'rank': rank,
    };
  }
}

class PresentModel {
  final String docId; // e.g. "Class 5_A"
  final String studentClass; // e.g. "Class 5"
  final String division; // e.g. "A"
  final int totalStudents;
  final int maxWorkingDays;
  final List<PresentStudentModel> students;

  PresentModel({
    required this.docId,
    required this.studentClass,
    required this.division,
    required this.totalStudents,
    required this.maxWorkingDays,
    required this.students,
  });

  factory PresentModel.fromMap(Map<String, dynamic> map, {String id = ''}) {
    final rawStudents = map['students'] as List<dynamic>? ?? [];
    final studentList = rawStudents
        .map((s) => PresentStudentModel.fromMap(Map<String, dynamic>.from(s)))
        .toList();

    // Calculate Tied Ranks (Same presentCount = Same rank)
    calculateTiedRanks(studentList);

    return PresentModel(
      docId: id.isNotEmpty ? id : (map['docId'] ?? ''),
      studentClass: map['studentClass'] ?? '',
      division: map['division'] ?? 'A',
      totalStudents: map['totalStudents'] ?? studentList.length,
      maxWorkingDays: map['maxWorkingDays'] ?? 200,
      students: studentList,
    );
  }

  factory PresentModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return PresentModel.fromMap(data, id: doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'docId': docId,
      'studentClass': studentClass,
      'division': division,
      'totalStudents': totalStudents,
      'maxWorkingDays': maxWorkingDays,
      'students': students.map((s) => s.toMap()).toList(),
    };
  }

  /// Calculates tied ranks: If multiple students have the exact same number of present days,
  /// they receive the SAME rank!
  static void calculateTiedRanks(List<PresentStudentModel> studentList) {
    studentList.sort((a, b) => b.presentCount.compareTo(a.presentCount));

    if (studentList.isEmpty) return;

    int currentRank = 1;
    studentList[0].rank = 1;

    for (int i = 1; i < studentList.length; i++) {
      if (studentList[i].presentCount == studentList[i - 1].presentCount) {
        studentList[i].rank = studentList[i - 1].rank;
      } else {
        currentRank = i + 1;
        studentList[i].rank = currentRank;
      }
    }
  }
}
