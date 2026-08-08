import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';

class CustomBreakItem {
  final String id;
  final String title;
  final int durationMinutes;
  final TimeOfDay breakTime;

  CustomBreakItem({
    required this.id,
    required this.title,
    required this.durationMinutes,
    required this.breakTime,
  });
}

class ScheduleGenerator {
  static int _getCategoryRank(String categoryOrClass) {
    final cat = categoryOrClass.trim().toLowerCase();
    if (cat.contains('primary')) return 1;
    if (cat.contains('sub-junior') || cat.contains('sub junior')) return 2;
    if (cat.contains('junior')) return 3;
    if (cat.contains('senior') && !cat.contains('super')) return 4;
    if (cat.contains('super senior') || cat.contains('super')) return 5;
    if (cat.contains('alumni')) return 6;
    return 7;
  }

  static List<ScheduleSlot> generateSchedule({
    required List<Program> programs,
    required TimeOfDay startTime,
    required TimeOfDay dhuhrTime,
    required TimeOfDay asrTime,
    required int breakDurationMins,
    required int dhuhrDurationMins,
    List<CustomBreakItem> customBreaks = const [],
    int fallbackDurationMins = 12,
    int stageBufferSecs = 60,
    int participantGapMins = 20,
    bool autoShiftOnCancel = true,
  }) {
    List<ScheduleSlot> slots = [];

    // Filter programs if autoShiftOnCancel is set
    List<Program> activePrograms = autoShiftOnCancel
        ? programs.where((p) => p.status != ProgramStatus.cancelled).toList()
        : List.from(programs);

    // Separate into Opening Ceremonial, Regular Programs, and Closing Ceremonial
    List<Program> openingEvents = [];
    List<Program> regularPrograms = [];
    List<Program> closingEvents = [];

    for (var p in activePrograms) {
      final isOpening = p.category.toLowerCase().contains('opening') ||
          p.studentClass.toLowerCase().contains('opening') ||
          p.number == 'OPENING';
      final isClosing = p.category.toLowerCase().contains('closing') ||
          p.studentClass.toLowerCase().contains('closing') ||
          p.number == 'CLOSING';

      if (isOpening) {
        openingEvents.add(p);
      } else if (isClosing) {
        closingEvents.add(p);
      } else {
        regularPrograms.add(p);
      }
    }

    // Common Scheduling Order for regular programs: Primary -> Sub-Junior -> Junior -> Senior -> Super Senior -> Alumni
    regularPrograms.sort((a, b) {
      int rankA = _getCategoryRank(a.category.isNotEmpty ? a.category : a.studentClass);
      int rankB = _getCategoryRank(b.category.isNotEmpty ? b.category : b.studentClass);
      if (rankA != rankB) return rankA.compareTo(rankB);
      return 0;
    });

    List<Program> sortedPrograms = [...openingEvents, ...regularPrograms, ...closingEvents];

    DateTime now = DateTime.now();
    DateTime current = DateTime(now.year, now.month, now.day, startTime.hour, startTime.minute);

    final timeFormat = DateFormat('hh:mm a');
    int slotIndex = 1;

    for (var i = 0; i < sortedPrograms.length; i++) {
      var prog = sortedPrograms[i];

      // Check user-added custom breaks
      for (var custom in customBreaks) {
        DateTime customDt = DateTime(now.year, now.month, now.day, custom.breakTime.hour, custom.breakTime.minute);
        if (current.isAfter(customDt.subtract(const Duration(minutes: 5))) &&
            !slots.any((s) => s.id == custom.id)) {
          DateTime breakEnd = current.add(Duration(minutes: custom.durationMinutes));
          slots.add(ScheduleSlot(
            id: custom.id,
            type: SlotType.breakSlot,
            title: custom.title,
            startTime: timeFormat.format(current),
            endTime: timeFormat.format(breakEnd),
          ));
          current = breakEnd;
        }
      }

      // Program slot duration with fallback handling
      final duration = prog.durationMinutes > 0 ? prog.durationMinutes : fallbackDurationMins;
      DateTime progEnd = current.add(Duration(minutes: duration));
      String startStr = timeFormat.format(current);
      String endStr = timeFormat.format(progEnd);

      prog.startTime = startStr;

      slots.add(ScheduleSlot(
        id: 'slot-$slotIndex-${prog.id}',
        type: SlotType.program,
        title: '${prog.number}: ${prog.item}',
        startTime: startStr,
        endTime: endStr,
        program: prog,
      ));

      // Advance current time with stage buffer offset
      current = progEnd.add(Duration(seconds: stageBufferSecs));
      slotIndex++;
    }

    return slots;
  }
}
