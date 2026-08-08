// Library: add_program_sheet.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/models/participant_model.dart';
import '../../core/models/program_model.dart';
import '../../core/providers/app_state.dart';
import '../../core/theme/app_colors.dart';

class SingleTabEntry {
  ParticipantModel? selectedParticipant;
  String searchQuery = '';
  List<String> selectedProgramNames;
  Map<String, int> programDurations;
  final TextEditingController customController = TextEditingController();

  // Track existing data auto-fill state
  bool isPreFilledFromExisting = false;
  Map<String, ProgramModel> existingProgramsMap = {};

  SingleTabEntry({
    this.selectedParticipant,
    List<String>? selectedProgramNames,
    Map<String, int>? programDurations,
  }) : selectedProgramNames = selectedProgramNames ?? ['MEELAD SONG'],
       programDurations = programDurations ?? {'MEELAD SONG': 10};

  void dispose() {
    customController.dispose();
  }
}

class GroupTabEntry {
  final TextEditingController programNameController;
  List<ParticipantModel> selectedGroupParticipants;
  int groupDuration;
  String searchQuery = '';

  // Track existing group auto-fill state
  bool isPreFilledFromExisting = false;
  ProgramModel? existingGroupDoc;

  GroupTabEntry({
    String programName = '',
    List<ParticipantModel>? selectedGroupParticipants,
    this.groupDuration = 15,
  }) : programNameController = TextEditingController(text: programName),
       selectedGroupParticipants = selectedGroupParticipants ?? [];

  void dispose() {
    programNameController.dispose();
  }
}

class AddProgramSheet extends StatefulWidget {
  final String initialType; // 'single', 'group', 'other'
  final ProgramModel? programToEdit;

  const AddProgramSheet({
    super.key,
    this.initialType = 'single',
    this.programToEdit,
  });

  @override
  State<AddProgramSheet> createState() => _AddProgramSheetState();
}

class _AddProgramSheetState extends State<AddProgramSheet> {
  late String _programType; // 'single', 'group'
  String _editingStatus = 'pending';
  int _activeTabIndex = 0;

  // Multi-tab entries lists
  final List<SingleTabEntry> _singleTabs = [];
  final List<GroupTabEntry> _groupTabs = [];

  // Preset Suggestions for Single Items
  final List<String> _presetSingleItems = [
    'MEELAD SONG',
    'QIRA\'AT RECITATION',
    'ELOCUTION / SPEECH',
    'ARABIC SPEECH',
    'URDU SPEECH',
    'ENGLISH SPEECH',
    'MAPPILA SONG',
  ];

  // Preset Suggestions for Group Items
  final List<String> _presetGroupItems = [
    'GROUP SONG',
    'DUFF MUTA',
    'BURDA RECITATION',
    'MAWLID SINGING',
    'DEBATE',
    'SCOUT',
    'FLOWER SHOW',
  ];

  @override
  void initState() {
    super.initState();
    _programType = widget.initialType.toLowerCase();

    if (widget.programToEdit != null) {
      final prog = widget.programToEdit!;
      _programType = prog.programType.toLowerCase();
      _editingStatus = prog.status.toLowerCase();

      final initialDur = int.tryParse(prog.duration.split(' ')[0]) ?? 10;

      if (_programType == 'group') {
        final names = prog.participantName.split(', ');
        final ids = prog.participantId.split(', ');
        final groupParts = <ParticipantModel>[];
        for (int i = 0; i < names.length; i++) {
          final pId = i < ids.length ? ids[i] : 'PATC-00${i + 1}';
          groupParts.add(
            ParticipantModel(
              participantId: pId,
              name: names[i],
              studentClass: prog.studentClass,
              gender: 'Male',
              division: prog.division,
              category: prog.category,
              parentName: '',
              phoneNo: '',
              madrasaId: prog.madrasaId,
              createdAt: prog.createdAt,
            ),
          );
        }
        final gTab = GroupTabEntry(
          programName: prog.programName,
          selectedGroupParticipants: groupParts,
          groupDuration: initialDur,
        );
        gTab.existingGroupDoc = prog;
        gTab.isPreFilledFromExisting = true;
        _groupTabs.add(gTab);
      } else {
        final sTab = SingleTabEntry(
          selectedParticipant: ParticipantModel(
            participantId: prog.participantId,
            name: prog.participantName,
            studentClass: prog.studentClass,
            gender: 'Male',
            division: prog.division,
            category: prog.category,
            parentName: '',
            phoneNo: '',
            madrasaId: prog.madrasaId,
            createdAt: prog.createdAt,
          ),
          selectedProgramNames: [prog.programName],
          programDurations: {prog.programName: initialDur},
        );
        sTab.existingProgramsMap[prog.programName.toUpperCase()] = prog;
        sTab.isPreFilledFromExisting = true;
        _singleTabs.add(sTab);
      }
    } else {
      if (_programType == 'group') {
        _groupTabs.add(GroupTabEntry());
      } else {
        _singleTabs.add(SingleTabEntry());
      }
    }
  }

  @override
  void dispose() {
    for (var tab in _singleTabs) {
      tab.dispose();
    }
    for (var tab in _groupTabs) {
      tab.dispose();
    }
    super.dispose();
  }

