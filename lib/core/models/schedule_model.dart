import 'package:cloud_firestore/cloud_firestore.dart';

class ScheduleBreakModel {
  final String title;
  final String startTime;
  final int duration;

  ScheduleBreakModel({
    required this.title,
    required this.startTime,
    required this.duration,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'startTime': startTime,
      'duration': duration,
    };
  }

  factory ScheduleBreakModel.fromMap(Map<String, dynamic> map) {
    return ScheduleBreakModel(
      title: map['title'] ?? map['name'] ?? '',
      startTime: map['startTime'] ?? '',
      duration: (map['duration'] as num?)?.toInt() ?? 15,
    );
  }
}

class ScheduleCeremonialEventModel {
  final String name;
  final String eventPosition; // 'start' or 'end'
  final int duration;
  final String person;
  final String personShortTitle;

  ScheduleCeremonialEventModel({
    required this.name,
    required this.eventPosition,
    required this.duration,
    required this.person,
    required this.personShortTitle,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'eventPosition': eventPosition,
      'duration': duration,
      'person': person,
      'personShortTitle': personShortTitle,
    };
  }

  factory ScheduleCeremonialEventModel.fromMap(Map<String, dynamic> map) {
    return ScheduleCeremonialEventModel(
      name: map['name'] ?? map['type'] ?? '',
      eventPosition: map['eventPosition'] ?? 'start',
      duration: (map['duration'] as num?)?.toInt() ?? 15,
      person: map['person'] ?? '',
      personShortTitle: map['personShortTitle'] ?? '',
    );
  }
}

class ScheduledProgramItemModel {
  final String prgName;
  final String prgId;
  final int prgOrder;
  final List<String> participantNames;
  final List<String> participantIds;
  final int order;
  final String prgType; // 'group' or 'single'
  final String startTime;
  final String endTime;
  final int durations;
  final String status;

  ScheduledProgramItemModel({
    required this.prgName,
    required this.prgId,
    required this.prgOrder,
    required this.participantNames,
    required this.participantIds,
    required this.order,
    required this.prgType,
    required this.startTime,
    required this.endTime,
    required this.durations,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'prgName': prgName,
      'prgId': prgId,
      'prgOrder': prgOrder,
      'participantNames': participantNames,
      'participantIds': participantIds,
      'order': order,
      'prgType': prgType,
      'startTime': startTime,
      'endTime': endTime,
      'durations': durations,
      'status': status,
    };
  }

  factory ScheduledProgramItemModel.fromMap(Map<String, dynamic> map) {
    return ScheduledProgramItemModel(
      prgName: map['prgName'] ?? '',
      prgId: map['prgId'] ?? '',
      prgOrder: (map['prgOrder'] as num?)?.toInt() ?? 0,
      participantNames: List<String>.from(map['participantNames'] ?? []),
      participantIds: List<String>.from(map['participantIds'] ?? []),
      order: (map['order'] as num?)?.toInt() ?? 0,
      prgType: map['prgType'] ?? 'single',
      startTime: map['startTime'] ?? '',
      endTime: map['endTime'] ?? '',
      durations: (map['durations'] as num?)?.toInt() ?? 12,
      status: map['status'] ?? 'pending',
    );
  }
}

class ScheduleModel {
  final String scheduleId;
  final String madrasaId;
  final String updatedAt;
  final bool isLocked;
  final List<ScheduleBreakModel> breaks;
  final List<ScheduleCeremonialEventModel> startAndEndPrograms;
  final List<ScheduledProgramItemModel> schedule;
  final Map<String, dynamic> rules;

  ScheduleModel({
    required this.scheduleId,
    required this.madrasaId,
    required this.updatedAt,
    required this.isLocked,
    required this.breaks,
    required this.startAndEndPrograms,
    required this.schedule,
    required this.rules,
  });

  Map<String, dynamic> toMap() {
    return {
      'scheduleId': scheduleId,
      'madrasaId': madrasaId,
      'updatedAt': updatedAt,
      'isLocked': isLocked,
      'breaks': breaks.map((b) => b.toMap()).toList(),
      'startAndEndPrograms': startAndEndPrograms.map((e) => e.toMap()).toList(),
      'schedule': schedule.map((s) => s.toMap()).toList(),
      'rules': rules,
    };
  }

  factory ScheduleModel.fromMap(Map<String, dynamic> map) {
    return ScheduleModel(
      scheduleId: map['scheduleId'] ?? 'schedule-${DateTime.now().year}',
      madrasaId: map['madrasaId'] ?? '',
      updatedAt: map['updatedAt'] ?? '',
      isLocked: map['isLocked'] ?? false,
      breaks: (map['breaks'] as List?)?.map((b) => ScheduleBreakModel.fromMap(Map<String, dynamic>.from(b))).toList() ?? [],
      startAndEndPrograms: (map['startAndEndPrograms'] as List?)?.map((e) => ScheduleCeremonialEventModel.fromMap(Map<String, dynamic>.from(e))).toList() ?? [],
      schedule: (map['schedule'] as List?)?.map((s) => ScheduledProgramItemModel.fromMap(Map<String, dynamic>.from(s))).toList() ?? [],
      rules: Map<String, dynamic>.from(map['rules'] ?? {}),
    );
  }

  factory ScheduleModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ScheduleModel.fromMap(data);
  }
}
