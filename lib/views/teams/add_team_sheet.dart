// Library: add_team_sheet.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/models/team_model.dart';
import '../../core/providers/app_state.dart';
import '../../core/theme/app_colors.dart';

class AddTeamSheet extends StatefulWidget {
  final TeamModel? initialTeam;

  const AddTeamSheet({super.key, this.initialTeam});

  @override
  State<AddTeamSheet> createState() => _AddTeamSheetState();
}

class _AddTeamSheetState extends State<AddTeamSheet> {
  late TextEditingController _teamNameController;
  late TextEditingController _teamHouseController;
  String _selectedColorHex = '0xFF3B82F6';

  TeamMemberModel? _teamCaptain;
  TeamMemberModel? _teamViceCaptain;

  final List<TeamMemberModel> _members = [];
  final Set<String> _removedStudentIds = {};

  String _captainSearchQuery = '';
  String _viceCaptainSearchQuery = '';
  String _memberSearchQuery = '';

  int _firstCount = 0;
  int _secondCount = 0;
  int _thirdCount = 0;
  int _overallPoint = 0;

  final List<TeamMedalWinnerModel> _firstMedals = [];
  final List<TeamMedalWinnerModel> _secondMedals = [];
  final List<TeamMedalWinnerModel> _thirdMedals = [];

  static const Map<String, String> _houseToColorMap = {
    'Red House': '0xFFEF4444',
    'Green House': '0xFF10B981',
    'Blue House': '0xFF3B82F6',
    'Gold House': '0xFFF59E0B',
    'Purple House': '0xFF8B5CF6',
    'Pink House': '0xFFEC4899',
    'Teal House': '0xFF14B8A6',
    'Orange House': '0xFFF97316',
  };

  static const Map<String, String> _colorToHouseMap = {
    '0xFFEF4444': 'Red House',
    '0xFF10B981': 'Green House',
    '0xFF3B82F6': 'Blue House',
    '0xFFF59E0B': 'Gold House',
    '0xFF8B5CF6': 'Purple House',
    '0xFFEC4899': 'Pink House',
    '0xFF14B8A6': 'Teal House',
    '0xFFF97316': 'Orange House',
  };

  final List<String> _houseColors = [
    '0xFFEF4444', // Red
    '0xFF10B981', // Green
    '0xFF3B82F6', // Blue
    '0xFFF59E0B', // Gold / Amber
    '0xFF8B5CF6', // Purple
    '0xFFEC4899', // Pink
    '0xFF14B8A6', // Teal
    '0xFFF97316', // Orange
  ];

  @override
  void initState() {
    super.initState();
    _teamNameController = TextEditingController(text: widget.initialTeam?.teamName ?? '');
    
    String initialHouse = widget.initialTeam?.teamHouse ?? 'Red House';
    if (initialHouse.isEmpty) initialHouse = 'Red House';
    
    String initialColor = widget.initialTeam?.houseColor ?? (_houseToColorMap[initialHouse] ?? '0xFFEF4444');
    
    if (_houseToColorMap.containsKey(initialHouse)) {
      initialColor = _houseToColorMap[initialHouse]!;
    } else if (_colorToHouseMap.containsKey(initialColor)) {
      initialHouse = _colorToHouseMap[initialColor]!;
    }

    _teamHouseController = TextEditingController(text: initialHouse);
    _selectedColorHex = initialColor;

    if (widget.initialTeam != null) {
      _teamCaptain = widget.initialTeam!.teamCaptain;
      _teamViceCaptain = widget.initialTeam!.teamViceCaptain;
      _members.addAll(widget.initialTeam!.members);
      _overallPoint = widget.initialTeam!.overallPoint;

      final medals = widget.initialTeam!.overallMedals;
      _firstCount = medals.firstCount;
      _secondCount = medals.secondCount;
      _thirdCount = medals.thirdCount;
      _firstMedals.addAll(medals.firstMedals);
      _secondMedals.addAll(medals.secondMedals);
      _thirdMedals.addAll(medals.thirdMedals);
    }
  }

  @override
  void dispose() {
    _teamNameController.dispose();
    _teamHouseController.dispose();
    super.dispose();
  }

  String _generateAutoTeamId(AppState appState) {
    if (widget.initialTeam != null) return widget.initialTeam!.teamId;
    final nextNum = appState.teamRecords.length + 1;
    return 'team-${nextNum.toString().padLeft(3, '0')}';
  }

  String? _getStudentExistingTeam(String participantId, AppState appState, String currentTeamId) {
    for (var t in appState.teamRecords) {
      if (t.teamId != currentTeamId) {
        if (t.members.any((m) => m.participantId == participantId)) {
          return '${t.teamName} (${t.teamHouse})';
        }
      }
    }
    return null;
  }

