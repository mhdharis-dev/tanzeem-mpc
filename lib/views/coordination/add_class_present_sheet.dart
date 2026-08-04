import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/models/participant_model.dart';
import '../../core/models/present_model.dart';
import '../../core/providers/app_state.dart';
import '../../core/theme/app_colors.dart';

// -----------------------------------------------------------------------------
// ADD CLASS PRESENT SHEET (With Division Selection & Tied Rank Calculation)
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

  // Map of participantId -> present count TextEditingController (Defaults to '0')
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

        // If this saved student is NOT in default class roster, add to _extraParticipants
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

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDark = appState.isDarkMode;
    final realParticipants = appState.realParticipants;

    // Detect lowest unmarked class on first launch & load real values
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

    // 2. Total Working Days (Max Present per Student)
    final totalWorkingDays = int.tryParse(_maxWorkingDaysController.text) ?? 200;

    // Check if any student's present count exceeds Total Working Days
    final List<String> invalidStudentNames = [];
    for (var p in allRosterStudents) {
      final ctrl = _getCountController(p.participantId, initialVal: '0');
      final pVal = int.tryParse(ctrl.text) ?? 0;
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
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.90),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(color: isDark ? AppColors.glassBorderDark : AppColors.glassBorderLight),
        ),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.how_to_reg_rounded, color: AppColors.secondary, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Class Present Sheet',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18, color: isDark ? AppColors.textLight : AppColors.textDark),
                      ),
                      Text(
                        'Selected: $_selectedClass (Div $_selectedDivision) ➔ Class $rosterClassNum ',
                        style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.secondary),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Top Controls Row: Class Selector + Division Selector + Total Working Days Box
            Row(
              children: [
                // Class Selection Dropdown
                Expanded(
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.school_rounded, color: AppColors.secondary, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          'Class: ',
                          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
                        ),
                        Expanded(
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedClass,
                              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.secondary),
                              dropdownColor: isDark ? AppColors.cardDark : Colors.white,
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
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                // Division Selection Dropdown (Default 'A')
                Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(20),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.primary, width: 1.2),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.grid_view_rounded, color: AppColors.primary, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        'Div: ',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
                      ),
                      DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedDivision,
                          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primary),
                          dropdownColor: isDark ? AppColors.cardDark : Colors.white,
                          items: ['A', 'B', 'C', 'D']
                              .map((d) => DropdownMenuItem(value: d, child: Text('Div $d')))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedDivision = val;
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

                // Total Working Days Box
                Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: hasInvalidStudent
                        ? AppColors.error.withAlpha(20)
                        : AppColors.secondary.withAlpha(20),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: hasInvalidStudent ? AppColors.error : AppColors.secondary.withAlpha(80),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_month_rounded,
                        color: hasInvalidStudent ? AppColors.error : AppColors.secondary,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Max Days: ',
                        style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
                      ),
                      Container(
                        width: 50,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.cardDark : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: hasInvalidStudent ? AppColors.error : AppColors.secondary, width: 1.2),
                        ),
                        child: TextField(
                          controller: _maxWorkingDaysController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: hasInvalidStudent ? AppColors.error : AppColors.secondary),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 8),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            if (hasInvalidStudent) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.error.withAlpha(25),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.error.withAlpha(80)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded, size: 16, color: AppColors.error),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Student present count for ${invalidStudentNames.join(", ")} exceeds Total Working Days ($totalWorkingDays)! Student count must be ≤ Total Working Days.',
                        style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.error),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Middle Roster List of Students (Showing Class + 1 with Remove option)
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Class $rosterClassNum Students Roster (${allRosterStudents.length} Competitors):',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13, color: isDark ? AppColors.textLight : AppColors.textDark),
                    ),
                    const SizedBox(height: 8),

                    ...allRosterStudents.map((p) {
                      final countCtrl = _getCountController(p.participantId, initialVal: '0');
                      final isExtra = !classStudents.any((cs) => cs.participantId == p.participantId);
                      final countVal = int.tryParse(countCtrl.text) ?? 0;
                      final isStudentExceeded = countVal > totalWorkingDays;
                      final isPresent = countVal > 0;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isStudentExceeded
                              ? AppColors.error.withAlpha(20)
                              : (isPresent
                                  ? AppColors.success.withAlpha(16)
                                  : (isDark ? AppColors.surfaceDark : AppColors.surfaceLight)),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isStudentExceeded
                                ? AppColors.error
                                : (isPresent
                                    ? AppColors.success.withAlpha(90)
                                    : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1))),
                            width: (isStudentExceeded || isPresent) ? 1.5 : 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: isStudentExceeded
                                    ? AppColors.error.withAlpha(30)
                                    : (isPresent ? AppColors.success.withAlpha(30) : AppColors.primary.withAlpha(20)),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isStudentExceeded
                                    ? Icons.warning_amber_rounded
                                    : (isPresent ? Icons.check_circle_rounded : Icons.person_rounded),
                                size: 16,
                                color: isStudentExceeded
                                    ? AppColors.error
                                    : (isPresent ? AppColors.success : AppColors.primary),
                              ),
                            ),
                            const SizedBox(width: 12),
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
                                          child: Text('Added', style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.secondary)),
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

                            // Student Present Days Input Field (Default 0, Max = Total Working Days)
                            Row(
                              children: [
                                Text(
                                  'Days Present: ',
                                  style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
                                ),
                                Container(
                                  width: 65,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: isDark ? AppColors.cardDark : Colors.white,
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
                                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                                    ),
                                    onChanged: (_) => setState(() {}),
                                  ),
                                ),
                                const SizedBox(width: 8),

                                // Student Remove Button from Sheet
                                Tooltip(
                                  message: 'Remove Student from Roster',
                                  child: IconButton(
                                    icon: const Icon(Icons.remove_circle_outline_rounded, color: AppColors.error, size: 20),
                                    onPressed: () {
                                      setState(() {
                                        _removedStudentIds.add(p.participantId);
                                        _extraParticipants.removeWhere((ep) => ep.participantId == p.participantId);
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),

                    const SizedBox(height: 14),

                    // Button: + Add Other Students
                    if (!_showAddStudentPicker)
                      Center(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            setState(() {
                              _showAddStudentPicker = true;
                            });
                          },
                          icon: const Icon(Icons.person_add_alt_1_rounded, size: 18, color: AppColors.secondary),
                          label: Text('Add Other Students', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.secondary)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.secondary, width: 1.5),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      )
                    else ...[
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.secondary.withAlpha(80), width: 1.5),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Select Additional Students', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.secondary)),
                                IconButton(
                                  icon: const Icon(Icons.close_rounded, size: 18),
                                  onPressed: () => setState(() => _showAddStudentPicker = false),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            TextField(
                              onChanged: (val) => setState(() => _studentSearchQuery = val),
                              decoration: InputDecoration(
                                hintText: 'Search student name, ID or class...',
                                hintStyle: GoogleFonts.poppins(fontSize: 12, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
                                prefixIcon: const Icon(Icons.person_search_rounded, size: 18, color: AppColors.secondary),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                                    title: Text(sp.name, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12, color: isAlreadyAddedElsewhere ? (isDark ? Colors.white54 : Colors.black54) : (isDark ? AppColors.textLight : AppColors.textDark))),
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

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 48,
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
                label: Text('Save Attendance Sheet', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
