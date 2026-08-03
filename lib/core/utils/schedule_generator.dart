import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';

class ScheduleGenerator {
  static List<ScheduleSlot> generateSchedule({
    required List<Program> programs,
    required TimeOfDay startTime,
    required TimeOfDay dhuhrTime,
    required TimeOfDay asrTime,
    required int breakDurationMins,
    required int dhuhrDurationMins,
  }) {
    List<ScheduleSlot> slots = [];
    
    DateTime now = DateTime.now();
    DateTime current = DateTime(now.year, now.month, now.day, startTime.hour, startTime.minute);
    
    final timeFormat = DateFormat('hh:mm a');
    int slotIndex = 1;

    for (var i = 0; i < programs.length; i++) {
      var prog = programs[i];
      
      // Check if Dhuhr prayer time reached
      DateTime dhuhrDt = DateTime(now.year, now.month, now.day, dhuhrTime.hour, dhuhrTime.minute);
      if (current.isAfter(dhuhrDt.subtract(const Duration(minutes: 5))) && 
          !slots.any((s) => s.type == SlotType.prayer && s.title.contains('Dhuhr'))) {
        DateTime prayerEnd = current.add(Duration(minutes: dhuhrDurationMins));
        slots.add(ScheduleSlot(
          id: 'slot-prayer-dhuhr',
          type: SlotType.prayer,
          title: '🕌 Dhuhr Prayer & Lunch Break',
          startTime: timeFormat.format(current),
          endTime: timeFormat.format(prayerEnd),
        ));
        current = prayerEnd;
      }

      // Check if Asr prayer time reached
      DateTime asrDt = DateTime(now.year, now.month, now.day, asrTime.hour, asrTime.minute);
      if (current.isAfter(asrDt.subtract(const Duration(minutes: 5))) && 
          !slots.any((s) => s.type == SlotType.prayer && s.title.contains('Asr'))) {
        DateTime prayerEnd = current.add(const Duration(minutes: 30));
        slots.add(ScheduleSlot(
          id: 'slot-prayer-asr',
          type: SlotType.prayer,
          title: '🕌 Asr Prayer Break',
          startTime: timeFormat.format(current),
          endTime: timeFormat.format(prayerEnd),
        ));
        current = prayerEnd;
      }

      // Program slot
      DateTime progEnd = current.add(Duration(minutes: prog.durationMinutes));
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
      
      current = progEnd;
      slotIndex++;

      // Insert short tea break after every 3 programs if not right next to prayer
      if (i > 0 && i % 3 == 0 && i != programs.length - 1) {
        DateTime breakEnd = current.add(Duration(minutes: breakDurationMins));
        slots.add(ScheduleSlot(
          id: 'slot-break-$i',
          type: SlotType.breakSlot,
          title: '☕ Short Tea Break',
          startTime: timeFormat.format(current),
          endTime: timeFormat.format(breakEnd),
        ));
        current = breakEnd;
      }
    }

    return slots;
  }
}
