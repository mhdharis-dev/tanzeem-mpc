// Library: add_class_mark_sheet.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/models/participant_model.dart';
import '../../core/models/mark_model.dart';
import '../../core/providers/app_state.dart';
import '../../core/theme/app_colors.dart';

// Helper class for subject input management
class _SubjectInput {
  final TextEditingController nameController;
  final TextEditingController maxMarkController;

  _SubjectInput(String name, {int maxMark = 50})
      : nameController = TextEditingController(text: name),
        maxMarkController = TextEditingController(text: '$maxMark');

  void dispose() {
    nameController.dispose();
    maxMarkController.dispose();
  }
}

// -----------------------------------------------------------------------------
// ADD CLASS MARK SHEET (With Dynamic Subjects, Full-Width Roster & Tied Ranks)
// -----------------------------------------------------------------------------
class AddClassMarkSheet extends StatefulWidget {
  final String? initialClass;
  final String? initialDiv;

  const AddClassMarkSheet({
    super.key,
    this.initialClass,
    this.initialDiv,
  });

  @override
  State<AddClassMarkSheet> createState() => _AddClassMarkSheetState();
}

class _AddClassMarkSheetState extends State<AddClassMarkSheet> {
  late String _selectedClass;
  late String _selectedDivision;

  // Subjects List (Default: Thareeq 50, Fiqh 50)
  final List<_SubjectInput> _subjects = [];

  // Map of "${participantId}_${subjectIndex}" -> TextEditingController for student mark
  final Map<String, TextEditingController> _markControllers = {};
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

