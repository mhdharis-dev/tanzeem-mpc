import 'package:cloud_firestore/cloud_firestore.dart';

class CeremonialEventModel {
  final String eventId;
  final String madrasaId;
  final String programName;
  final String programType; // Opening or Ending
  final int durationMinutes;
  final String personName;
  final String personDesignation; // e.g. MLA, Panchayath President
  final String position; // Starting or Ending
  final String createdAt;

  CeremonialEventModel({
    required this.eventId,
    required this.madrasaId,
    required this.programName,
    required this.programType,
    required this.durationMinutes,
    required this.personName,
    required this.personDesignation,
    required this.position,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'eventId': eventId,
      'madrasaId': madrasaId,
      'programName': programName,
      'programType': programType,
      'durationMinutes': durationMinutes,
      'personName': personName,
      'personDesignation': personDesignation,
      'position': position,
      'createdAt': createdAt,
    };
  }

  factory CeremonialEventModel.fromMap(Map<String, dynamic> map) {
    return CeremonialEventModel(
      eventId: map['eventId'] ?? '',
      madrasaId: map['madrasaId'] ?? '',
      programName: map['programName'] ?? '',
      programType: map['programType'] ?? '',
      durationMinutes: (map['durationMinutes'] as num?)?.toInt() ?? 15,
      personName: map['personName'] ?? '',
      personDesignation: map['personDesignation'] ?? '',
      position: map['position'] ?? 'Starting',
      createdAt: map['createdAt'] ?? '',
    );
  }

  factory CeremonialEventModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return CeremonialEventModel.fromMap(data);
  }
}
