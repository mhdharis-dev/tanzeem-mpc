import 'package:cloud_firestore/cloud_firestore.dart';

class ProgramModel {
  final String programId; // e.g. "PRG-001"
  final String participantName;
  final String participantId;
  final String studentClass;
  final String division;
  final String category;
  final String programName; // e.g. "Speech", "Song", "Qira'at"
  final String programType; // "single", "group", "other"
  final String startTime; // e.g. "10:45:20"
  final String endTime; // e.g. "10:46:10"
  final String duration; // e.g. "50 sec", "1m 30s", "10 mins"
  final String status; // "pending", "live", "completed", "canceled"
  final int order;
  final String madrasaId;
  final String createdAt;

  ProgramModel({
    required this.programId,
    required this.participantName,
    required this.participantId,
    required this.studentClass,
    required this.division,
    required this.category,
    required this.programName,
    required this.programType,
    this.startTime = 'TBD',
    this.endTime = 'TBD',
    required this.duration,
    this.status = 'pending',
    required this.order,
    required this.madrasaId,
    required this.createdAt,
  });

  factory ProgramModel.fromMap(Map<String, dynamic> map) {
    String durStr = '10 mins';
    if (map['duration'] != null) {
      if (map['duration'] is int) {
        durStr = '${map['duration']} mins';
      } else {
        durStr = map['duration'].toString();
      }
    }

    return ProgramModel(
      programId: map['programId'] ?? '',
      participantName: map['participantName'] ?? '',
      participantId: map['participantId'] ?? '',
      studentClass: map['studentClass'] ?? '',
      division: map['division'] ?? 'A',
      category: map['category'] ?? '',
      programName: map['programName'] ?? '',
      programType: map['programType'] ?? 'single',
      startTime: map['startTime'] ?? 'TBD',
      endTime: map['endTime'] ?? 'TBD',
      duration: durStr,
      status: map['status'] ?? 'pending',
      order: (map['order'] is int)
          ? map['order']
          : int.tryParse(map['order']?.toString() ?? '1') ?? 1,
      madrasaId: map['madrasaId'] ?? '',
      createdAt: map['createdAt'] ?? '',
    );
  }

  factory ProgramModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ProgramModel.fromMap({
      ...data,
      'programId': doc.id,
    });
  }

  Map<String, dynamic> toMap() {
    return {
      'programId': programId,
      'participantName': participantName,
      'participantId': participantId,
      'studentClass': studentClass,
      'division': division,
      'category': category,
      'programName': programName,
      'programType': programType,
      'startTime': startTime,
      'endTime': endTime,
      'duration': duration,
      'status': status,
      'order': order,
      'madrasaId': madrasaId,
      'createdAt': createdAt,
    };
  }

  static String generateNextProgramId(int currentLength) {
    final count = currentLength + 1;
    final formattedNumber = count.toString().padLeft(3, '0');
    return 'PRG-$formattedNumber';
  }

  static String formatSecondsToDuration(int totalSeconds) {
    if (totalSeconds < 60) {
      return '$totalSeconds sec';
    }
    final minutes = totalSeconds ~/ 60;
    final remainingSeconds = totalSeconds % 60;
    if (minutes < 60) {
      if (remainingSeconds == 0) {
        return '$minutes min';
      }
      return '${minutes}m ${remainingSeconds}s';
    }
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    if (remainingMinutes == 0) {
      return '${hours}h';
    }
    return '${hours}h ${remainingMinutes}m';
  }
}
