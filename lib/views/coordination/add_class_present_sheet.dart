// Library: add_class_present_sheet.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/models/participant_model.dart';
import '../../core/models/present_model.dart';
import '../../core/providers/app_state.dart';
import '../../core/theme/app_colors.dart';

// -----------------------------------------------------------------------------
// REDESIGNED ADD CLASS PRESENT SHEET (PREMIUM GLASS UI & QUICK INCR/DECR)
// -----------------------------------------------------------------------------
class AddClassPresentSheet extends StatefulWidget {
  final String? initialClass;
  final String? initialDiv;

  const AddClassPresentSheet({
    super.key,
    this.initialClass,
    this.initialDiv,
  });

  @override
  State<AddClassPresentSheet> createState() => _AddClassPresentSheetState();
}

class _AddClassPresentSheetState extends State<AddClassPresentSheet> {
  late String _selectedClass;
  late String _selectedDivision;
  final TextEditingController _maxWorkingDaysController = TextEditingController(text: '200');

  // Map of participantId -> present count TextEditingController
  final Map<String, TextEditingController> _presentCountControllers = {};
  final List<ParticipantModel> _extraParticipants = [];
  final Set<String> _removedStudentIds = {};
  String _studentSearchQuery = '';
  bool _showAddStudentPicker = false;
  bool _initializedClass = false;

  @override
  void initState() {
    super.initState();
    _selectedClass = (widget.initialClass != null && widget.initialClass != 'All') ? widget.initialClass! : 'Class 1';
    _selectedDivision = (widget.initialDiv != null && widget.initialDiv != 'All') ? widget.initialDiv! : 'A';
  }

