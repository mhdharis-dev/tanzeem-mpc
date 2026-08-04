import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/models/participant_model.dart';
import '../../core/models/program_model.dart';
import '../../core/providers/app_state.dart';
import '../../core/theme/app_colors.dart';

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

  // Selected Participant state for 'single'
  ParticipantModel? _selectedParticipant;
  String _participantSearchQuery = '';

  // Selected Group Participants state for 'group'
  final List<ParticipantModel> _selectedGroupParticipants = [];
  int _groupDuration = 15;
  final TextEditingController _groupProgramNameController = TextEditingController(text: 'DAFFA SONG');

  // Selected Program Names and Per-Program Durations Map for 'single'
  final List<String> _selectedProgramNames = ['MEELAD SONG'];
  final Map<String, int> _programDurations = {'MEELAD SONG': 10};

  final TextEditingController _customProgramNameController = TextEditingController();

  // Preset Suggestions for Single Items
  final List<String> _presetSingleItems = [
    'MEELAD SONG',
    'QIRA\'AT RECITATION',
    'NA\'AT PRAISE',
    'ELOCUTION / SPEECH',
    'QASIDA SINGING',
    'ISLAMIC QUIZ',
    'CALLIGRAPHY',
  ];

  // Preset Suggestions for Group Items
  final List<String> _presetGroupItems = [
    'DAFFA SONG',
    'GROUP SONG',
    'KOLKALI',
    'DUFF MUTA',
    'BURDA RECITATION',
    'MAWLID SINGING',
    'GROUP DRAMA',
  ];

  @override
  void initState() {
    super.initState();
    _programType = widget.initialType.toLowerCase();

    if (widget.programToEdit != null) {
      final prog = widget.programToEdit!;
      _programType = prog.programType.toLowerCase();
      _editingStatus = prog.status.toLowerCase();
      _selectedProgramNames.clear();
      _selectedProgramNames.add(prog.programName);
      final initialDur = int.tryParse(prog.duration.split(' ')[0]) ?? 10;
      _programDurations[prog.programName] = initialDur;
      _groupDuration = initialDur;
      _groupProgramNameController.text = prog.programName;

      if (_programType == 'group') {
        final names = prog.participantName.split(', ');
        final ids = prog.participantId.split(', ');
        _selectedGroupParticipants.clear();
        for (int i = 0; i < names.length; i++) {
          final pId = i < ids.length ? ids[i] : 'PATC-00${i + 1}';
          _selectedGroupParticipants.add(
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
      } else {
        _selectedParticipant = ParticipantModel(
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
        );
      }
    }
  }

  @override
  void dispose() {
    _customProgramNameController.dispose();
    _groupProgramNameController.dispose();
    super.dispose();
  }

  void _addProgramName(String name) {
    final clean = name.trim().toUpperCase();
    if (clean.isNotEmpty && !_selectedProgramNames.contains(clean)) {
      setState(() {
        _selectedProgramNames.add(clean);
        _programDurations[clean] = 10;
        _customProgramNameController.clear();
      });
    }
  }

  void _removeProgramName(String name) {
    if (_selectedProgramNames.length > 1) {
      setState(() {
        _selectedProgramNames.remove(name);
        _programDurations.remove(name);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('At least 1 program name must be selected.'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  void _toggleSuggestion(String itemName) {
    setState(() {
      if (_selectedProgramNames.contains(itemName)) {
        if (_selectedProgramNames.length > 1) {
          _selectedProgramNames.remove(itemName);
          _programDurations.remove(itemName);
        }
      } else {
        _selectedProgramNames.add(itemName);
        _programDurations[itemName] = 10;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDark = appState.isDarkMode;

    final realParticipants = appState.realParticipants;

    // Filter real participants for search dropdown
    final matchingParticipants = realParticipants.where((p) {
      final q = _participantSearchQuery.trim().toLowerCase();
      return q.isEmpty ||
          p.name.toLowerCase().contains(q) ||
          p.participantId.toLowerCase().contains(q) ||
          p.studentClass.toLowerCase().contains(q) ||
          p.category.toLowerCase().contains(q);
    }).toList();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.90,
        ),
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

            // Header Title Bar
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.note_add_rounded, color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _programType == 'group' ? 'Register Group Program' : 'Register Meelad Program',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: isDark ? AppColors.textLight : AppColors.textDark,
                        ),
                      ),
                      Text(
                        _programType == 'group'
                            ? 'Select 2 or more participants for a single group item performance.'
                            : 'Register participant performance details for festival schedule.',
                        style: GoogleFonts.poppins(fontSize: 12, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
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

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_programType == 'single') ...[
                      // -------------------------------------------------------------
                      // CASE 1: SINGLE (1 Student, Multiple Programs)
                      // -------------------------------------------------------------
                      Text(
                        'Select Participant',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13, color: isDark ? AppColors.textLight : AppColors.textDark),
                      ),
                      const SizedBox(height: 6),

                      // Participant Picker Search Box & Dropdown
                      Container(
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          children: [
                            TextField(
                              onChanged: (val) => setState(() => _participantSearchQuery = val),
                              decoration: InputDecoration(
                                hintText: _selectedParticipant != null
                                    ? '${_selectedParticipant!.name} (${_selectedParticipant!.studentClass} - Div ${_selectedParticipant!.division})'
                                    : 'Search participant name, class or ID...',
                                hintStyle: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: _selectedParticipant != null ? FontWeight.bold : FontWeight.normal,
                                  color: _selectedParticipant != null
                                      ? AppColors.primary
                                      : (isDark ? AppColors.subtextLight : AppColors.subtextDark),
                                ),
                                prefixIcon: const Icon(Icons.person_search_rounded, size: 20),
                                suffixIcon: _selectedParticipant != null
                                    ? IconButton(
                                        icon: const Icon(Icons.clear_rounded, size: 18),
                                        onPressed: () => setState(() => _selectedParticipant = null),
                                      )
                                    : null,
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                              ),
                            ),

                            // Real Firestore Participant Results List
                            if (_selectedParticipant == null && matchingParticipants.isNotEmpty) ...[
                              const Divider(height: 1),
                              Container(
                                constraints: const BoxConstraints(maxHeight: 160),
                                child: ListView.separated(
                                  shrinkWrap: true,
                                  itemCount: matchingParticipants.length,
                                  separatorBuilder: (_, _) => const Divider(height: 1, color: Colors.white10),
                                  itemBuilder: (context, idx) {
                                    final p = matchingParticipants[idx];
                                    return ListTile(
                                      dense: true,
                                      title: Text(p.name, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13, color: isDark ? AppColors.textLight : AppColors.textDark)),
                                      subtitle: Text('${p.studentClass} (Div ${p.division}) • ${p.category} • ${p.participantId}', style: GoogleFonts.poppins(fontSize: 11, color: AppColors.primary)),
                                      trailing: const Icon(Icons.check_circle_outline_rounded, size: 18, color: AppColors.primary),
                                      onTap: () {
                                        setState(() {
                                          _selectedParticipant = p;
                                        });
                                      },
                                    );
                                  },
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      if (_selectedParticipant != null) ...[
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
                              const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Wrap(
                                  spacing: 12,
                                  runSpacing: 4,
                                  children: [
                                    Text('Class: ${_selectedParticipant!.studentClass}', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 11, color: isDark ? AppColors.textLight : AppColors.textDark)),
                                    Text('Div: ${_selectedParticipant!.division}', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 11, color: isDark ? AppColors.textLight : AppColors.textDark)),
                                    Text('Category: ${_selectedParticipant!.category}', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.primary)),
                                    Text('ID: ${_selectedParticipant!.participantId}', style: GoogleFonts.poppins(fontSize: 11, color: isDark ? AppColors.subtextLight : AppColors.subtextDark)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 22),

                      // Program Names Chip Input UI
                      Text(
                        'Program Names',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? AppColors.textLight : AppColors.textDark),
                      ),
                      const SizedBox(height: 10),

                      if (_selectedProgramNames.isNotEmpty) ...[
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _selectedProgramNames.map((pName) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.primary.withAlpha(30) : const Color(0xFFEBF5FF),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isDark ? AppColors.primary : const Color(0xFF60A5FA),
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    pName,
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: isDark ? AppColors.textLight : const Color(0xFF2563EB),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  InkWell(
                                    onTap: () => _removeProgramName(pName),
                                    child: Icon(
                                      Icons.close_rounded,
                                      size: 16,
                                      color: isDark ? AppColors.subtextLight : const Color(0xFF2563EB),
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
                                color: isDark ? AppColors.surfaceDark : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: const Color(0xFF38BDF8), width: 1.5),
                              ),
                              child: TextField(
                                controller: _customProgramNameController,
                                onSubmitted: (val) => _addProgramName(val),
                                style: GoogleFonts.poppins(fontSize: 13, color: isDark ? AppColors.textLight : AppColors.textDark),
                                decoration: InputDecoration(
                                  hintText: 'Type program name...',
                                  hintStyle: GoogleFonts.poppins(fontSize: 12, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () => _addProgramName(_customProgramNameController.text),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              elevation: 1,
                            ),
                            child: Text(
                              'Add',
                              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      Text(
                        'Suggestions',
                        style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
                      ),
                      const SizedBox(height: 8),

                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _presetSingleItems.map((sug) {
                          final isSelected = _selectedProgramNames.contains(sug);
                          return InkWell(
                            onTap: () => _toggleSuggestion(sug),
                            borderRadius: BorderRadius.circular(12),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? (isDark ? AppColors.primary.withAlpha(30) : const Color(0xFFE0F2FE))
                                    : (isDark ? AppColors.surfaceDark : const Color(0xFFF1F5F9)),
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
                                    const Icon(Icons.check_rounded, size: 14, color: Color(0xFF0284C7)),
                                    const SizedBox(width: 6),
                                  ],
                                  Text(
                                    sug,
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                      color: isSelected
                                          ? (isDark ? AppColors.textLight : const Color(0xFF0284C7))
                                          : (isDark ? AppColors.textLight : AppColors.textDark),
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
                        'Set Each Program\'s Duration (Minutes)',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13, color: isDark ? AppColors.textLight : AppColors.textDark),
                      ),
                      const SizedBox(height: 10),

                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _selectedProgramNames.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, idx) {
                          final pName = _selectedProgramNames[idx];
                          final currentDur = _programDurations[pName] ?? 10;

                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withAlpha(20),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.timer_outlined, size: 18, color: AppColors.primary),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    pName,
                                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12, color: isDark ? AppColors.textLight : AppColors.textDark),
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle_outline_rounded, size: 20, color: AppColors.primary),
                                      onPressed: () {
                                        if (currentDur > 2) {
                                          setState(() => _programDurations[pName] = currentDur - 1);
                                        }
                                      },
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withAlpha(25),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '$currentDur mins',
                                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primary),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.add_circle_outline_rounded, size: 20, color: AppColors.primary),
                                      onPressed: () {
                                        setState(() => _programDurations[pName] = currentDur + 1);
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ] else if (_programType == 'group') ...[
                      // -------------------------------------------------------------
                      // CASE 2: GROUP PROGRAM (Multiple Students, 1 Program Name)
                      // -------------------------------------------------------------
                      Text(
                        'Select Group Participants (2 or more)',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13, color: isDark ? AppColors.textLight : AppColors.textDark),
                      ),
                      const SizedBox(height: 6),

                      // Group Student Search & Selection Box
                      Container(
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          children: [
                            TextField(
                              onChanged: (val) => setState(() => _participantSearchQuery = val),
                              decoration: InputDecoration(
                                hintText: 'Search & add student to group...',
                                hintStyle: GoogleFonts.poppins(fontSize: 12, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
                                prefixIcon: const Icon(Icons.group_add_rounded, size: 20, color: AppColors.secondary),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                              ),
                            ),

                            if (matchingParticipants.isNotEmpty) ...[
                              const Divider(height: 1),
                              Container(
                                constraints: const BoxConstraints(maxHeight: 160),
                                child: ListView.separated(
                                  shrinkWrap: true,
                                  itemCount: matchingParticipants.length,
                                  separatorBuilder: (_, _) => const Divider(height: 1, color: Colors.white10),
                                  itemBuilder: (context, idx) {
                                    final p = matchingParticipants[idx];
                                    final isAlreadyInGroup = _selectedGroupParticipants.any((gp) => gp.participantId == p.participantId);
                                    return ListTile(
                                      dense: true,
                                      title: Text(p.name, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13, color: isDark ? AppColors.textLight : AppColors.textDark)),
                                      subtitle: Text('${p.studentClass} (Div ${p.division}) • ${p.category} • ${p.participantId}', style: GoogleFonts.poppins(fontSize: 11, color: AppColors.secondary)),
                                      trailing: isAlreadyInGroup
                                          ? const Icon(Icons.check_circle_rounded, size: 18, color: AppColors.success)
                                          : const Icon(Icons.add_circle_outline_rounded, size: 18, color: AppColors.secondary),
                                      onTap: () {
                                        if (!isAlreadyInGroup) {
                                          setState(() {
                                            _selectedGroupParticipants.add(p);
                                          });
                                        }
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

                      // Selected Group Participants Tag Chips Display
                      if (_selectedGroupParticipants.isNotEmpty) ...[
                        Text(
                          'Selected Group Members (${_selectedGroupParticipants.length}):',
                          style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.secondary),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _selectedGroupParticipants.map((gp) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                                    style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: isDark ? AppColors.textLight : AppColors.textDark),
                                  ),
                                  const SizedBox(width: 6),
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        _selectedGroupParticipants.removeWhere((item) => item.participantId == gp.participantId);
                                      });
                                    },
                                    child: const Icon(Icons.cancel_rounded, size: 16, color: AppColors.secondary),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // 1 Program Name Input for Group Performance
                      Text(
                        'Group Program Name (1 Item)',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? AppColors.textLight : AppColors.textDark),
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
                          controller: _groupProgramNameController,
                          style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? AppColors.textLight : AppColors.textDark),
                          decoration: InputDecoration(
                            hintText: 'Enter group program name (e.g. DAFFA SONG)...',
                            hintStyle: GoogleFonts.poppins(fontSize: 12, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Preset Suggestions for Group Items
                      Text(
                        'Preset Group Items',
                        style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _presetGroupItems.map((gItem) {
                          final isSelected = _groupProgramNameController.text.trim().toUpperCase() == gItem;
                          return InkWell(
                            onTap: () {
                              setState(() {
                                _groupProgramNameController.text = gItem;
                              });
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.secondary.withAlpha(30) : (isDark ? AppColors.surfaceDark : const Color(0xFFF1F5F9)),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: isSelected ? AppColors.secondary : Colors.transparent, width: 1.2),
                              ),
                              child: Text(
                                gItem,
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  color: isSelected ? AppColors.secondary : (isDark ? AppColors.textLight : AppColors.textDark),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 20),

                      // Group Performance Duration Controller
                      Text(
                        'Set Group Performance Duration (Minutes)',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13, color: isDark ? AppColors.textLight : AppColors.textDark),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.secondary.withAlpha(20),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.timer_outlined, size: 18, color: AppColors.secondary),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _groupProgramNameController.text.isEmpty ? 'GROUP PROGRAM' : _groupProgramNameController.text,
                                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12, color: isDark ? AppColors.textLight : AppColors.textDark),
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline_rounded, size: 20, color: AppColors.secondary),
                                  onPressed: () {
                                    if (_groupDuration > 2) {
                                      setState(() => _groupDuration--);
                                    }
                                  },
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.secondary.withAlpha(25),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '$_groupDuration mins',
                                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.secondary),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline_rounded, size: 20, color: AppColors.secondary),
                                  onPressed: () {
                                    setState(() => _groupDuration++);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],

                    if (widget.programToEdit != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Program Status:',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13, color: isDark ? AppColors.textLight : AppColors.textDark),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.cardDark : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.primary.withAlpha(80), width: 1.2),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _editingStatus,
                            isExpanded: true,
                            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary),
                            dropdownColor: isDark ? AppColors.cardDark : Colors.white,
                            items: const [
                              DropdownMenuItem(value: 'pending', child: Text('PENDING (Scheduled)')),
                              DropdownMenuItem(value: 'live', child: Text('LIVE (On Stage)')),
                              DropdownMenuItem(value: 'completed', child: Text('COMPLETED')),
                              DropdownMenuItem(value: 'cancelled', child: Text('CANCELLED')),
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

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Save Program Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () async {
                  if (_programType == 'group') {
                    if (_selectedGroupParticipants.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select at least 2 students for group program'), backgroundColor: AppColors.error),
                      );
                      return;
                    }

                    final pName = _groupProgramNameController.text.trim().toUpperCase();
                    if (pName.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter a group program name'), backgroundColor: AppColors.error),
                      );
                      return;
                    }

                    final combinedNames = _selectedGroupParticipants.map((p) => p.name).join(', ');
                    final combinedIds = _selectedGroupParticipants.map((p) => p.participantId).join(', ');
                    final firstP = _selectedGroupParticipants.first;

                    if (widget.programToEdit != null) {
                      final updatedProg = ProgramModel(
                        programId: widget.programToEdit!.programId,
                        participantName: combinedNames,
                        participantId: combinedIds,
                        studentClass: firstP.studentClass,
                        division: firstP.division,
                        category: firstP.category,
                        programName: pName,
                        programType: 'group',
                        startTime: widget.programToEdit!.startTime,
                        endTime: widget.programToEdit!.endTime,
                        duration: '$_groupDuration mins',
                        status: _editingStatus,
                        order: widget.programToEdit!.order,
                        madrasaId: appState.madrasaId,
                        createdAt: widget.programToEdit!.createdAt,
                      );

                      await appState.updateProgramInFirestore(updatedProg);
                      if (!context.mounted) return;
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Group Program ${updatedProg.programId} ($pName) updated successfully!'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                      return;
                    }

                    final nowStr = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());
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
                      duration: '$_groupDuration mins',
                      status: 'pending',
                      order: baseOrder + 1,
                      madrasaId: appState.madrasaId,
                      createdAt: nowStr,
                    );

                    await appState.addProgramToFirestore(newGroupProgramDoc);
                    if (!context.mounted) return;
                    Navigator.of(context).pop();

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Group Program $progId ($pName) with ${_selectedGroupParticipants.length} students added to schedule!'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                    return;
                  }

                  if (_programType == 'single') {
                    if (_selectedParticipant == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select a participant from registered list'), backgroundColor: AppColors.error),
                      );
                      return;
                    }

                    if (_selectedProgramNames.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select or add at least 1 program name'), backgroundColor: AppColors.error),
                      );
                      return;
                    }

                    if (widget.programToEdit != null) {
                      final pName = _selectedProgramNames.first;
                      final durInt = _programDurations[pName] ?? 10;
                      final updatedProg = ProgramModel(
                        programId: widget.programToEdit!.programId,
                        participantName: _selectedParticipant!.name,
                        participantId: _selectedParticipant!.participantId,
                        studentClass: _selectedParticipant!.studentClass,
                        division: _selectedParticipant!.division,
                        category: _selectedParticipant!.category,
                        programName: pName,
                        programType: _programType,
                        startTime: widget.programToEdit!.startTime,
                        endTime: widget.programToEdit!.endTime,
                        duration: '$durInt mins',
                        status: _editingStatus,
                        order: widget.programToEdit!.order,
                        madrasaId: appState.madrasaId,
                        createdAt: widget.programToEdit!.createdAt,
                      );

                      await appState.updateProgramInFirestore(updatedProg);
                      if (!context.mounted) return;
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Program ${updatedProg.programId} (${updatedProg.programName}) updated successfully!'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                      return;
                    }

                    final nowStr = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());
                    final baseOrder = appState.realPrograms.length;
                    final createdIds = <String>[];

                    for (int i = 0; i < _selectedProgramNames.length; i++) {
                      final pName = _selectedProgramNames[i];
                      final progId = ProgramModel.generateNextProgramId(baseOrder + i);
                      final durInt = _programDurations[pName] ?? 10;

                      final newProgramDoc = ProgramModel(
                        programId: progId,
                        participantName: _selectedParticipant!.name,
                        participantId: _selectedParticipant!.participantId,
                        studentClass: _selectedParticipant!.studentClass,
                        division: _selectedParticipant!.division,
                        category: _selectedParticipant!.category,
                        programName: pName,
                        programType: 'single',
                        startTime: 'TBD',
                        endTime: 'TBD',
                        duration: '$durInt mins',
                        status: 'pending',
                        order: baseOrder + i + 1,
                        madrasaId: appState.madrasaId,
                        createdAt: nowStr,
                      );

                      await appState.addProgramToFirestore(newProgramDoc);
                      createdIds.add(progId);
                    }

                    if (!context.mounted) return;
                    Navigator.of(context).pop();

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${createdIds.length} Single Program(s) (${createdIds.join(', ')}) added to schedule!'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.save_rounded, size: 20),
                label: Text(
                  _programType == 'group'
                      ? 'Save Group Program Schedule'
                      : 'Save ${_selectedProgramNames.length} Program Schedule(s)',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _programType == 'group' ? AppColors.secondary : AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

