import 'package:cloud_firestore/cloud_firestore.dart';
import 'models.dart';

class ParticipantModel {
  final String participantId; // e.g. "PATC-001"
  final String name;
  final String studentClass; // e.g. "Class 5"
  final String gender; // e.g. "Male" or "Female"
  final String division; // e.g. "A"
  final String category; // e.g. "Junior"
  final String parentName;
  final String phoneNo;
  final String madrasaId; // e.g. "7020@tanzeem"
  final String createdAt; // e.g. "2026-08-03 18:07"

  ParticipantModel({
    required this.participantId,
    required this.name,
    required this.studentClass,
    required this.gender,
    required this.division,
    required this.category,
    required this.parentName,
    required this.phoneNo,
    required this.madrasaId,
    required this.createdAt,
  });

  factory ParticipantModel.fromMap(Map<String, dynamic> map) {
    return ParticipantModel(
      participantId: map['participantId'] ?? '',
      name: map['name'] ?? '',
      studentClass: map['studentClass'] ?? '',
      gender: map['gender'] ?? 'Male',
      division: map['division'] ?? 'A',
      category: map['category'] ?? '',
      parentName: map['parentName'] ?? '',
      phoneNo: map['phoneNo'] ?? '',
      madrasaId: map['madrasaId'] ?? '',
      createdAt: map['createdAt'] ?? '',
    );
  }

  factory ParticipantModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ParticipantModel.fromMap({
      ...data,
      'participantId': doc.id,
    });
  }

  Map<String, dynamic> toMap() {
    return {
      'participantId': participantId,
      'name': name,
      'studentClass': studentClass,
      'gender': gender,
      'division': division,
      'category': category,
      'parentName': parentName,
      'phoneNo': phoneNo,
      'madrasaId': madrasaId,
      'createdAt': createdAt,
    };
  }

  Participant toParticipant() {
    return Participant(
      id: participantId,
      name: name,
      photoUrl: 'https://i.pravatar.cc/150?u=$participantId',
      studentClass: studentClass,
      category: category,
      item: 'Competition Item',
      teacher: parentName.isNotEmpty ? parentName : 'Usthad',
      madrasaName: madrasaId,
      status: 'Active',
    );
  }

  static String generateNextParticipantId(int currentLength) {
    final count = currentLength + 1;
    final formattedNumber = count.toString().padLeft(3, '0');
    return 'PATC-$formattedNumber';
  }
}