    // Default 2 subjects as shown in the design: Thareeq (50), Fiqh (50)
    _subjects.add(_SubjectInput('Thareeq', maxMark: 50));
    _subjects.add(_SubjectInput('Fiqh', maxMark: 50));
  }

  @override
  void dispose() {
    for (var sub in _subjects) {
      sub.dispose();
    }
    for (var c in _markControllers.values) {
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
      final markedClasses = appState.markRecords
          .where((r) => r.students.any((s) => s.totalMarks > 0))
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
    MarkModel? savedRecord;
    try {
      savedRecord = appState.markRecords.firstWhere(
        (r) => r.docId == targetDocId || (r.studentClass == _selectedClass && r.division == _selectedDivision),
      );
    } catch (_) {}

    if (savedRecord != null && savedRecord.students.isNotEmpty) {
      // Get standard Class + 1 student IDs to identify extra added students
      final selectedNum = int.tryParse(_selectedClass.replaceAll(RegExp(r'[^0-9]'), '')) ?? 5;
      final rosterClassNum = selectedNum < 12 ? selectedNum + 1 : 12;
      final defaultStudentIds = appState.realParticipants.where((p) {
        final pNum = int.tryParse(p.studentClass.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        return pNum == rosterClassNum || p.studentClass.toLowerCase() == 'class $rosterClassNum'.toLowerCase();
      }).map((p) => p.participantId).toSet();

      // Extract unique subjects from saved students
      final Map<String, int> savedSubjectsMap = {};
      for (var st in savedRecord.students) {
        for (var sub in st.subjects) {
          if (!savedSubjectsMap.containsKey(sub.subjectName)) {
            savedSubjectsMap[sub.subjectName] = sub.maxMark;
          }
        }
      }

      if (savedSubjectsMap.isNotEmpty) {
        // Clear current subject controllers and rebuild
        for (var sub in _subjects) {
          sub.dispose();
        }
        _subjects.clear();
        savedSubjectsMap.forEach((subName, maxM) {
          _subjects.add(_SubjectInput(subName, maxMark: maxM));
        });
      }

      // Populate student mark controllers & restore extra added students
      for (var st in savedRecord.students) {
        for (int subIdx = 0; subIdx < st.subjects.length; subIdx++) {
          final sub = st.subjects[subIdx];
          final key = '${st.participantId}_$subIdx';
          if (_markControllers.containsKey(key)) {
            _markControllers[key]!.text = sub.studentMark.toString();
          } else {
            _markControllers[key] = TextEditingController(text: sub.studentMark.toString());
          }
        }

        // If this saved student is NOT in default class roster, add to _extraParticipants
        if (!defaultStudentIds.contains(st.participantId)) {
          try {
            final p = appState.realParticipants.firstWhere((rp) => rp.participantId == st.participantId);
            if (!_extraParticipants.any((ep) => ep.participantId == st.participantId)) {
              _extraParticipants.add(p);
            }
          } catch (_) {
            if (!_extraParticipants.any((ep) => ep.participantId == st.participantId)) {
              _extraParticipants.add(ParticipantModel.fromMap({
                'participantId': st.participantId,
                'name': st.name,
                'studentClass': st.currentClass,
                'division': st.currentDiv,
                'category': 'General',
                'madrasaId': appState.madrasaId,
              }));
            }
          }
        }
      }
    }
  }

  String? _getStudentExistingClassMark(String participantId, AppState appState) {
    final currentDocId = '${_selectedClass}_$_selectedDivision';
    for (var record in appState.markRecords) {
      if (record.docId != currentDocId) {
        if (record.students.any((s) => s.participantId == participantId)) {
          return '${record.studentClass} (${record.division})';
        }
      }
    }
    return null;
  }

  TextEditingController _getMarkController(String studentId, int subjectIndex, {String initialVal = '0'}) {
    final key = '${studentId}_$subjectIndex';
    if (!_markControllers.containsKey(key)) {
      _markControllers[key] = TextEditingController(text: initialVal);
    }
    return _markControllers[key]!;
  }

  void _addNewSubject() {
    setState(() {
      _subjects.add(_SubjectInput('Subject ${_subjects.length + 1}', maxMark: 50));
    });
  }

  void _removeSubject(int index) {
    if (_subjects.length <= 1) return; // Keep at least 1 subject
    setState(() {
      final removed = _subjects.removeAt(index);
      removed.dispose();
    });
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

    // Check for any invalid student marks exceeding subject max mark
    final List<String> invalidEntries = [];
    for (var p in allRosterStudents) {
      for (int i = 0; i < _subjects.length; i++) {
        final sub = _subjects[i];
        final maxM = int.tryParse(sub.maxMarkController.text) ?? 50;
        final ctrl = _getMarkController(p.participantId, i);
        final markVal = int.tryParse(ctrl.text) ?? 0;
        if (markVal > maxM) {
          invalidEntries.add('${p.name} (${sub.nameController.text}: $markVal > $maxM)');
        }
      }
    }
    final hasInvalidMarks = invalidEntries.isNotEmpty;

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
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(color: isDark ? AppColors.glassBorderDark : AppColors.glassBorderLight),
        ),
        padding: const EdgeInsets.all(20.0),
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
            const SizedBox(height: 12),

            // Header Section
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.post_add_rounded, color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Class Mark Sheet',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18, color: isDark ? AppColors.textLight : AppColors.textDark),
                      ),
                      Text(
                        'Selected: $_selectedClass (Div $_selectedDivision) ➔ Class $rosterClassNum',
                        style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
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

            const SizedBox(height: 14),

            // Controls Row: Class Dropdown + Division Dropdown
            Row(
              children: [
                // Class Selection Dropdown
                Expanded(
                  child: Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.school_rounded, color: AppColors.primary, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          'Class: ',
                          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
                        ),
                        Expanded(
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedClass,
                              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primary),
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
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withAlpha(20),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.secondary, width: 1.2),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.grid_view_rounded, color: AppColors.secondary, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        'Div: ',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
                      ),
                      DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedDivision,
                          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.secondary),
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
              ],
            ),

            if (hasInvalidMarks) ...[
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
                        'Student marks for ${invalidEntries.join(", ")} exceed Subject Max Mark! Student mark must be ≤ Subject Max Mark.',
                        style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.error),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 14),

            // Scrollable Content Area (Subjects Table + Student Marks Grid)
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. SUBJECTS MANAGEMENT TABLE
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Subjects & Max Marks Config:',
                                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primary),
                              ),
                              Text(
                                '${_subjects.length} Subjects',
                                style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Table Header
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withAlpha(20),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Expanded(flex: 4, child: Text('Subject Name', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.primary))),
                                const SizedBox(width: 8),
                                SizedBox(width: 100, child: Text('Max Mark', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.primary), textAlign: TextAlign.center)),
                                const SizedBox(width: 8),
                                const SizedBox(width: 36, child: Text('', textAlign: TextAlign.center)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),

                          // Subject Rows List
                          ...List.generate(_subjects.length, (idx) {
                            final sub = _subjects[idx];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 6),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.cardDark : Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                              ),
                              child: Row(
                                children: [
                                  // Subject Name Input Field
                                  Expanded(
                                    flex: 4,
                                    child: TextField(
                                      controller: sub.nameController,
                                      style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? AppColors.textLight : AppColors.textDark),
                                      decoration: const InputDecoration(
                                        isDense: true,
                                        contentPadding: EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                                        border: InputBorder.none,
                                        hintText: 'Enter subject name...',
                                      ),
                                      onChanged: (_) => setState(() {}),
                                    ),
                                  ),
                                  const SizedBox(width: 8),

                                  // Max Mark Input Field (Default 50)
                                  SizedBox(
                                    width: 100,
                                    child: Container(
                                      height: 34,
                                      decoration: BoxDecoration(
                                        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: AppColors.primary, width: 1.2),
                                      ),
                                      child: TextField(
                                        controller: sub.maxMarkController,
                                        keyboardType: TextInputType.number,
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                                        decoration: const InputDecoration(
                                          isDense: true,
                                          contentPadding: EdgeInsets.symmetric(vertical: 6),
                                          border: InputBorder.none,
                                        ),
                                        onChanged: (_) => setState(() {}),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),

                                  // Delete Subject Button
                                  SizedBox(
                                    width: 36,
                                    child: IconButton(
                                      icon: const Icon(Icons.remove_circle_outline_rounded, color: AppColors.error, size: 20),
                                      onPressed: () => _removeSubject(idx),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),

                          const SizedBox(height: 6),
                          Center(
                            child: InkWell(
                              onTap: _addNewSubject,
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withAlpha(20),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppColors.primary, width: 1.2),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.add_rounded, size: 16, color: AppColors.primary),
                                    const SizedBox(width: 6),
                                    Text('Add New Subject', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primary)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 2. STUDENT MARKS ENTRY GRID TABLE (Full Width)
                    Text(
                      'Class $rosterClassNum Students Marks Roster (${allRosterStudents.length} Students):',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12, color: isDark ? AppColors.textLight : AppColors.textDark),
                    ),
                    const SizedBox(height: 8),

                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(minWidth: constraints.maxWidth),
                              child: DataTable(
                                columnSpacing: 24,
                                headingRowHeight: 42,
                                dataRowMaxHeight: 56,
                                headingRowColor: WidgetStateProperty.all(AppColors.secondary.withAlpha(20)),
                                columns: [
                                  DataColumn(
                                    label: Text('Name', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.secondary)),
                                  ),
                                  ...List.generate(_subjects.length, (sIdx) {
                                    final subName = _subjects[sIdx].nameController.text.trim();
                                    return DataColumn(
                                      label: Text(
                                        subName.isNotEmpty ? subName : 'Sub ${sIdx + 1}',
                                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.secondary),
                                      ),
                                    );
                                  }),
                                  DataColumn(
                                    label: Text('Action', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.error)),
                                  ),
                                ],
                                rows: allRosterStudents.map((p) {
                                  final isExtra = !classStudents.any((cs) => cs.participantId == p.participantId);

                                  return DataRow(
                                    cells: [
                                      // Candidate Name Cell
                                      DataCell(
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      p.name,
                                                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12, color: isDark ? AppColors.textLight : AppColors.textDark),
                                                    ),
                                                    if (isExtra) ...[
                                                      const SizedBox(width: 4),
                                                      Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                                        decoration: BoxDecoration(
                                                          color: AppColors.primary.withAlpha(25),
                                                          borderRadius: BorderRadius.circular(4),
                                                        ),
                                                        child: Text('Added', style: GoogleFonts.poppins(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.primary)),
                                                      ),
                                                    ],
                                                  ],
                                                ),
                                                Text('${p.participantId} • ${p.studentClass} (${p.division})', style: GoogleFonts.poppins(fontSize: 9, color: isDark ? AppColors.subtextLight : AppColors.subtextDark)),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Subject Mark Cells
                                      ...List.generate(_subjects.length, (sIdx) {
                                        final sub = _subjects[sIdx];
                                        final maxM = int.tryParse(sub.maxMarkController.text) ?? 50;
                                        final ctrl = _getMarkController(p.participantId, sIdx);
                                        final markVal = int.tryParse(ctrl.text) ?? 0;
                                        final isExceeded = markVal > maxM;

                                        return DataCell(
                                          Container(
                                            width: 65,
                                            height: 34,
                                            decoration: BoxDecoration(
                                              color: isExceeded
                                                  ? AppColors.error.withAlpha(20)
                                                  : (isDark ? AppColors.cardDark : Colors.white),
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(
                                                color: isExceeded
                                                    ? AppColors.error
                                                    : (markVal > 0 ? AppColors.primary : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1))),
                                                width: 1.2,
                                              ),
                                            ),
                                            child: TextField(
                                              controller: ctrl,
                                              keyboardType: TextInputType.number,
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.poppins(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: isExceeded
                                                    ? AppColors.error
                                                    : (markVal > 0 ? AppColors.primary : (isDark ? AppColors.textLight : AppColors.textDark)),
                                              ),
                                              decoration: const InputDecoration(
                                                isDense: true,
                                                contentPadding: EdgeInsets.symmetric(vertical: 7),
                                                border: InputBorder.none,
                                              ),
                                              onChanged: (_) => setState(() {}),
                                            ),
                                          ),
                                        );
                                      }),

                                      // Student Remove Action Cell
                                      DataCell(
                                        IconButton(
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
                                  );
                                }).toList(),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Button: + Add Other Students
                    if (!_showAddStudentPicker)
                      Center(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            setState(() {
                              _showAddStudentPicker = true;
                            });
                          },
                          icon: const Icon(Icons.person_add_alt_1_rounded, size: 18, color: AppColors.primary),
                          label: Text('Add Other Students', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primary)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.primary, width: 1.5),
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      )
                    else ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.primary.withAlpha(80), width: 1.5),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Select Additional Students', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primary)),
                                IconButton(
                                  icon: const Icon(Icons.close_rounded, size: 18),
                                  onPressed: () => setState(() => _showAddStudentPicker = false),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            TextField(
                              onChanged: (val) => setState(() => _studentSearchQuery = val),
                              decoration: InputDecoration(
                                hintText: 'Search student name, ID or class...',
                                hintStyle: GoogleFonts.poppins(fontSize: 11, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
                                prefixIcon: const Icon(Icons.person_search_rounded, size: 18, color: AppColors.primary),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              constraints: const BoxConstraints(maxHeight: 160),
                              child: ListView.separated(
                                shrinkWrap: true,
                                itemCount: searchMatchingStudents.length,
                                separatorBuilder: (_, _) => const Divider(height: 1),
                                itemBuilder: (context, idx) {
                                  final sp = searchMatchingStudents[idx];
                                  final existingClass = _getStudentExistingClassMark(sp.participantId, appState);
                                  final isAlreadyAddedElsewhere = existingClass != null;

                                  return ListTile(
                                    dense: true,
                                    title: Text(sp.name, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 11, color: isAlreadyAddedElsewhere ? (isDark ? Colors.white54 : Colors.black54) : (isDark ? AppColors.textLight : AppColors.textDark))),
                                    subtitle: Text(
                                      isAlreadyAddedElsewhere
                                          ? '${sp.participantId} • ${sp.studentClass} (${sp.division}) • ⚠️ Added in $existingClass'
                                          : '${sp.participantId} • ${sp.studentClass} (${sp.division})',
                                      style: GoogleFonts.poppins(fontSize: 9, color: isAlreadyAddedElsewhere ? AppColors.error : (isDark ? AppColors.subtextLight : AppColors.subtextDark), fontWeight: isAlreadyAddedElsewhere ? FontWeight.bold : FontWeight.normal),
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
                                        : const Icon(Icons.add_circle_outline_rounded, size: 18, color: AppColors.primary),
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

            const SizedBox(height: 14),

            // Bottom Full Width Save Button
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton.icon(
                onPressed: hasInvalidMarks
                    ? null
                    : () async {
                        final List<MarkStudentModel> studentList = allRosterStudents.map((p) {
                          final List<MarkSubjectModel> subModels = [];
                          for (int i = 0; i < _subjects.length; i++) {
                            final sub = _subjects[i];
                            final subName = sub.nameController.text.trim();
                            final maxM = int.tryParse(sub.maxMarkController.text) ?? 50;
                            final ctrl = _getMarkController(p.participantId, i);
                            final markVal = int.tryParse(ctrl.text) ?? 0;
                            subModels.add(MarkSubjectModel(
                              subjectName: subName.isNotEmpty ? subName : 'Subject ${i + 1}',
                              maxMark: maxM,
                              studentMark: markVal,
                            ));
                          }

                          return MarkStudentModel(
                            participantId: p.participantId,
                            name: p.name,
                            currentClass: p.studentClass,
                            currentDiv: p.division,
                            subjects: subModels,
                          );
                        }).toList();

                        MarkModel.calculateTiedRanks(studentList);

                        final record = MarkModel(
                          docId: '${_selectedClass}_$_selectedDivision',
                          studentClass: _selectedClass,
                          division: _selectedDivision,
                          totalStudents: studentList.length,
                          students: studentList,
                        );

                        await appState.saveMarkRecordToFirestore(record);

                        if (context.mounted) {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('✅ Class Mark Sheet saved for $_selectedClass (Div $_selectedDivision)! Total Competitors: ${studentList.length}.'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        }
                      },
                icon: const Icon(Icons.check_circle_rounded, size: 20),
                label: Text('Save Mark Sheet', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
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