  void _addNewTab() {
    setState(() {
      if (_programType == 'single') {
        _singleTabs.add(SingleTabEntry());
        _activeTabIndex = _singleTabs.length - 1;
      } else {
        _groupTabs.add(GroupTabEntry());
        _activeTabIndex = _groupTabs.length - 1;
      }
    });
  }

  void _removeTab(int index) {
    if (_programType == 'single') {
      if (_singleTabs.length > 1) {
        setState(() {
          _singleTabs[index].dispose();
          _singleTabs.removeAt(index);
          if (_activeTabIndex >= _singleTabs.length) {
            _activeTabIndex = _singleTabs.length - 1;
          }
        });
      }
    } else {
      if (_groupTabs.length > 1) {
        setState(() {
          _groupTabs[index].dispose();
          _groupTabs.removeAt(index);
          if (_activeTabIndex >= _groupTabs.length) {
            _activeTabIndex = _groupTabs.length - 1;
          }
        });
      }
    }
  }

  // --- AUTO FILL LOGIC FOR SINGLE MODE ---
  void _selectSingleParticipant(
    SingleTabEntry tab,
    ParticipantModel p,
    AppState appState,
  ) {
    tab.selectedParticipant = p;
    tab.existingProgramsMap.clear();
    tab.isPreFilledFromExisting = false;

    // Query realPrograms in AppState for existing registered single programs for this student
    final existingProgs = appState.realPrograms.where((prog) {
      return prog.programType.toLowerCase() == 'single' &&
          prog.participantId.trim().toLowerCase() ==
              p.participantId.trim().toLowerCase();
    }).toList();

    if (existingProgs.isNotEmpty) {
      tab.isPreFilledFromExisting = true;
      tab.selectedProgramNames.clear();

      for (var ep in existingProgs) {
        final pName = ep.programName.trim().toUpperCase();
        final durInt = int.tryParse(ep.duration.split(' ')[0]) ?? 10;
        if (!tab.selectedProgramNames.contains(pName)) {
          tab.selectedProgramNames.add(pName);
        }
        tab.programDurations[pName] = durInt;
        tab.existingProgramsMap[pName] = ep;
      }
    }

    setState(() {});
  }

  // --- AUTO FILL LOGIC FOR GROUP MODE ---
  void _checkGroupMatchAndAutoFill(GroupTabEntry tab, AppState appState) {
    final selectedIds = tab.selectedGroupParticipants
        .map((gp) => gp.participantId.trim().toLowerCase())
        .toSet();

    if (selectedIds.isEmpty) {
      tab.isPreFilledFromExisting = false;
      tab.existingGroupDoc = null;
      return;
    }

    // Find an existing group program in appState.realPrograms whose members are ALL included in selectedIds
    final existingGroupProgs = appState.realPrograms.where((prog) {
      if (prog.programType.toLowerCase() != 'group') return false;
      final progIds = prog.participantId
          .split(', ')
          .map((id) => id.trim().toLowerCase())
          .toSet();

      // Activation Condition: selected students must contain ALL members of an existing registered group program
      return progIds.isNotEmpty &&
          progIds.every((id) => selectedIds.contains(id));
    }).toList();

    if (existingGroupProgs.isNotEmpty) {
      final matchedProg = existingGroupProgs.first;
      tab.isPreFilledFromExisting = true;
      tab.existingGroupDoc = matchedProg;

      if (matchedProg.programName.isNotEmpty) {
        tab.programNameController.text = matchedProg.programName.toUpperCase();
      }
      final durInt = int.tryParse(matchedProg.duration.split(' ')[0]) ?? 15;
      tab.groupDuration = durInt;
    } else {
      if (tab.isPreFilledFromExisting) {
        tab.isPreFilledFromExisting = false;
        tab.existingGroupDoc = null;
      }
    }
  }

  void _addParticipantToGroupTab(
    GroupTabEntry tab,
    ParticipantModel p,
    AppState appState,
  ) {
    if (!tab.selectedGroupParticipants.any(
      (gp) => gp.participantId == p.participantId,
    )) {
      tab.selectedGroupParticipants.add(p);
      _checkGroupMatchAndAutoFill(tab, appState);
      setState(() {});
    }
  }

  void _removeParticipantFromGroupTab(
    GroupTabEntry tab,
    String participantId,
    AppState appState,
  ) {
    tab.selectedGroupParticipants.removeWhere(
      (item) => item.participantId == participantId,
    );
    _checkGroupMatchAndAutoFill(tab, appState);
    setState(() {});
  }

  void _addProgramNameToTab(SingleTabEntry tab, String name) {
    final clean = name.trim().toUpperCase();
    if (clean.isNotEmpty && !tab.selectedProgramNames.contains(clean)) {
      setState(() {
        tab.selectedProgramNames.add(clean);
        tab.programDurations[clean] = 10;
        tab.customController.clear();
      });
    }
  }