  @override
  void dispose() {
    _maxWorkingDaysController.dispose();
    for (var c in _presentCountControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  /// Automatically detects and sets the lowest unmarked class on first load
  void _detectLowestUnmarkedClass(AppState appState) {
    if (_initializedClass) return;
    _initializedClass = true;

    if (widget.initialClass == null || widget.initialClass == 'All') {
      const allClasses = ['Class 1', 'Class 2', 'Class 3', 'Class 4', 'Class 5', 'Class 6', 'Class 7', 'Class 8', 'Class 9', 'Class 10', 'Class 11', 'Class 12'];
      final markedClasses = appState.presentRecords
          .where((r) => r.students.any((s) => s.presentCount > 0))
          .map((r) => r.studentClass.toLowerCase())
          .toSet();

      for (var cls in allClasses) {
        if (!markedClasses.contains(cls.toLowerCase())) {
          _selectedClass = cls;
          break;
        }
      }
    }

    _loadSavedRecordValues(appState);
  }

  /// Loads real saved values whenever class or division changes
  void _loadSavedRecordValues(AppState appState) {
    final targetDocId = '${_selectedClass}_$_selectedDivision';
    PresentModel? savedRecord;
    try {
      savedRecord = appState.presentRecords.firstWhere(
        (r) => r.docId == targetDocId || (r.studentClass == _selectedClass && r.division == _selectedDivision),
      );
    } catch (_) {}

    if (savedRecord != null) {
      _maxWorkingDaysController.text = savedRecord.maxWorkingDays.toString();

      // Get standard Class + 1 student IDs to identify extra added students
      final selectedNum = int.tryParse(_selectedClass.replaceAll(RegExp(r'[^0-9]'), '')) ?? 5;
      final rosterClassNum = selectedNum < 12 ? selectedNum + 1 : 12;
      final defaultStudentIds = appState.realParticipants.where((p) {
        final pNum = int.tryParse(p.studentClass.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        return pNum == rosterClassNum || p.studentClass.toLowerCase() == 'class $rosterClassNum'.toLowerCase();
      }).map((p) => p.participantId).toSet();

      for (var s in savedRecord.students) {
        if (_presentCountControllers.containsKey(s.participantId)) {
          _presentCountControllers[s.participantId]!.text = s.presentCount.toString();
        } else {
          _presentCountControllers[s.participantId] = TextEditingController(text: s.presentCount.toString());
        }

        if (!defaultStudentIds.contains(s.participantId)) {
          try {
            final p = appState.realParticipants.firstWhere((rp) => rp.participantId == s.participantId);
            if (!_extraParticipants.any((ep) => ep.participantId == s.participantId)) {
              _extraParticipants.add(p);
            }
          } catch (_) {
            if (!_extraParticipants.any((ep) => ep.participantId == s.participantId)) {
              _extraParticipants.add(ParticipantModel.fromMap({
                'participantId': s.participantId,
                'name': s.name,
                'studentClass': s.currentClass,
                'division': s.currentDiv,
                'category': 'General',
                'madrasaId': appState.madrasaId,
              }));
            }
          }
        }
      }
    }
  }

  String? _getStudentExistingClassPresent(String participantId, AppState appState) {
    final currentDocId = '${_selectedClass}_$_selectedDivision';
    for (var record in appState.presentRecords) {
      if (record.docId != currentDocId) {
        if (record.students.any((s) => s.participantId == participantId)) {
          return '${record.studentClass} (${record.division})';
        }
      }
    }
    return null;
  }

  TextEditingController _getCountController(String key, {String initialVal = '0'}) {
    if (!_presentCountControllers.containsKey(key)) {
      _presentCountControllers[key] = TextEditingController(text: initialVal);
    }
    return _presentCountControllers[key]!;
  }

  void _incrementDays(String participantId, int maxDays) {
    final ctrl = _getCountController(participantId);
    int current = int.tryParse(ctrl.text) ?? 0;
    if (current < maxDays) {
      setState(() {
        ctrl.text = (current + 1).toString();
      });
    }
  }

  void _decrementDays(String participantId) {
    final ctrl = _getCountController(participantId);
    int current = int.tryParse(ctrl.text) ?? 0;
    if (current > 0) {
      setState(() {
        ctrl.text = (current - 1).toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDark = appState.isDarkMode;
    final realParticipants = appState.realParticipants;

    _detectLowestUnmarkedClass(appState);

    // 1. CLASS + 1 RULE: Selected Class X ➔ Roster shows Class (X + 1)
    final selectedNum = int.tryParse(_selectedClass.replaceAll(RegExp(r'[^0-9]'), '')) ?? 5;
    final rosterClassNum = selectedNum < 12 ? selectedNum + 1 : 12;

    final classStudents = realParticipants.where((p) {
      final pNum = int.tryParse(p.studentClass.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      return pNum == rosterClassNum || p.studentClass.toLowerCase() == 'class $rosterClassNum'.toLowerCase();
    }).toList();

    final Map<String, ParticipantModel> allRosterMap = {};
    for (var p in classStudents) {
      if (!_removedStudentIds.contains(p.participantId)) {
        allRosterMap[p.participantId] = p;
      }
    }
    for (var p in _extraParticipants) {
      if (!_removedStudentIds.contains(p.participantId)) {
        allRosterMap[p.participantId] = p;
      }
    }
    final allRosterStudents = allRosterMap.values.toList();
    final totalWorkingDays = int.tryParse(_maxWorkingDaysController.text) ?? 200;

    // Check if any student's present count exceeds Total Working Days
    final List<String> invalidStudentNames = [];
    int markedStudentsCount = 0;
    for (var p in allRosterStudents) {
      final ctrl = _getCountController(p.participantId, initialVal: '0');
      final pVal = int.tryParse(ctrl.text) ?? 0;
      if (pVal > 0) markedStudentsCount++;
      if (pVal > totalWorkingDays) {
        invalidStudentNames.add('${p.name} ($pVal days)');
      }
    }

    final hasInvalidStudent = invalidStudentNames.isNotEmpty;

    // Search query matching students
    final searchMatchingStudents = realParticipants.where((p) {
      final q = _studentSearchQuery.trim().toLowerCase();
      final isInRoster = allRosterMap.containsKey(p.participantId);
      final matchQuery = q.isEmpty ||
          p.name.toLowerCase().contains(q) ||
          p.participantId.toLowerCase().contains(q) ||
          p.studentClass.toLowerCase().contains(q) ||
          p.category.toLowerCase().contains(q);
      return !isInRoster && matchQuery;
    }).toList();

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.92),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F172A) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isDark ? 120 : 40),
              blurRadius: 24,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Handle Bar
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Premium Header Banner
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF1E1B4B), const Color(0xFF312E81)]
                        : [const Color(0xFFEEF2FF), const Color(0xFFE0E7FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? const Color(0xFF4338CA).withAlpha(100) : const Color(0xFFC7D2FE),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.secondary.withAlpha(80),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.how_to_reg_rounded, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Class Attendance Sheet',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: isDark ? Colors.white : const Color(0xFF1E1B4B),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.secondary.withAlpha(30),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'Selected: $_selectedClass ($_selectedDivision)',
                                  style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.secondary),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '➔ Roster: Class $rosterClassNum',
                                style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.success.withAlpha(25),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.success.withAlpha(80)),
                      ),
                      child: Text(
                        '$markedStudentsCount / ${allRosterStudents.length} Marked',
                        style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.success),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Controls Bar: Class Selector + Division Segment Chips + Max Working Days Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    // Class Selection Dropdown
                    Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.school_rounded, color: AppColors.secondary, size: 18),
                          const SizedBox(width: 8),
                          DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedClass,
                              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12, color: isDark ? AppColors.textLight : AppColors.textDark),
                              dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                              items: ['Class 1', 'Class 2', 'Class 3', 'Class 4', 'Class 5', 'Class 6', 'Class 7', 'Class 8', 'Class 9', 'Class 10', 'Class 11', 'Class 12']
                                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                                  .toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() {
                                    _selectedClass = val;
                                    _loadSavedRecordValues(appState);
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 10),