  void _addMemberToList(TeamMemberModel member) {
    if (!_members.any((m) => m.participantId == member.participantId)) {
      _members.add(member);
    }
    _removedStudentIds.remove(member.participantId);
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDark = appState.isDarkMode;
    final realParticipants = appState.realParticipants;
    final autoTeamId = _generateAutoTeamId(appState);

    Color currentColor = Color(int.parse(_selectedColorHex));

    // Filter candidate students for captain picker (Exclude students assigned to OTHER teams)
    final captainCandidates = realParticipants.where((p) {
      final q = _captainSearchQuery.toLowerCase();
      final matchesSearch = q.isEmpty ||
          p.name.toLowerCase().contains(q) ||
          p.participantId.toLowerCase().contains(q) ||
          p.studentClass.toLowerCase().contains(q);
      final isOtherTeamMember = _getStudentExistingTeam(p.participantId, appState, autoTeamId) != null;
      return matchesSearch && !isOtherTeamMember;
    }).toList();

    // Filter candidate students for vice captain picker (Exclude students assigned to OTHER teams)
    final viceCaptainCandidates = realParticipants.where((p) {
      final q = _viceCaptainSearchQuery.toLowerCase();
      final matchesSearch = q.isEmpty ||
          p.name.toLowerCase().contains(q) ||
          p.participantId.toLowerCase().contains(q) ||
          p.studentClass.toLowerCase().contains(q);
      final isOtherTeamMember = _getStudentExistingTeam(p.participantId, appState, autoTeamId) != null;
      return matchesSearch && !isOtherTeamMember;
    }).toList();

    // Filter candidate students for member search picker (Exclude students assigned to OTHER teams)
    final memberCandidates = realParticipants.where((p) {
      final q = _memberSearchQuery.toLowerCase();
      final matchesSearch = q.isEmpty ||
          p.name.toLowerCase().contains(q) ||
          p.participantId.toLowerCase().contains(q) ||
          p.studentClass.toLowerCase().contains(q);
      final notInCurrentMembers = !_members.any((m) => m.participantId == p.participantId);
      final isOtherTeamMember = _getStudentExistingTeam(p.participantId, appState, autoTeamId) != null;
      return matchesSearch && notInCurrentMembers && !isOtherTeamMember;
    }).toList();

    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.92),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag Handle & Top Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border(bottom: BorderSide(color: isDark ? Colors.white10 : const Color(0xFFE2E8F0))),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: currentColor.withAlpha(30),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.groups_rounded, color: currentColor, size: 22),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.initialTeam != null ? 'Edit Team Roster & Details' : 'Configure New House Team',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? AppColors.textLight : AppColors.textDark),
                    ),
                    Text(
                      'ID: $autoTeamId • Setup house name, captain, vice-captain, and member roster',
                      style: GoogleFonts.poppins(fontSize: 11, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          // Scrollable Form Shell
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- SECTION 1: TEAM BASIC INFORMATION & HOUSE COLORS ---
                  Text('1. House Team Information', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14, color: currentColor)),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      // Team Auto ID (Read Only)
                      Expanded(
                        child: TextField(
                          readOnly: true,
                          controller: TextEditingController(text: autoTeamId),
                          decoration: InputDecoration(
                            labelText: 'Team ID (Auto)',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            filled: true,
                            fillColor: isDark ? Colors.white10 : const Color(0xFFF1F5F9),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      // Team Name
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: _teamNameController,
                          decoration: InputDecoration(
                            labelText: 'Team Name',
                            hintText: 'e.g. Al-Fath',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      // House Name Dropdown
                      Expanded(
                        flex: 2,
                        child: DropdownButtonFormField<String>(
                          initialValue: _houseToColorMap.containsKey(_teamHouseController.text) ? _teamHouseController.text : 'Red House',
                          decoration: InputDecoration(
                            labelText: 'House Unit Name',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          dropdownColor: isDark ? AppColors.cardDark : Colors.white,
                          items: _houseToColorMap.keys.map((houseName) {
                            final colorHex = _houseToColorMap[houseName]!;
                            final Color houseColor = Color(int.parse(colorHex));
                            return DropdownMenuItem<String>(
                              value: houseName,
                              child: Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: houseColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    houseName,
                                    style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _teamHouseController.text = val;
                                _selectedColorHex = _houseToColorMap[val]!;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // House Color Selection
                  Row(
                    children: [
                      Text('Select House Theme Color:', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
                      const SizedBox(width: 14),
                      Wrap(
                        spacing: 8,
                        children: _houseColors.map((hexStr) {
                          Color c = Color(int.parse(hexStr));
                          bool isSel = _selectedColorHex == hexStr;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedColorHex = hexStr;
                                if (_colorToHouseMap.containsKey(hexStr)) {
                                  _teamHouseController.text = _colorToHouseMap[hexStr]!;
                                }
                              });
                            },
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: c,
                                shape: BoxShape.circle,
                                border: isSel ? Border.all(color: Colors.white, width: 3) : null,
                                boxShadow: isSel ? [BoxShadow(color: c.withAlpha(160), blurRadius: 8, offset: const Offset(0, 2))] : null,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  const Divider(height: 1),
                  const SizedBox(height: 20),

                  // --- SECTION 2: CAPTAIN & VICE-CAPTAIN SELECTION ---
                  Text('2. Team Leadership (Captain & Vice Captain)', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14, color: currentColor)),
                  const SizedBox(height: 12),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Team Captain Picker Box
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.surfaceDark : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.stars_rounded, color: Color(0xFFEAB308), size: 18),
                                  const SizedBox(width: 8),
                                  Text('Team Captain:', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13)),
                                ],
                              ),
                              const SizedBox(height: 8),

                              if (_teamCaptain != null)
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: currentColor.withAlpha(20),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: currentColor.withAlpha(80)),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(_teamCaptain!.participantName, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12)),
                                            Text('${_teamCaptain!.participantId} • Class ${_teamCaptain!.participantClass} (${_teamCaptain!.participantDiv})', style: GoogleFonts.poppins(fontSize: 10)),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.close_rounded, size: 16, color: AppColors.error),
                                        onPressed: () => setState(() => _teamCaptain = null),
                                      ),
                                    ],
                                  ),
                                )
                              else
                                Column(
                                  children: [
                                    TextField(
                                      onChanged: (val) => setState(() => _captainSearchQuery = val),
                                      decoration: InputDecoration(
                                        hintText: 'Search Captain Name or ID...',
                                        hintStyle: GoogleFonts.poppins(fontSize: 11),
                                        prefixIcon: const Icon(Icons.search_rounded, size: 16),
                                        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      constraints: const BoxConstraints(maxHeight: 120),
                                      child: ListView.separated(
                                        shrinkWrap: true,
                                        itemCount: captainCandidates.length,
                                        separatorBuilder: (_, _) => const Divider(height: 1),
                                        itemBuilder: (context, idx) {
                                          final p = captainCandidates[idx];
                                          return ListTile(
                                            dense: true,
                                            title: Text(p.name, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 11)),
                                            subtitle: Text('${p.participantId} • Class ${p.studentClass} (${p.division})', style: GoogleFonts.poppins(fontSize: 9)),
                                            trailing: const Icon(Icons.check_circle_outline_rounded, size: 16, color: AppColors.secondary),
                                            onTap: () {
                                              setState(() {
                                                _teamCaptain = TeamMemberModel(
                                                  participantId: p.participantId,
                                                  participantName: p.name,
                                                  participantClass: p.studentClass,
                                                  participantDiv: p.division,
                                                );
                                                _addMemberToList(_teamCaptain!);
                                              });
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 14),

                      // Team Vice-Captain Picker Box
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.surfaceDark : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.workspace_premium_rounded, color: Color(0xFF94A3B8), size: 18),
                                  const SizedBox(width: 8),
                                  Text('Team Vice Captain:', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13)),
                                ],
                              ),
                              const SizedBox(height: 8),

                              if (_teamViceCaptain != null)
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: currentColor.withAlpha(20),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: currentColor.withAlpha(80)),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(_teamViceCaptain!.participantName, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12)),
                                            Text('${_teamViceCaptain!.participantId} • Class ${_teamViceCaptain!.participantClass} (${_teamViceCaptain!.participantDiv})', style: GoogleFonts.poppins(fontSize: 10)),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.close_rounded, size: 16, color: AppColors.error),
                                        onPressed: () => setState(() => _teamViceCaptain = null),
                                      ),
                                    ],
                                  ),
                                )
                              else
                                Column(
                                  children: [
                                    TextField(
                                      onChanged: (val) => setState(() => _viceCaptainSearchQuery = val),
                                      decoration: InputDecoration(
                                        hintText: 'Search Vice Captain Name or ID...',
                                        hintStyle: GoogleFonts.poppins(fontSize: 11),
                                        prefixIcon: const Icon(Icons.search_rounded, size: 16),
                                        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      constraints: const BoxConstraints(maxHeight: 120),
                                      child: ListView.separated(
                                        shrinkWrap: true,
                                        itemCount: viceCaptainCandidates.length,
                                        separatorBuilder: (_, _) => const Divider(height: 1),
                                        itemBuilder: (context, idx) {
                                          final p = viceCaptainCandidates[idx];
                                          return ListTile(
                                            dense: true,
                                            title: Text(p.name, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 11)),
                                            subtitle: Text('${p.participantId} • Class ${p.studentClass} (${p.division})', style: GoogleFonts.poppins(fontSize: 9)),
                                            trailing: const Icon(Icons.check_circle_outline_rounded, size: 16, color: AppColors.primary),
                                            onTap: () {
                                              setState(() {
                                                _teamViceCaptain = TeamMemberModel(
                                                  participantId: p.participantId,
                                                  participantName: p.name,
                                                  participantClass: p.studentClass,
                                                  participantDiv: p.division,
                                                );
                                                _addMemberToList(_teamViceCaptain!);
                                              });
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  const Divider(height: 1),
                  const SizedBox(height: 20),

                  // --- SECTION 3: TEAM MEMBERS ROSTER & PICKER ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('3. Team Members Roster (${_members.length} Members)', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14, color: currentColor)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: currentColor.withAlpha(25),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Total Roster: ${_members.length} Students',
                          style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: currentColor),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Add Extra Team Members Picker Box
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('➕ Add Students to House Roster', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12)),
                        const SizedBox(height: 8),
                        TextField(
                          onChanged: (val) => setState(() => _memberSearchQuery = val),
                          decoration: InputDecoration(
                            hintText: 'Search student name, ID or class to add...',
                            hintStyle: GoogleFonts.poppins(fontSize: 11),
                            prefixIcon: const Icon(Icons.person_add_rounded, size: 16, color: AppColors.secondary),
                            contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                        const SizedBox(height: 8),

                        if (_memberSearchQuery.isNotEmpty)
                          Container(
                            constraints: const BoxConstraints(maxHeight: 140),
                            child: ListView.separated(
                              shrinkWrap: true,
                              itemCount: memberCandidates.length,
                              separatorBuilder: (_, _) => const Divider(height: 1),
                              itemBuilder: (context, idx) {
                                final sp = memberCandidates[idx];
                                final existingTeam = _getStudentExistingTeam(sp.participantId, appState, autoTeamId);
                                final isAlreadyAddedElsewhere = existingTeam != null;

                                return ListTile(
                                  dense: true,
                                  title: Text(sp.name, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 11, color: isAlreadyAddedElsewhere ? (isDark ? Colors.white54 : Colors.black54) : (isDark ? AppColors.textLight : AppColors.textDark))),
                                  subtitle: Text(
                                    isAlreadyAddedElsewhere
                                        ? '${sp.participantId} • Class ${sp.studentClass} (${sp.division}) • ⚠️ Registered in $existingTeam'
                                        : '${sp.participantId} • Class ${sp.studentClass} (${sp.division}) • ${sp.category}',
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
                                            'Added in $existingTeam',
                                            style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.error),
                                          ),
                                        )
                                      : const Icon(Icons.add_circle_outline_rounded, size: 18, color: AppColors.secondary),
                                  onTap: isAlreadyAddedElsewhere
                                      ? () {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('⚠️ Cannot add ${sp.name}! Student is already registered in $existingTeam.'),
                                              backgroundColor: AppColors.error,
                                            ),
                                          );
                                        }
                                      : () {
                                          setState(() {
                                            _addMemberToList(TeamMemberModel(
                                              participantId: sp.participantId,
                                              participantName: sp.name,
                                              participantClass: sp.studentClass,
                                              participantDiv: sp.division,
                                            ));
                                          });
                                        },
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Members Roster Data Table
                  if (_members.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Text(
                          'No members added to roster yet. Select Captain, Vice Captain or add students above.',
                          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceDark : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _members.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, idx) {
                          final m = _members[idx];
                          final isCaptain = _teamCaptain?.participantId == m.participantId;
                          final isViceCaptain = _teamViceCaptain?.participantId == m.participantId;

                          return ListTile(
                            dense: true,
                            leading: CircleAvatar(
                              radius: 14,
                              backgroundColor: currentColor.withAlpha(30),
                              child: Text('${idx + 1}', style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: currentColor)),
                            ),
                            title: Row(
                              children: [
                                Text(m.participantName, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12)),
                                if (isCaptain) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(color: const Color(0xFFEAB308).withAlpha(30), borderRadius: BorderRadius.circular(6)),
                                    child: Text('👑 Captain', style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.bold, color: const Color(0xFFD97706))),
                                  ),
                                ],
                                if (isViceCaptain) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(color: const Color(0xFF94A3B8).withAlpha(30), borderRadius: BorderRadius.circular(6)),
                                    child: Text('⭐ Vice Captain', style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.bold, color: const Color(0xFF475569))),
                                  ),
                                ],
                              ],
                            ),
                            subtitle: Text('${m.participantId} • Class ${m.participantClass} (${m.participantDiv})', style: GoogleFonts.poppins(fontSize: 10)),
                            trailing: IconButton(
                              icon: const Icon(Icons.remove_circle_outline_rounded, size: 18, color: AppColors.error),
                              onPressed: () {
                                setState(() {
                                  _members.removeAt(idx);
                                  if (isCaptain) _teamCaptain = null;
                                  if (isViceCaptain) _teamViceCaptain = null;
                                });
                              },
                            ),
                          );
                        },
                      ),
                    ),

                  const SizedBox(height: 24),
                  const Divider(height: 1),
                  const SizedBox(height: 20),

                  // --- SECTION 4: MEDALS TALLY & OVERALL POINTS ---
                  Text('4. Overall Points & Medal Tally', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14, color: currentColor)),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      // Overall Points Input
                      Expanded(
                        child: TextField(
                          controller: TextEditingController(text: '$_overallPoint'),
                          keyboardType: TextInputType.number,
                          onChanged: (val) => _overallPoint = int.tryParse(val) ?? 0,
                          decoration: InputDecoration(
                            labelText: 'Overall Championship Points',
                            hintText: 'e.g. 450',
                            prefixIcon: const Icon(Icons.stars_rounded, color: Color(0xFFF59E0B)),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      // 1st Place Medals Count
                      Expanded(
                        child: TextField(
                          controller: TextEditingController(text: '$_firstCount'),
                          keyboardType: TextInputType.number,
                          onChanged: (val) => _firstCount = int.tryParse(val) ?? 0,
                          decoration: InputDecoration(
                            labelText: '1st Medals 🥇',
                            prefixIcon: const Icon(Icons.military_tech_rounded, color: Color(0xFFEAB308)),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      // 2nd Place Medals Count
                      Expanded(
                        child: TextField(
                          controller: TextEditingController(text: '$_secondCount'),
                          keyboardType: TextInputType.number,
                          onChanged: (val) => _secondCount = int.tryParse(val) ?? 0,
                          decoration: InputDecoration(
                            labelText: '2nd Medals 🥈',
                            prefixIcon: const Icon(Icons.military_tech_rounded, color: Color(0xFF94A3B8)),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      // 3rd Place Medals Count
                      Expanded(
                        child: TextField(
                          controller: TextEditingController(text: '$_thirdCount'),
                          keyboardType: TextInputType.number,
                          onChanged: (val) => _thirdCount = int.tryParse(val) ?? 0,
                          decoration: InputDecoration(
                            labelText: '3rd Medals 🥉',
                            prefixIcon: const Icon(Icons.military_tech_rounded, color: Color(0xFFD97706)),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Bottom Full Width Save Action Button Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
              border: Border(top: BorderSide(color: isDark ? Colors.white10 : const Color(0xFFE2E8F0))),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final tName = _teamNameController.text.trim();
                  final tHouse = _teamHouseController.text.trim();

                  if (tName.isEmpty || tHouse.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('⚠️ Please fill Team Name and House Name!'), backgroundColor: AppColors.error),
                    );
                    return;
                  }

                  final record = TeamModel(
                    teamId: autoTeamId,
                    teamName: tName,
                    teamHouse: tHouse,
                    houseColor: _selectedColorHex,
                    teamCaptain: _teamCaptain,
                    teamViceCaptain: _teamViceCaptain,
                    totalMembers: _members.length,
                    members: _members,
                    overallPoint: _overallPoint,
                    overallMedals: TeamMedalsModel(
                      firstCount: _firstCount,
                      firstMedals: _firstMedals,
                      secondCount: _secondCount,
                      secondMedals: _secondMedals,
                      thirdCount: _thirdCount,
                      thirdMedals: _thirdMedals,
                    ),
                  );

                  final nav = Navigator.of(context);
                  final messenger = ScaffoldMessenger.of(context);

                  await appState.saveTeamRecordToFirestore(record);

                  if (mounted) {
                    nav.pop();
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text('✨ Team "$tName ($tHouse)" roster saved successfully!'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.save_rounded, size: 20),
                label: Text(
                  widget.initialTeam != null ? 'Save Team Roster Changes' : 'Create Team Roster',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: currentColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
