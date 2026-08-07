export 'madrasa_model.dart';
import 'madrasa_model.dart';
export 'participant_model.dart';
export 'program_model.dart';
export 'present_model.dart';
export 'mark_model.dart';
export 'ceremonial_event_model.dart';
export 'team_model.dart';

enum ProgramStatus { pending, live, completed, cancelled }

enum SlotType { program, prayer, breakSlot, lunch }

class Program {
  final String id;
  final String number;
  final String studentName;
  final String studentPhoto;
  final String studentClass; // Sub-Junior, Junior, Senior, Super Senior
  final String category; // Qira'at, Na'at, Speech, Group Song, Quiz, Calligraphy
  final String item;
  final int durationMinutes;
  final String stage; // Stage A, Stage B, Stage C
  ProgramStatus status;
  String startTime;
  final String teacher;
  final String remarks;
  final String priority; // High, Normal, Low
  final String colorTag; // Hex color code or name

  Program({
    required this.id,
    required this.number,
    required this.studentName,
    required this.studentPhoto,
    required this.studentClass,
    required this.category,
    required this.item,
    required this.durationMinutes,
    required this.stage,
    this.status = ProgramStatus.pending,
    required this.startTime,
    required this.teacher,
    this.remarks = '',
    this.priority = 'Normal',
    this.colorTag = '#0F766E',
  });

  Program copyWith({
    String? id,
    String? number,
    String? studentName,
    String? studentPhoto,
    String? studentClass,
    String? category,
    String? item,
    int? durationMinutes,
    String? stage,
    ProgramStatus? status,
    String? startTime,
    String? teacher,
    String? remarks,
    String? priority,
    String? colorTag,
  }) {
    return Program(
      id: id ?? this.id,
      number: number ?? this.number,
      studentName: studentName ?? this.studentName,
      studentPhoto: studentPhoto ?? this.studentPhoto,
      studentClass: studentClass ?? this.studentClass,
      category: category ?? this.category,
      item: item ?? this.item,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      stage: stage ?? this.stage,
      status: status ?? this.status,
      startTime: startTime ?? this.startTime,
      teacher: teacher ?? this.teacher,
      remarks: remarks ?? this.remarks,
      priority: priority ?? this.priority,
      colorTag: colorTag ?? this.colorTag,
    );
  }
}

class Participant {
  final String id;
  final String name;
  final String photoUrl;
  final String studentClass;
  final String category;
  final String item;
  final String teacher;
  final String madrasaName;
  final String status;

  Participant({
    required this.id,
    required this.name,
    required this.photoUrl,
    required this.studentClass,
    required this.category,
    required this.item,
    required this.teacher,
    required this.madrasaName,
    required this.status,
  });
}

typedef Madrasa = MadrasaModel;

class ScheduleSlot {
  final String id;
  final SlotType type;
  final String title;
  final String startTime;
  final String endTime;
  final Program? program;

  ScheduleSlot({
    required this.id,
    required this.type,
    required this.title,
    required this.startTime,
    required this.endTime,
    this.program,
  });
}

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final String timestamp;
  final String type; // upcoming, live, update, participant
  bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.type,
    this.isRead = false,
  });
}