                    // Division Segmented Selector Chips
                    Container(
                      height: 44,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                      ),
                      child: Row(
                        children: ['A', 'B', 'C', 'D'].map((div) {
                          final isSel = _selectedDivision == div;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedDivision = div;
                                _loadSavedRecordValues(appState);
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              decoration: BoxDecoration(
                                color: isSel ? AppColors.secondary : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Div $div',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                                  color: isSel ? Colors.white : (isDark ? AppColors.textLight : AppColors.textDark),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(width: 10),

                    // Total Working Days Input Card
                    Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: hasInvalidStudent ? AppColors.error.withAlpha(20) : AppColors.secondary.withAlpha(15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: hasInvalidStudent ? AppColors.error : AppColors.secondary.withAlpha(60),
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_month_rounded, color: hasInvalidStudent ? AppColors.error : AppColors.secondary, size: 16),
                          const SizedBox(width: 6),
                          Text('Max Days: ', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: isDark ? AppColors.subtextLight : AppColors.subtextDark)),
                          SizedBox(
                            width: 45,
                            child: TextField(
                              controller: _maxWorkingDaysController,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: hasInvalidStudent ? AppColors.error : AppColors.secondary),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(vertical: 6),
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (hasInvalidStudent) ...[
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.error.withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.error.withAlpha(80)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, size: 18, color: AppColors.error),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Exceeded Total Working Days ($totalWorkingDays)! Check: ${invalidStudentNames.join(", ")}.',
                          style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.error),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Roster Competitors List (Chest Card Styled Items)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Class $rosterClassNum Roster (${allRosterStudents.length} Students)',
                            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13, color: isDark ? AppColors.textLight : AppColors.textDark),
                          ),
                          if (!_showAddStudentPicker)
                            GestureDetector(
                              onTap: () => setState(() => _showAddStudentPicker = true),
                              child: Text(
                                '+ Add Extra Student',
                                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.secondary),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      ...allRosterStudents.map((p) {
                        final countCtrl = _getCountController(p.participantId, initialVal: '0');
                        final isExtra = !classStudents.any((cs) => cs.participantId == p.participantId);
                        final countVal = int.tryParse(countCtrl.text) ?? 0;
                        final isStudentExceeded = countVal > totalWorkingDays;
                        final isPresent = countVal > 0;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isStudentExceeded
                                ? AppColors.error.withAlpha(20)
                                : (isPresent
                                    ? AppColors.success.withAlpha(16)
                                    : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC))),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isStudentExceeded
                                  ? AppColors.error
                                  : (isPresent ? AppColors.success.withAlpha(90) : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0))),
                              width: (isStudentExceeded || isPresent) ? 1.5 : 1.0,
                            ),
                          ),
                          child: Row(
                            children: [
                              // Avatar / Chest Badge Icon
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: isStudentExceeded
                                      ? AppColors.error.withAlpha(30)
                                      : (isPresent ? AppColors.success.withAlpha(30) : AppColors.primary.withAlpha(20)),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Icon(
                                    isStudentExceeded
                                        ? Icons.warning_amber_rounded
                                        : (isPresent ? Icons.check_circle_rounded : Icons.person_outline_rounded),
                                    size: 20,
                                    color: isStudentExceeded
                                        ? AppColors.error
                                        : (isPresent ? AppColors.success : AppColors.primary),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Student Details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          p.name,
                                          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13, color: isDark ? AppColors.textLight : AppColors.textDark),
                                        ),
                                        if (isExtra) ...[
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: AppColors.secondary.withAlpha(25),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text('Extra', style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.secondary)),
                                          ),
                                        ],
                                      ],
                                    ),
                                    Text(
                                      '${p.participantId} • ${p.studentClass} (${p.division}) • ${p.category}',
                                      style: GoogleFonts.poppins(fontSize: 10, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
                                    ),
                                  ],
                                ),
                              ),

                              // Quick Increments & Present Days Box
                              Row(
                                children: [
                                  // Decrement Button
                                  IconButton(
                                    onPressed: () => _decrementDays(p.participantId),
                                    icon: const Icon(Icons.remove_circle_outline_rounded, size: 20),
                                    color: isDark ? AppColors.subtextLight : AppColors.subtextDark,
                                    constraints: const BoxConstraints(),
                                    padding: const EdgeInsets.all(4),
                                  ),

                                  // Count Box
                                  Container(
                                    width: 50,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF0F172A) : Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: isStudentExceeded
                                            ? AppColors.error
                                            : (isPresent ? AppColors.success : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1))),
                                        width: 1.2,
                                      ),
                                    ),
                                    child: TextField(
                                      controller: countCtrl,
                                      keyboardType: TextInputType.number,
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: isStudentExceeded
                                            ? AppColors.error
                                            : (isPresent ? AppColors.success : (isDark ? AppColors.textLight : AppColors.textDark)),
                                      ),
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        isDense: true,
                                        contentPadding: EdgeInsets.symmetric(vertical: 8),
                                      ),
                                      onChanged: (_) => setState(() {}),
                                    ),
                                  ),

                                  // Increment Button
                                  IconButton(
                                    onPressed: () => _incrementDays(p.participantId, totalWorkingDays),
                                    icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
                                    color: AppColors.secondary,
                                    constraints: const BoxConstraints(),
                                    padding: const EdgeInsets.all(4),
                                  ),

                                  const SizedBox(width: 4),

                                  // Remove Button
                                  IconButton(
                                    icon: const Icon(Icons.close_rounded, color: Colors.grey, size: 18),
                                    onPressed: () {
                                      setState(() {
                                        _removedStudentIds.add(p.participantId);
                                        _extraParticipants.removeWhere((ep) => ep.participantId == p.participantId);
                                      });
                                    },
                                    constraints: const BoxConstraints(),
                                    padding: const EdgeInsets.all(4),
                                    tooltip: 'Remove Student',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }),

                      // Search / Picker Panel for Extra Students
                      if (_showAddStudentPicker) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppColors.secondary.withAlpha(80), width: 1.5),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Select Additional Student', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.secondary)),
                                  IconButton(
                                    icon: const Icon(Icons.close_rounded, size: 18),
                                    onPressed: () => setState(() => _showAddStudentPicker = false),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                onChanged: (val) => setState(() => _studentSearchQuery = val),
                                decoration: InputDecoration(
                                  hintText: 'Search student name, ID or class...',
                                  hintStyle: GoogleFonts.poppins(fontSize: 12, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
                                  prefixIcon: const Icon(Icons.person_search_rounded, size: 18, color: AppColors.secondary),
                                  filled: true,
                                  fillColor: isDark ? const Color(0xFF0F172A) : Colors.white,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                  contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                constraints: const BoxConstraints(maxHeight: 180),
                                child: ListView.separated(
                                  shrinkWrap: true,
                                  itemCount: searchMatchingStudents.length,
                                  separatorBuilder: (_, _) => const Divider(height: 1),
                                  itemBuilder: (context, idx) {
                                    final sp = searchMatchingStudents[idx];
                                    final existingClass = _getStudentExistingClassPresent(sp.participantId, appState);
                                    final isAlreadyAddedElsewhere = existingClass != null;

                                    return ListTile(
                                      dense: true,
                                      title: Text(sp.name, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12, color: isAlreadyAddedElsewhere ? Colors.grey : (isDark ? AppColors.textLight : AppColors.textDark))),
                                      subtitle: Text(
                                        isAlreadyAddedElsewhere
                                            ? '${sp.participantId} • ${sp.studentClass} (${sp.division}) • ⚠️ Added in $existingClass'
                                            : '${sp.participantId} • ${sp.studentClass} (${sp.division}) • ${sp.category}',
                                        style: GoogleFonts.poppins(fontSize: 10, color: isAlreadyAddedElsewhere ? AppColors.error : (isDark ? AppColors.subtextLight : AppColors.subtextDark), fontWeight: isAlreadyAddedElsewhere ? FontWeight.bold : FontWeight.normal),
                                      ),
                                      trailing: isAlreadyAddedElsewhere
                                          ? Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: AppColors.error.withAlpha(25),
                                                borderRadius: BorderRadius.circular(6),
                                                border: Border.all(color: AppColors.error.withAlpha(80)),
                                              ),
                                              child: Text(
                                                'Added in $existingClass',
                                                style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.error),
                                              ),
                                            )
                                          : const Icon(Icons.add_circle_outline_rounded, size: 18, color: AppColors.secondary),
                                      onTap: isAlreadyAddedElsewhere
                                          ? () {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('⚠️ Cannot add ${sp.name}! Student is already registered in $existingClass.'),
                                                  backgroundColor: AppColors.error,
                                                ),
                                              );
                                            }
                                          : () {
                                              setState(() {
                                                _extraParticipants.add(sp);
                                                _removedStudentIds.remove(sp.participantId);
                                              });
                                            },
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Primary Save Action Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: hasInvalidStudent
                      ? null
                      : () async {
                          final List<PresentStudentModel> studentList = allRosterStudents.map((p) {
                            final ctrl = _getCountController(p.participantId, initialVal: '0');
                            final pVal = int.tryParse(ctrl.text) ?? 0;
                            return PresentStudentModel(
                              participantId: p.participantId,
                              name: p.name,
                              presentCount: pVal,
                              currentClass: p.studentClass,
                              currentDiv: p.division,
                            );
                          }).toList();

                          PresentModel.calculateTiedRanks(studentList);

                          final record = PresentModel(
                            docId: '${_selectedClass}_$_selectedDivision',
                            studentClass: _selectedClass,
                            division: _selectedDivision,
                            totalStudents: studentList.length,
                            maxWorkingDays: totalWorkingDays,
                            students: studentList,
                          );

                          await appState.savePresentRecordToFirestore(record);

                          if (context.mounted) {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('✅ Attendance Record saved for $_selectedClass (Div $_selectedDivision)! Total Working Days: $totalWorkingDays.'),
                                backgroundColor: AppColors.success,
                              ),
                            );
                          }
                        },
                  icon: const Icon(Icons.check_circle_rounded, size: 20),
                  label: Text('Save Attendance Sheet', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