  void _removeProgramNameFromTab(SingleTabEntry tab, String name) {
    if (tab.selectedProgramNames.length > 1) {
      setState(() {
        tab.selectedProgramNames.remove(name);
        tab.programDurations.remove(name);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'At least 1 program name must be selected for this entry.',
          ),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  void _toggleSuggestionForTab(SingleTabEntry tab, String itemName) {
    setState(() {
      if (tab.selectedProgramNames.contains(itemName)) {
        if (tab.selectedProgramNames.length > 1) {
          tab.selectedProgramNames.remove(itemName);
          tab.programDurations.remove(itemName);
        }
      } else {
        tab.selectedProgramNames.add(itemName);
        tab.programDurations[itemName] = 10;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDark = appState.isDarkMode;
    final realParticipants = appState.realParticipants;

    final isGroup = _programType == 'group';
    final totalTabs = isGroup ? _groupTabs.length : _singleTabs.length;
    _activeTabIndex = _activeTabIndex.clamp(0, totalTabs - 1);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.92,
        ),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(
            color: isDark
                ? AppColors.glassBorderDark
                : AppColors.glassBorderLight,
          ),
        ),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sheet Handle bar
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

            // Header Title Bar & Close
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (isGroup ? AppColors.secondary : AppColors.primary)
                        .withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isGroup ? Icons.group_add_rounded : Icons.note_add_rounded,
                    color: isGroup ? AppColors.secondary : AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isGroup
                            ? 'Register Group Program'
                            : 'Register Meelad Program',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: isDark
                              ? AppColors.textLight
                              : AppColors.textDark,
                        ),
                      ),
                      Text(
                        isGroup
                            ? 'Batch register group items with auto-detect existing entries.'
                            : 'Batch register student items with auto-detect existing entries.',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.subtextLight
                              : AppColors.subtextDark,
                        ),
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

            // --- CHROME STYLE TAB BAR WITH "+ Add Entry Tab" BUTTON ---
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ...List.generate(totalTabs, (idx) {
                    final isSel = _activeTabIndex == idx;
                    final tabLabel = 'Tab ${idx + 1}';

                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => setState(() => _activeTabIndex = idx),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSel
                                  ? (isGroup
                                        ? AppColors.secondary
                                        : AppColors.primary)
                                  : (isDark
                                        ? const Color(0xFF1E293B)
                                        : const Color(0xFFF1F5F9)),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSel
                                    ? (isGroup
                                          ? AppColors.secondary
                                          : AppColors.primary)
                                    : (isDark
                                          ? const Color(0xFF334155)
                                          : const Color(0xFFE2E8F0)),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isGroup
                                      ? Icons.group_rounded
                                      : Icons.person_rounded,
                                  size: 15,
                                  color: isSel
                                      ? Colors.white
                                      : (isDark
                                            ? AppColors.subtextLight
                                            : AppColors.subtextDark),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  tabLabel,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isSel
                                        ? Colors.white
                                        : (isDark
                                              ? AppColors.textLight
                                              : AppColors.textDark),
                                  ),
                                ),
                                if (totalTabs > 1 &&
                                    widget.programToEdit == null) ...[
                                  const SizedBox(width: 8),
                                  InkWell(
                                    onTap: () => _removeTab(idx),
                                    borderRadius: BorderRadius.circular(10),
                                    child: Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: Icon(
                                        Icons.close_rounded,
                                        size: 14,
                                        color: isSel
                                            ? Colors.white70
                                            : Colors.redAccent,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),

                  if (widget.programToEdit == null) ...[
                    ElevatedButton.icon(
                      onPressed: _addNewTab,
                      icon: const Icon(Icons.add_rounded, size: 16),
                      label: Text(
                        '+ Add Entry Tab',
                        style: GoogleFonts.poppins(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),

            // --- TAB CONTENT WORKSPACE ---
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: isGroup
                    ? _buildGroupTabContent(
                        context,
                        appState,
                        realParticipants,
                        _groupTabs[_activeTabIndex],
                      )
                    : _buildSingleTabContent(
                        context,
                        appState,
                        realParticipants,
                        _singleTabs[_activeTabIndex],
                      ),
              ),
            ),

            const SizedBox(height: 16),

            // --- SAVE ALL TABS BUTTON ---
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {
                  _saveAllTabs(context, appState);
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.save_rounded, size: 20),
                label: Text(
                  widget.programToEdit != null
                      ? 'Save Program Changes'
                      : (isGroup
                            ? 'Save All $totalTabs Group Program Tab(s)'
                            : 'Save All $totalTabs Single Participant Tab(s)'),
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isGroup
                      ? AppColors.secondary
                      : AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- SINGLE PROGRAM TAB CONTENT (1 Student, Multiple Programs) ---
  Widget _buildSingleTabContent(
    BuildContext context,
    AppState appState,
    List<ParticipantModel> realParticipants,
    SingleTabEntry tab,
  ) {
    final isDark = appState.isDarkMode;

    final matchingParticipants = realParticipants.where((p) {
      final q = tab.searchQuery.trim().toLowerCase();
      return q.isEmpty ||
          p.name.toLowerCase().contains(q) ||
          p.participantId.toLowerCase().contains(q) ||
          p.studentClass.toLowerCase().contains(q) ||
          p.category.toLowerCase().contains(q);
    }).toList();

    final Map<String, int> selectedInOtherTabs = {};
    for (int i = 0; i < _singleTabs.length; i++) {
      final t = _singleTabs[i];
      if (t != tab && t.selectedParticipant != null) {
        selectedInOtherTabs[t.selectedParticipant!.participantId] = i + 1;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Participant (Student)',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: isDark ? AppColors.textLight : AppColors.textDark,
          ),
        ),
        const SizedBox(height: 6),

        // Participant Picker Search Box & Dropdown
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            ),
          ),
          child: Column(
            children: [
              TextField(
                onChanged: (val) => setState(() => tab.searchQuery = val),
                decoration: InputDecoration(
                  hintText: tab.selectedParticipant != null
                      ? '${tab.selectedParticipant!.name} (${tab.selectedParticipant!.studentClass} - Div ${tab.selectedParticipant!.division})'
                      : 'Search participant name, class or ID...',
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: tab.selectedParticipant != null
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: tab.selectedParticipant != null
                        ? AppColors.primary
                        : (isDark
                              ? AppColors.subtextLight
                              : AppColors.subtextDark),
                  ),
                  prefixIcon: const Icon(Icons.person_search_rounded, size: 20),
                  suffixIcon: tab.selectedParticipant != null
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () =>
                              setState(() => tab.selectedParticipant = null),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 14,
                  ),
                ),
              ),

              if (tab.selectedParticipant == null &&
                  matchingParticipants.isNotEmpty) ...[
                const Divider(height: 1),
                Container(
                  constraints: const BoxConstraints(maxHeight: 160),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: matchingParticipants.length,
                    separatorBuilder: (_, _) =>
                        const Divider(height: 1, color: Colors.white10),
                    itemBuilder: (context, idx) {
                      final p = matchingParticipants[idx];
                      final otherTabNum = selectedInOtherTabs[p.participantId];
                      final isSelectedInOtherTab = otherTabNum != null;

                      return ListTile(
                        dense: true,
                        title: Text(
                          p.name,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: isSelectedInOtherTab
                                ? Colors.grey
                                : (isDark
                                      ? AppColors.textLight
                                      : AppColors.textDark),
                          ),
                        ),
                        subtitle: Text(
                          isSelectedInOtherTab
                              ? '🚫 Already selected in Tab $otherTabNum'
                              : '${p.studentClass} (Div ${p.division}) • ${p.category} • ${p.participantId}',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: isSelectedInOtherTab
                                ? Colors.redAccent
                                : AppColors.primary,
                            fontWeight: isSelectedInOtherTab
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        trailing: Icon(
                          isSelectedInOtherTab
                              ? Icons.block_rounded
                              : Icons.check_circle_outline_rounded,
                          size: 18,
                          color: isSelectedInOtherTab
                              ? Colors.redAccent
                              : AppColors.primary,
                        ),
                        onTap: () {
                          if (isSelectedInOtherTab) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '"${p.name}" is already selected in Tab $otherTabNum! A student can only be selected in 1 single tab.',
                                ),
                                backgroundColor: AppColors.error,
                              ),
                            );
                            return;
                          }
                          _selectSingleParticipant(tab, p, appState);
                        },
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),

        if (tab.selectedParticipant != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withAlpha(50)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 4,
                    children: [
                      Text(
                        'Class: ${tab.selectedParticipant!.studentClass}',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          color: isDark
                              ? AppColors.textLight
                              : AppColors.textDark,
                        ),
                      ),
                      Text(
                        'Div: ${tab.selectedParticipant!.division}',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          color: isDark
                              ? AppColors.textLight
                              : AppColors.textDark,
                        ),
                      ),
                      Text(
                        'Category: ${tab.selectedParticipant!.category}',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        'ID: ${tab.selectedParticipant!.participantId}',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: isDark
                              ? AppColors.subtextLight
                              : AppColors.subtextDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],

        // Pre-filled existing registered programs banner pill
        if (tab.isPreFilledFromExisting && tab.selectedParticipant != null) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withAlpha(20),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF10B981).withAlpha(70)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.auto_awesome_rounded,
                  color: Color(0xFF10B981),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Auto-filled from existing registered programs (${tab.selectedProgramNames.length} items found for ${tab.selectedParticipant!.name})',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF10B981),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 20),

        // Multiple Program Names Selection
        Text(
          'Multiple Program Names for ${tab.selectedParticipant != null ? tab.selectedParticipant!.name : "Student"}',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: isDark ? AppColors.textLight : AppColors.textDark,
          ),
        ),
        const SizedBox(height: 10),

        if (tab.selectedProgramNames.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tab.selectedProgramNames.map((pName) {
              final isExisting = tab.existingProgramsMap.containsKey(
                pName.toUpperCase(),
              );

              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isExisting
                      ? const Color(0xFF10B981).withAlpha(25)
                      : (isDark
                            ? AppColors.primary.withAlpha(30)
                            : const Color(0xFFEBF5FF)),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isExisting
                        ? const Color(0xFF10B981)
                        : (isDark
                              ? AppColors.primary
                              : const Color(0xFF60A5FA)),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isExisting) ...[
                      const Icon(
                        Icons.edit_rounded,
                        size: 12,
                        color: Color(0xFF10B981),
                      ),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      pName,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: isExisting
                            ? const Color(0xFF10B981)
                            : (isDark
                                  ? AppColors.textLight
                                  : const Color(0xFF2563EB)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => _removeProgramNameFromTab(tab, pName),
                      child: Icon(
                        Icons.close_rounded,
                        size: 16,
                        color: isExisting
                            ? const Color(0xFF10B981)
                            : (isDark
                                  ? AppColors.subtextLight
                                  : const Color(0xFF2563EB)),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
        ],

        Row(
          children: [
            Expanded(
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.surfaceDark
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFF38BDF8),
                    width: 1.5,
                  ),
                ),
                child: TextField(
                  controller: tab.customController,
                  onSubmitted: (val) => _addProgramNameToTab(tab, val),
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: isDark ? AppColors.textLight : AppColors.textDark,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Type custom program name...',
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.subtextLight
                          : AppColors.subtextDark,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () =>
                  _addProgramNameToTab(tab, tab.customController.text),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 1,
              ),
              child: Text(
                'Add',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        Text(
          'Preset Suggestions',
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.subtextLight : AppColors.subtextDark,
          ),
        ),
        const SizedBox(height: 8),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _presetSingleItems.map((sug) {
            final isSelected = tab.selectedProgramNames.contains(sug);
            return InkWell(
              onTap: () => _toggleSuggestionForTab(tab, sug),
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark
                            ? AppColors.primary.withAlpha(30)
                            : const Color(0xFFE0F2FE))
                      : (isDark
                            ? AppColors.surfaceDark
                            : const Color(0xFFF1F5F9)),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? (isDark ? AppColors.primary : const Color(0xFF38BDF8))
                        : Colors.transparent,
                    width: 1.2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isSelected) ...[
                      const Icon(
                        Icons.check_rounded,
                        size: 14,
                        color: Color(0xFF0284C7),
                      ),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      sug,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w500,
                        color: isSelected
                            ? (isDark
                                  ? AppColors.textLight
                                  : const Color(0xFF0284C7))
                            : (isDark
                                  ? AppColors.textLight
                                  : AppColors.textDark),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 22),

        Text(
          'Set Program Durations (Minutes)',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: isDark ? AppColors.textLight : AppColors.textDark,
          ),
        ),
        const SizedBox(height: 10),

        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: tab.selectedProgramNames.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, idx) {
            final pName = tab.selectedProgramNames[idx];
            final currentDur = tab.programDurations[pName] ?? 10;
            final isExisting = tab.existingProgramsMap.containsKey(
              pName.toUpperCase(),
            );

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isExisting
                      ? const Color(0xFF10B981).withAlpha(80)
                      : (isDark
                            ? const Color(0xFF334155)
                            : const Color(0xFFE2E8F0)),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color:
                          (isExisting
                                  ? const Color(0xFF10B981)
                                  : AppColors.primary)
                              .withAlpha(20),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.timer_outlined,
                      size: 18,
                      color: isExisting
                          ? const Color(0xFF10B981)
                          : AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pName,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: isDark
                                ? AppColors.textLight
                                : AppColors.textDark,
                          ),
                        ),
                        if (isExisting)
                          Text(
                            'Registered in festival schedule (Will update)',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: const Color(0xFF10B981),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.remove_circle_outline_rounded,
                          size: 20,
                          color: isExisting
                              ? const Color(0xFF10B981)
                              : AppColors.primary,
                        ),
                        onPressed: () {
                          if (currentDur > 2) {
                            setState(
                              () =>
                                  tab.programDurations[pName] = currentDur - 1,
                            );
                          }
                        },
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color:
                              (isExisting
                                      ? const Color(0xFF10B981)
                                      : AppColors.primary)
                                  .withAlpha(25),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$currentDur mins',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: isExisting
                                ? const Color(0xFF10B981)
                                : AppColors.primary,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.add_circle_outline_rounded,
                          size: 20,
                          color: isExisting
                              ? const Color(0xFF10B981)
                              : AppColors.primary,
                        ),
                        onPressed: () {
                          setState(
                            () => tab.programDurations[pName] = currentDur + 1,
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),

        if (widget.programToEdit != null) ...[
          const SizedBox(height: 16),
          Text(
            'Program Status:',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: isDark ? AppColors.textLight : AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.primary.withAlpha(80),
                width: 1.2,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _editingStatus,
                isExpanded: true,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: AppColors.primary,
                ),
                dropdownColor: isDark ? AppColors.cardDark : Colors.white,
                items: const [
                  DropdownMenuItem(
                    value: 'pending',
                    child: Text('PENDING (Scheduled)'),
                  ),
                  DropdownMenuItem(
                    value: 'live',
                    child: Text('LIVE (On Stage)'),
                  ),
                  DropdownMenuItem(
                    value: 'completed',
                    child: Text('COMPLETED'),
                  ),
                  DropdownMenuItem(
                    value: 'cancelled',
                    child: Text('CANCELLED'),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _editingStatus = val;
                    });
                  }
                },
              ),
            ),
          ),
        ],
      ],
    );
  }

  // --- GROUP PROGRAM TAB CONTENT (1 Program Name, Multiple Students) ---
  Widget _buildGroupTabContent(
    BuildContext context,
    AppState appState,
    List<ParticipantModel> realParticipants,
    GroupTabEntry tab,
  ) {
    final isDark = appState.isDarkMode;

    final matchingParticipants = realParticipants.where((p) {
      final q = tab.searchQuery.trim().toLowerCase();
      return q.isEmpty ||
          p.name.toLowerCase().contains(q) ||
          p.participantId.toLowerCase().contains(q) ||
          p.studentClass.toLowerCase().contains(q) ||
          p.category.toLowerCase().contains(q);
    }).toList();

    final currentPName = tab.programNameController.text.trim().toUpperCase();
    final Map<String, int> studentSameProgramOtherTabs = {};
    if (currentPName.isNotEmpty) {
      for (int i = 0; i < _groupTabs.length; i++) {
        final otherTab = _groupTabs[i];
        if (otherTab != tab) {
          final otherPName = otherTab.programNameController.text
              .trim()
              .toUpperCase();
          if (otherPName == currentPName) {
            for (var gp in otherTab.selectedGroupParticipants) {
              studentSameProgramOtherTabs[gp.participantId] = i + 1;
            }
          }
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Group Program Name (1 Item)',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: isDark ? AppColors.textLight : AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),

        Container(
          height: 48,
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.secondary, width: 1.5),
          ),
          child: TextField(
            controller: tab.programNameController,
            onChanged: (val) => setState(() {}),
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textLight : AppColors.textDark,
            ),
            decoration: InputDecoration(
              hintText: 'Enter group program name (e.g. DAFFA SONG)...',
              hintStyle: GoogleFonts.poppins(
                fontSize: 12,
                color: isDark ? AppColors.subtextLight : AppColors.subtextDark,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Preset Suggestions for Group Items
        Text(
          'Preset Group Items',
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.subtextLight : AppColors.subtextDark,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _presetGroupItems.map((gItem) {
            final isSelected =
                tab.programNameController.text.trim().toUpperCase() == gItem;
            return InkWell(
              onTap: () {
                setState(() {
                  tab.programNameController.text = gItem;
                });
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.secondary.withAlpha(30)
                      : (isDark
                            ? AppColors.surfaceDark
                            : const Color(0xFFF1F5F9)),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.secondary
                        : Colors.transparent,
                    width: 1.2,
                  ),
                ),
                child: Text(
                  gItem,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected
                        ? AppColors.secondary
                        : (isDark ? AppColors.textLight : AppColors.textDark),
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 22),

        // Group Participants Selection
        Text(
          'Select Group Participants (2 or more)',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: isDark ? AppColors.textLight : AppColors.textDark,
          ),
        ),
        const SizedBox(height: 6),

        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            ),
          ),
          child: Column(
            children: [
              TextField(
                onChanged: (val) => setState(() => tab.searchQuery = val),
                decoration: InputDecoration(
                  hintText: 'Search & add student to group...',
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.subtextLight
                        : AppColors.subtextDark,
                  ),
                  prefixIcon: const Icon(
                    Icons.group_add_rounded,
                    size: 20,
                    color: AppColors.secondary,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 14,
                  ),
                ),
              ),

              if (matchingParticipants.isNotEmpty) ...[
                const Divider(height: 1),
                Container(
                  constraints: const BoxConstraints(maxHeight: 160),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: matchingParticipants.length,
                    separatorBuilder: (_, _) =>
                        const Divider(height: 1, color: Colors.white10),
                    itemBuilder: (context, idx) {
                      final p = matchingParticipants[idx];
                      final isAlreadyInGroup = tab.selectedGroupParticipants
                          .any((gp) => gp.participantId == p.participantId);
                      final inSameProgramOtherTabNum =
                          studentSameProgramOtherTabs[p.participantId];
                      final isSameProgramDuplicate =
                          inSameProgramOtherTabNum != null;

                      return ListTile(
                        dense: true,
                        title: Text(
                          p.name,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: isSameProgramDuplicate
                                ? Colors.grey
                                : (isDark
                                      ? AppColors.textLight
                                      : AppColors.textDark),
                          ),
                        ),
                        subtitle: Text(
                          isSameProgramDuplicate
                              ? '🚫 Already in "$currentPName" in Tab $inSameProgramOtherTabNum'
                              : '${p.studentClass} (Div ${p.division}) • ${p.category} • ${p.participantId}',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: isSameProgramDuplicate
                                ? Colors.redAccent
                                : AppColors.secondary,
                            fontWeight: isSameProgramDuplicate
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        trailing: isAlreadyInGroup
                            ? const Icon(
                                Icons.check_circle_rounded,
                                size: 18,
                                color: AppColors.success,
                              )
                            : Icon(
                                isSameProgramDuplicate
                                    ? Icons.block_rounded
                                    : Icons.add_circle_outline_rounded,
                                size: 18,
                                color: isSameProgramDuplicate
                                    ? Colors.redAccent
                                    : AppColors.secondary,
                              ),
                        onTap: () {
                          if (isSameProgramDuplicate) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '"${p.name}" is already added to "$currentPName" in Tab $inSameProgramOtherTabNum! Cannot duplicate student in same group item.',
                                ),
                                backgroundColor: AppColors.error,
                              ),
                            );
                            return;
                          }
                          _addParticipantToGroupTab(tab, p, appState);
                        },
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Selected Group Participants Tag Chips
        if (tab.selectedGroupParticipants.isNotEmpty) ...[
          Text(
            'Selected Group Members (${tab.selectedGroupParticipants.length}):',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tab.selectedGroupParticipants.map((gp) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withAlpha(20),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.secondary.withAlpha(80)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${gp.name} (${gp.studentClass}-${gp.division})',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.textLight
                            : AppColors.textDark,
                      ),
                    ),
                    const SizedBox(width: 6),
                    InkWell(
                      onTap: () => _removeParticipantFromGroupTab(
                        tab,
                        gp.participantId,
                        appState,
                      ),
                      child: const Icon(
                        Icons.cancel_rounded,
                        size: 16,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
        ],

        // Pre-filled existing registered group banner pill
        if (tab.isPreFilledFromExisting) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withAlpha(20),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF10B981).withAlpha(70)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.auto_awesome_rounded,
                  color: Color(0xFF10B981),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Auto-filled existing registered group item "${tab.programNameController.text}"',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF10B981),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
        ],

        // Group Performance Duration
        Text(
          'Set Group Performance Duration (Minutes)',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: isDark ? AppColors.textLight : AppColors.textDark,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: tab.isPreFilledFromExisting
                  ? const Color(0xFF10B981).withAlpha(80)
                  : (isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFE2E8F0)),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color:
                      (tab.isPreFilledFromExisting
                              ? const Color(0xFF10B981)
                              : AppColors.secondary)
                          .withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.timer_outlined,
                  size: 18,
                  color: tab.isPreFilledFromExisting
                      ? const Color(0xFF10B981)
                      : AppColors.secondary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tab.programNameController.text.isEmpty
                          ? 'GROUP PROGRAM'
                          : tab.programNameController.text,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: isDark
                            ? AppColors.textLight
                            : AppColors.textDark,
                      ),
                    ),
                    if (tab.isPreFilledFromExisting)
                      Text(
                        'Registered group item (Will update)',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: const Color(0xFF10B981),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.remove_circle_outline_rounded,
                      size: 20,
                      color: tab.isPreFilledFromExisting
                          ? const Color(0xFF10B981)
                          : AppColors.secondary,
                    ),
                    onPressed: () {
                      if (tab.groupDuration > 2) {
                        setState(() => tab.groupDuration--);
                      }
                    },
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color:
                          (tab.isPreFilledFromExisting
                                  ? const Color(0xFF10B981)
                                  : AppColors.secondary)
                              .withAlpha(25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${tab.groupDuration} mins',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: tab.isPreFilledFromExisting
                            ? const Color(0xFF10B981)
                            : AppColors.secondary,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.add_circle_outline_rounded,
                      size: 20,
                      color: tab.isPreFilledFromExisting
                          ? const Color(0xFF10B981)
                          : AppColors.secondary,
                    ),
                    onPressed: () {
                      setState(() => tab.groupDuration++);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),

        if (widget.programToEdit != null) ...[
          const SizedBox(height: 16),
          Text(
            'Program Status:',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: isDark ? AppColors.textLight : AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.primary.withAlpha(80),
                width: 1.2,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _editingStatus,
                isExpanded: true,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: AppColors.primary,
                ),
                dropdownColor: isDark ? AppColors.cardDark : Colors.white,
                items: const [
                  DropdownMenuItem(
                    value: 'pending',
                    child: Text('PENDING (Scheduled)'),
                  ),
                  DropdownMenuItem(
                    value: 'live',
                    child: Text('LIVE (On Stage)'),
                  ),
                  DropdownMenuItem(
                    value: 'completed',
                    child: Text('COMPLETED'),
                  ),
                  DropdownMenuItem(
                    value: 'cancelled',
                    child: Text('CANCELLED'),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _editingStatus = val;
                    });
                  }
                },
              ),
            ),
          ),
        ],
      ],
    );
  }

  // --- SAVE ALL TABS METHOD ---
  Future<void> _saveAllTabs(BuildContext context, AppState appState) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final nowStr = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());
    int createdCount = 0;
    int updatedCount = 0;

    if (_programType == 'group') {
      for (int tIdx = 0; tIdx < _groupTabs.length; tIdx++) {
        final tab = _groupTabs[tIdx];
        if (tab.selectedGroupParticipants.length < 2) {
          messenger.showSnackBar(
            SnackBar(
              content: Text(
                'Tab ${tIdx + 1}: Please select at least 2 students for group program.',
              ),
              backgroundColor: AppColors.error,
            ),
          );
          return;
        }

        final pName = tab.programNameController.text.trim().toUpperCase();
        if (pName.isEmpty) {
          messenger.showSnackBar(
            SnackBar(
              content: Text(
                'Tab ${tIdx + 1}: Please enter a group program name.',
              ),
              backgroundColor: AppColors.error,
            ),
          );
          return;
        }

        final combinedNames = tab.selectedGroupParticipants
            .map((p) => p.name)
            .join(', ');
        final combinedIds = tab.selectedGroupParticipants
            .map((p) => p.participantId)
            .join(', ');
        final firstP = tab.selectedGroupParticipants.first;

        // Check if updating an existing group program
        final existingGroupDoc =
            tab.existingGroupDoc ??
            appState.realPrograms.firstWhere(
              (p) =>
                  p.programType.toLowerCase() == 'group' &&
                  p.programName.trim().toUpperCase() == pName &&
                  p.participantId
                      .split(', ')
                      .any((id) => combinedIds.contains(id.trim())),
              orElse: () => ProgramModel(
                programId: '',
                participantName: '',
                participantId: '',
                studentClass: '',
                division: '',
                category: '',
                programName: '',
                programType: '',
                duration: '',
                order: 0,
                madrasaId: '',
                createdAt: '',
              ),
            );

        if (existingGroupDoc.programId.isNotEmpty) {
          final updatedGroupProg = ProgramModel(
            programId: existingGroupDoc.programId,
            participantName: combinedNames,
            participantId: combinedIds,
            studentClass: firstP.studentClass,
            division: firstP.division,
            category: firstP.category,
            programName: pName,
            programType: 'group',
            startTime: existingGroupDoc.startTime,
            endTime: existingGroupDoc.endTime,
            duration: '${tab.groupDuration} mins',
            status: widget.programToEdit != null
                ? _editingStatus
                : existingGroupDoc.status,
            order: existingGroupDoc.order,
            madrasaId: appState.madrasaId,
            createdAt: existingGroupDoc.createdAt,
          );

          await appState.updateProgramInFirestore(updatedGroupProg);
          updatedCount++;
        } else {
          final baseOrder = appState.realPrograms.length;
          final progId = ProgramModel.generateNextProgramId(baseOrder);

          final newGroupProgramDoc = ProgramModel(
            programId: progId,
            participantName: combinedNames,
            participantId: combinedIds,
            studentClass: firstP.studentClass,
            division: firstP.division,
            category: firstP.category,
            programName: pName,
            programType: 'group',
            startTime: 'TBD',
            endTime: 'TBD',
            duration: '${tab.groupDuration} mins',
            status: 'pending',
            order: baseOrder + 1,
            madrasaId: appState.madrasaId,
            createdAt: nowStr,
          );

          await appState.addProgramToFirestore(newGroupProgramDoc);
          createdCount++;
        }
      }

      navigator.pop();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            updatedCount > 0
                ? '✨ Saved $updatedCount updated & $createdCount new Group Program(s) across ${_groupTabs.length} tab(s)!'
                : '✨ Successfully created $createdCount Group Program(s) across ${_groupTabs.length} tab(s)!',
          ),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      for (int tIdx = 0; tIdx < _singleTabs.length; tIdx++) {
        final tab = _singleTabs[tIdx];

        if (tab.selectedParticipant == null) {
          messenger.showSnackBar(
            SnackBar(
              content: Text(
                'Tab ${tIdx + 1}: Please select a participant student from the list.',
              ),
              backgroundColor: AppColors.error,
            ),
          );
          return;
        }

        if (tab.selectedProgramNames.isEmpty) {
          messenger.showSnackBar(
            SnackBar(
              content: Text(
                'Tab ${tIdx + 1}: Please select at least 1 program name.',
              ),
              backgroundColor: AppColors.error,
            ),
          );
          return;
        }

        final pId = tab.selectedParticipant!.participantId;
        final baseOrder = appState.realPrograms.length;

        for (int i = 0; i < tab.selectedProgramNames.length; i++) {
          final pName = tab.selectedProgramNames[i];
          final pNameUpper = pName.trim().toUpperCase();
          final durInt = tab.programDurations[pName] ?? 10;

          // Check if this single program already exists for this student
          final existingSingleDoc =
              tab.existingProgramsMap[pNameUpper] ??
              appState.realPrograms.firstWhere(
                (p) =>
                    p.programType.toLowerCase() == 'single' &&
                    p.participantId.trim().toLowerCase() ==
                        pId.trim().toLowerCase() &&
                    p.programName.trim().toUpperCase() == pNameUpper,
                orElse: () => ProgramModel(
                  programId: '',
                  participantName: '',
                  participantId: '',
                  studentClass: '',
                  division: '',
                  category: '',
                  programName: '',
                  programType: '',
                  duration: '',
                  order: 0,
                  madrasaId: '',
                  createdAt: '',
                ),
              );

          if (existingSingleDoc.programId.isNotEmpty) {
            final updatedSingleProg = ProgramModel(
              programId: existingSingleDoc.programId,
              participantName: tab.selectedParticipant!.name,
              participantId: tab.selectedParticipant!.participantId,
              studentClass: tab.selectedParticipant!.studentClass,
              division: tab.selectedParticipant!.division,
              category: tab.selectedParticipant!.category,
              programName: pName,
              programType: 'single',
              startTime: existingSingleDoc.startTime,
              endTime: existingSingleDoc.endTime,
              duration: '$durInt mins',
              status: widget.programToEdit != null
                  ? _editingStatus
                  : existingSingleDoc.status,
              order: existingSingleDoc.order,
              madrasaId: appState.madrasaId,
              createdAt: existingSingleDoc.createdAt,
            );

            await appState.updateProgramInFirestore(updatedSingleProg);
            updatedCount++;
          } else {
            final progId = ProgramModel.generateNextProgramId(
              baseOrder + createdCount,
            );

            final newProgramDoc = ProgramModel(
              programId: progId,
              participantName: tab.selectedParticipant!.name,
              participantId: tab.selectedParticipant!.participantId,
              studentClass: tab.selectedParticipant!.studentClass,
              division: tab.selectedParticipant!.division,
              category: tab.selectedParticipant!.category,
              programName: pName,
              programType: 'single',
              startTime: 'TBD',
              endTime: 'TBD',
              duration: '$durInt mins',
              status: 'pending',
              order: baseOrder + createdCount + 1,
              madrasaId: appState.madrasaId,
              createdAt: nowStr,
            );

            await appState.addProgramToFirestore(newProgramDoc);
            createdCount++;
          }
        }
      }

      navigator.pop();

      messenger.showSnackBar(
        SnackBar(
          content: Text(
            updatedCount > 0
                ? '✨ Saved $updatedCount updated & $createdCount new Single Program(s) across ${_singleTabs.length} tab(s)!'
                : '✨ Successfully created $createdCount Single Program(s) across ${_singleTabs.length} student tab(s)!',
          ),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }
}
