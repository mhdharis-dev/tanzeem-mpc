// Library: teams_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/models/team_model.dart';
import '../../core/providers/app_state.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/glass_card.dart';
import 'add_team_sheet.dart';

class TeamsScreen extends StatefulWidget {
  const TeamsScreen({super.key});

  @override
  State<TeamsScreen> createState() => _TeamsScreenState();
}

class _TeamsScreenState extends State<TeamsScreen> {
  String _searchQuery = '';
  String _selectedHouseFilter = 'All';
  String _selectedTeamFilter = 'All';

  final List<TeamModel> _defaultDemoTeams = [
    TeamModel(
      teamId: 'team-001',
      teamName: 'Al-Fath',
      teamHouse: 'Red House',
      houseColor: '0xFFEF4444',
      teamCaptain: TeamMemberModel(participantId: 'P101', participantName: 'Muhammed Sinan', participantClass: '10', participantDiv: 'A'),
      teamViceCaptain: TeamMemberModel(participantId: 'P102', participantName: 'Ahmad Raihan', participantClass: '9', participantDiv: 'B'),
      totalMembers: 32,
      overallPoint: 485,
      members: [
        TeamMemberModel(participantId: 'P101', participantName: 'Muhammed Sinan', participantClass: '10', participantDiv: 'A'),
        TeamMemberModel(participantId: 'P102', participantName: 'Ahmad Raihan', participantClass: '9', participantDiv: 'B'),
        TeamMemberModel(participantId: 'P103', participantName: 'Fadil Rahman', participantClass: '7', participantDiv: 'A'),
      ],
      overallMedals: TeamMedalsModel(firstCount: 8, secondCount: 5, thirdCount: 4),
    ),
    TeamModel(
      teamId: 'team-002',
      teamName: 'Badr',
      teamHouse: 'Green House',
      houseColor: '0xFF10B981',
      teamCaptain: TeamMemberModel(participantId: 'P201', participantName: 'Bilal Hassan', participantClass: '10', participantDiv: 'A'),
      teamViceCaptain: TeamMemberModel(participantId: 'P202', participantName: 'Zayd Muhammed', participantClass: '9', participantDiv: 'A'),
      totalMembers: 30,
      overallPoint: 440,
      members: [
        TeamMemberModel(participantId: 'P201', participantName: 'Bilal Hassan', participantClass: '10', participantDiv: 'A'),
        TeamMemberModel(participantId: 'P202', participantName: 'Zayd Muhammed', participantClass: '9', participantDiv: 'A'),
      ],
      overallMedals: TeamMedalsModel(firstCount: 6, secondCount: 7, thirdCount: 3),
    ),
    TeamModel(
      teamId: 'team-003',
      teamName: 'Uhud',
      teamHouse: 'Blue House',
      houseColor: '0xFF3B82F6',
      teamCaptain: TeamMemberModel(participantId: 'P301', participantName: 'Hamza Ibrahim', participantClass: '10', participantDiv: 'B'),
      teamViceCaptain: TeamMemberModel(participantId: 'P302', participantName: 'Omar Mukhtar', participantClass: '9', participantDiv: 'B'),
      totalMembers: 28,
      overallPoint: 395,
      members: [
        TeamMemberModel(participantId: 'P301', participantName: 'Hamza Ibrahim', participantClass: '10', participantDiv: 'B'),
        TeamMemberModel(participantId: 'P302', participantName: 'Omar Mukhtar', participantClass: '9', participantDiv: 'B'),
      ],
      overallMedals: TeamMedalsModel(firstCount: 5, secondCount: 4, thirdCount: 6),
    ),
    TeamModel(
      teamId: 'team-004',
      teamName: 'Yarmouk',
      teamHouse: 'Gold House',
      houseColor: '0xFFF59E0B',
      teamCaptain: TeamMemberModel(participantId: 'P401', participantName: 'Khalid Waleed', participantClass: '10', participantDiv: 'A'),
      teamViceCaptain: TeamMemberModel(participantId: 'P402', participantName: 'Tariq Ziyad', participantClass: '9', participantDiv: 'A'),
      totalMembers: 29,
      overallPoint: 360,
      members: [
        TeamMemberModel(participantId: 'P401', participantName: 'Khalid Waleed', participantClass: '10', participantDiv: 'A'),
        TeamMemberModel(participantId: 'P402', participantName: 'Tariq Ziyad', participantClass: '9', participantDiv: 'A'),
      ],
      overallMedals: TeamMedalsModel(firstCount: 4, secondCount: 5, thirdCount: 5),
    ),
  ];

  void _confirmDeleteTeam(TeamModel team) {
    final appState = Provider.of<AppState>(context, listen: false);
    final isDark = appState.isDarkMode;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: isDark ? AppColors.cardDark : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.error.withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.delete_forever_rounded, color: AppColors.error, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Delete ${team.teamName}?',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to delete "${team.teamName} (${team.teamHouse})"?',
                style: GoogleFonts.poppins(fontSize: 13, color: isDark ? AppColors.textLight : AppColors.textDark),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warning.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.warning.withAlpha(80)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, size: 18, color: AppColors.warning),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'All ${team.members.length} members of this team will be unassigned (team ID and team name set to empty).',
                        style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('Cancel', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.grey)),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                Navigator.of(ctx).pop();
                await appState.deleteTeamFromFirestore(team.teamId);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Team "${team.teamName}" deleted. Members unassigned successfully.'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              },
              icon: const Icon(Icons.delete_forever_rounded, size: 16),
              label: Text('Delete Team', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        );
      },
    );
  }

  void _openAddTeamSheet([TeamModel? team]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddTeamSheet(initialTeam: team),
    ).then((_) {
      setState(() {});
    });
  }

  // --- MANAGE TEAM MEMBERS MODAL (IN-PLACE MULTI-SELECTION ADD & UNREGISTER) ---
  void _openManageTeamMembersModal(TeamModel team) {
    final appState = Provider.of<AppState>(context, listen: false);
    final isDark = appState.isDarkMode;
    Color teamColor = Color(int.parse(team.houseColor));
    String modalSearchQuery = '';
    int activeTabIndex = 0; // 0: Candidate Students, 1: Enrolled Members

    Set<String> selectedCandidateIds = {};
    Set<String> selectedMemberIds = {};

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final realParticipants = appState.realParticipants;

            // Candidates: Students NOT assigned to ANY team in appState.teamRecords
            final candidateStudents = realParticipants.where((p) {
              bool isAssignedToAnyTeam = appState.teamRecords.any((t) => t.members.any((m) => m.participantId == p.participantId));
              bool matchesSearch = modalSearchQuery.isEmpty ||
                  p.name.toLowerCase().contains(modalSearchQuery.toLowerCase()) ||
                  p.participantId.toLowerCase().contains(modalSearchQuery.toLowerCase()) ||
                  p.studentClass.toLowerCase().contains(modalSearchQuery.toLowerCase());
              return !isAssignedToAnyTeam && matchesSearch;
            }).toList();

            final registeredMembers = team.members.where((m) {
              return modalSearchQuery.isEmpty ||
                  m.participantName.toLowerCase().contains(modalSearchQuery.toLowerCase()) ||
                  m.participantId.toLowerCase().contains(modalSearchQuery.toLowerCase()) ||
                  m.participantClass.toLowerCase().contains(modalSearchQuery.toLowerCase());
            }).toList();

            bool isAllCandidatesSelected = candidateStudents.isNotEmpty && candidateStudents.every((p) => selectedCandidateIds.contains(p.participantId));
            bool isAllMembersSelected = registeredMembers.isNotEmpty && registeredMembers.every((m) => selectedMemberIds.contains(m.participantId));

            return AlertDialog(
              backgroundColor: isDark ? AppColors.cardDark : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: teamColor.withAlpha(30), shape: BoxShape.circle),
                        child: Icon(Icons.person_add_rounded, color: teamColor, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Manage Team Members', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                            Text('${team.teamName} (${team.teamHouse})', style: GoogleFonts.poppins(fontSize: 11, color: teamColor, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Segmented Tab Switcher
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setModalState(() => activeTabIndex = 0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: activeTabIndex == 0 ? teamColor : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                'Candidates (${candidateStudents.length})',
                                style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: activeTabIndex == 0 ? Colors.white : (isDark ? AppColors.textLight : AppColors.textDark)),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setModalState(() => activeTabIndex = 1),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: activeTabIndex == 1 ? teamColor : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                'Team Members (${team.members.length})',
                                style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: activeTabIndex == 1 ? Colors.white : (isDark ? AppColors.textLight : AppColors.textDark)),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              content: SizedBox(
                width: 620,
                height: 440,
                child: Column(
                  children: [
                    TextField(
                      onChanged: (val) => setModalState(() => modalSearchQuery = val),
                      decoration: InputDecoration(
                        hintText: activeTabIndex == 0 ? 'Search student by name, ID or class...' : 'Search team member...',
                        hintStyle: GoogleFonts.poppins(fontSize: 12),
                        prefixIcon: Icon(Icons.search_rounded, color: teamColor, size: 18),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // TAB 0: CANDIDATES LIST
                    if (activeTabIndex == 0) ...[
                      if (candidateStudents.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Checkbox(
                                value: isAllCandidatesSelected,
                                activeColor: teamColor,
                                onChanged: (val) {
                                  setModalState(() {
                                    if (val == true) {
                                      selectedCandidateIds.addAll(candidateStudents.map((e) => e.participantId));
                                    } else {
                                      selectedCandidateIds.clear();
                                    }
                                  });
                                },
                              ),
                              Text('Select All Candidates (${candidateStudents.length})', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold)),
                              const Spacer(),
                              if (selectedCandidateIds.isNotEmpty)
                                Text('${selectedCandidateIds.length} Selected', style: GoogleFonts.poppins(fontSize: 11, color: teamColor, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      const SizedBox(height: 6),

                      Expanded(
                        child: candidateStudents.isEmpty
                            ? Center(
                                child: Text('No unassigned candidate students found.', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                              )
                            : ListView.separated(
                                itemCount: candidateStudents.length,
                                separatorBuilder: (_, _) => const Divider(height: 1),
                                itemBuilder: (context, idx) {
                                  final sp = candidateStudents[idx];
                                  bool isChecked = selectedCandidateIds.contains(sp.participantId);

                                  return ListTile(
                                    dense: true,
                                    onTap: () {
                                      setModalState(() {
                                        if (isChecked) {
                                          selectedCandidateIds.remove(sp.participantId);
                                        } else {
                                          selectedCandidateIds.add(sp.participantId);
                                        }
                                      });
                                    },
                                    leading: Checkbox(
                                      value: isChecked,
                                      activeColor: teamColor,
                                      onChanged: (val) {
                                        setModalState(() {
                                          if (val == true) {
                                            selectedCandidateIds.add(sp.participantId);
                                          } else {
                                            selectedCandidateIds.remove(sp.participantId);
                                          }
                                        });
                                      },
                                    ),
                                    title: Text(sp.name, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12)),
                                    subtitle: Text(
                                      '${sp.participantId} • Class ${sp.studentClass} (${sp.division}) • Cat: ${sp.category}',
                                      style: GoogleFonts.poppins(fontSize: 10),
                                    ),
                                    trailing: ElevatedButton.icon(
                                      onPressed: () async {
                                        await appState.assignStudentToTeam(
                                          studentId: sp.participantId,
                                          studentName: sp.name,
                                          studentClass: sp.studentClass,
                                          studentDiv: sp.division,
                                          newTeam: team,
                                        );

                                        setModalState(() {
                                          selectedCandidateIds.remove(sp.participantId);
                                        });
                                        setState(() {});

                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('✨ Added ${sp.name} into ${team.teamName} & updated side events!'),
                                              backgroundColor: AppColors.success,
                                              duration: const Duration(seconds: 1),
                                            ),
                                          );
                                        }
                                      },
                                      icon: const Icon(Icons.add_rounded, size: 14),
                                      label: Text('Add', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold)),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: teamColor,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),

                      if (candidateStudents.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: SizedBox(
                            width: double.infinity,
                            height: 44,
                            child: ElevatedButton.icon(
                              onPressed: selectedCandidateIds.isEmpty
                                  ? null
                                  : () async {
                                      final selectedStudents = candidateStudents.where((p) => selectedCandidateIds.contains(p.participantId)).toList();

                                      for (var sp in selectedStudents) {
                                        await appState.assignStudentToTeam(
                                          studentId: sp.participantId,
                                          studentName: sp.name,
                                          studentClass: sp.studentClass,
                                          studentDiv: sp.division,
                                          newTeam: team,
                                        );
                                      }

                                      final count = selectedCandidateIds.length;
                                      setModalState(() {
                                        selectedCandidateIds.clear();
                                      });
                                      setState(() {});

                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('✨ Added $count members to ${team.teamName} & updated side events!'),
                                            backgroundColor: AppColors.success,
                                            duration: const Duration(seconds: 2),
                                          ),
                                        );
                                      }
                                    },
                              icon: const Icon(Icons.group_add_rounded, size: 18),
                              label: Text('Add Selected Members (${selectedCandidateIds.length})', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: teamColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                        ),
                    ],

                    // TAB 1: TEAM MEMBERS LIST (WITH REMOVE OPTION)
                    if (activeTabIndex == 1) ...[
                      if (registeredMembers.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Checkbox(
                                value: isAllMembersSelected,
                                activeColor: AppColors.error,
                                onChanged: (val) {
                                  setModalState(() {
                                    if (val == true) {
                                      selectedMemberIds.addAll(registeredMembers.map((e) => e.participantId));
                                    } else {
                                      selectedMemberIds.clear();
                                    }
                                  });
                                },
                              ),
                              Text('Select All Members (${registeredMembers.length})', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold)),
                              const Spacer(),
                              if (selectedMemberIds.isNotEmpty)
                                Text('${selectedMemberIds.length} Selected', style: GoogleFonts.poppins(fontSize: 11, color: AppColors.error, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      const SizedBox(height: 6),

                      Expanded(
                        child: registeredMembers.isEmpty
                            ? Center(
                                child: Text('No members currently registered in this team.', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                              )
                            : ListView.separated(
                                itemCount: registeredMembers.length,
                                separatorBuilder: (_, _) => const Divider(height: 1),
                                itemBuilder: (context, idx) {
                                  final m = registeredMembers[idx];
                                  bool isChecked = selectedMemberIds.contains(m.participantId);

                                  return ListTile(
                                    dense: true,
                                    onTap: () {
                                      setModalState(() {
                                        if (isChecked) {
                                          selectedMemberIds.remove(m.participantId);
                                        } else {
                                          selectedMemberIds.add(m.participantId);
                                        }
                                      });
                                    },
                                    leading: Checkbox(
                                      value: isChecked,
                                      activeColor: AppColors.error,
                                      onChanged: (val) {
                                        setModalState(() {
                                          if (val == true) {
                                            selectedMemberIds.add(m.participantId);
                                          } else {
                                            selectedMemberIds.remove(m.participantId);
                                          }
                                        });
                                      },
                                    ),
                                    title: Text(m.participantName, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12)),
                                    subtitle: Text(
                                      '${m.participantId} • Class ${m.participantClass} (${m.participantDiv})',
                                      style: GoogleFonts.poppins(fontSize: 10),
                                    ),
                                    trailing: OutlinedButton.icon(
                                      onPressed: () async {
                                        await appState.removeStudentFromTeam(
                                          studentId: m.participantId,
                                          team: team,
                                        );

                                        setModalState(() {
                                          selectedMemberIds.remove(m.participantId);
                                        });
                                        setState(() {});

                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('🗑️ Removed ${m.participantName} from ${team.teamName}.'),
                                              backgroundColor: AppColors.error,
                                              duration: const Duration(seconds: 1),
                                            ),
                                          );
                                        }
                                      },
                                      icon: const Icon(Icons.person_remove_rounded, size: 14, color: AppColors.error),
                                      label: Text('Remove', style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.error)),
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(color: AppColors.error),
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),

                      if (registeredMembers.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: SizedBox(
                            width: double.infinity,
                            height: 44,
                            child: ElevatedButton.icon(
                              onPressed: selectedMemberIds.isEmpty
                                  ? null
                                  : () async {
                                      for (var id in selectedMemberIds) {
                                        await appState.removeStudentFromTeam(
                                          studentId: id,
                                          team: team,
                                        );
                                      }

                                      final count = selectedMemberIds.length;
                                      setModalState(() {
                                        selectedMemberIds.clear();
                                      });
                                      setState(() {});

                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('🗑️ Removed $count members from ${team.teamName}.'),
                                            backgroundColor: AppColors.error,
                                            duration: const Duration(seconds: 2),
                                          ),
                                        );
                                      }
                                    },
                              icon: const Icon(Icons.person_remove_rounded, size: 18),
                              label: Text('Remove Selected Members (${selectedMemberIds.length})', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.error,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text('Done', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // --- REDESIGNED TEAM ROSTER MODAL (DETAILED PARTICIPANT GRANTED POINTS & EVENTS LIST) ---
  void _openTeamRosterModal(TeamModel team) {
    final appState = Provider.of<AppState>(context, listen: false);
    final isDark = appState.isDarkMode;
    Color teamColor = Color(int.parse(team.houseColor));

    // Calculate total roster points dynamically
    int totalTeamRosterPoints = 0;
    for (var m in team.members) {
      for (var se in appState.sideEventRecords) {
        final match = se.participants.where((x) => x.participantId == m.participantId).toList();
        if (match.isNotEmpty) {
          totalTeamRosterPoints += match.first.point;
        }
      }
    }
    int displayPoints = team.overallPoint > totalTeamRosterPoints ? team.overallPoint : totalTeamRosterPoints;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: isDark ? AppColors.cardDark : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(color: teamColor, shape: BoxShape.circle),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${team.teamName} (${team.teamHouse}) Roster', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('${team.members.length} Registered Members', style: GoogleFonts.poppins(fontSize: 11, color: isDark ? AppColors.subtextLight : AppColors.subtextDark)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: teamColor.withAlpha(30), borderRadius: BorderRadius.circular(10)),
                child: Text('$displayPoints Pts', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14, color: teamColor)),
              ),
            ],
          ),
          content: SizedBox(
            width: 600,
            height: 440,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Captains Banner
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const Text('👑 ', style: TextStyle(fontSize: 14)),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Captain', style: GoogleFonts.poppins(fontSize: 10, color: isDark ? AppColors.subtextLight : AppColors.subtextDark)),
                                Text(team.teamCaptain?.participantName ?? "Unassigned", style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            const Text('⭐ ', style: TextStyle(fontSize: 14)),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Vice Captain', style: GoogleFonts.poppins(fontSize: 10, color: isDark ? AppColors.subtextLight : AppColors.subtextDark)),
                                Text(team.teamViceCaptain?.participantName ?? "Unassigned", style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Text('Team Members Performance & Points Breakdown:', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 8),

                Expanded(
                  child: team.members.isEmpty
                      ? Center(child: Text('No members registered in this team yet.', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)))
                      : ListView.separated(
                          itemCount: team.members.length,
                          separatorBuilder: (_, _) => const Divider(height: 1),
                          itemBuilder: (context, idx) {
                            final m = team.members[idx];

                            // Compute Granted Points across Side Events
                            int grantedPoints = 0;
                            List<String> eventChips = [];

                            // Side Events Points
                            for (var se in appState.sideEventRecords) {
                              final match = se.participants.where((x) => x.participantId == m.participantId).toList();
                              if (match.isNotEmpty) {
                                final p = match.first;
                                grantedPoints += p.point;
                                final rankBadge = p.rank == 1 ? '🥇 1st' : (p.rank == 2 ? '🥈 2nd' : (p.rank == 3 ? '🥉 3rd' : '#${p.rank}'));
                                eventChips.add('${se.sideEventName} ($rankBadge • ${p.point} pts)');
                              }
                            }

                            return Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 14,
                                        backgroundColor: teamColor.withAlpha(30),
                                        child: Text('${idx + 1}', style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: teamColor)),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(m.participantName, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13)),
                                            Text('${m.participantId} • Class ${m.participantClass} (${m.participantDiv})', style: GoogleFonts.poppins(fontSize: 10, color: isDark ? AppColors.subtextLight : AppColors.subtextDark)),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: grantedPoints > 0 ? const Color(0xFF10B981).withAlpha(20) : Colors.grey.withAlpha(20),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          '$grantedPoints Points',
                                          style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: grantedPoints > 0 ? const Color(0xFF10B981) : Colors.grey),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (eventChips.isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 38.0),
                                      child: Wrap(
                                        spacing: 6,
                                        runSpacing: 4,
                                        children: eventChips.map((chipText) {
                                          return Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: teamColor.withAlpha(18),
                                              borderRadius: BorderRadius.circular(6),
                                              border: Border.all(color: teamColor.withAlpha(50)),
                                            ),
                                            child: Text(chipText, style: GoogleFonts.poppins(fontSize: 9.5, color: teamColor, fontWeight: FontWeight.w600)),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('Close', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDark = appState.isDarkMode;

    final teamsList = appState.teamRecords.isNotEmpty ? appState.teamRecords : _defaultDemoTeams;

    final filteredTeams = teamsList.where((t) {
      final matchesSearch = _searchQuery.isEmpty ||
          t.teamName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          t.teamHouse.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (t.teamCaptain?.participantName.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
          t.members.any((m) => m.participantName.toLowerCase().contains(_searchQuery.toLowerCase()));

      final matchesHouse = _selectedHouseFilter == 'All' || t.teamHouse.toLowerCase() == _selectedHouseFilter.toLowerCase();
      final matchesTeam = _selectedTeamFilter == 'All' || t.teamName.toLowerCase() == _selectedTeamFilter.toLowerCase();

      return matchesSearch && matchesHouse && matchesTeam;
    }).toList();

    // Sort by points descending for leaderboard rank
    filteredTeams.sort((a, b) => b.overallPoint.compareTo(a.overallPoint));

    final totalChampionshipPoints = teamsList.fold<int>(0, (sum, t) => sum + t.overallPoint);
    final topTeam = teamsList.reduce((a, b) => a.overallPoint > b.overallPoint ? a : b);

    // Extract unique house names and team names for filter chips
    final availableHouses = ['All', ...teamsList.map((t) => t.teamHouse).toSet()];
    final availableTeamNames = ['All', ...teamsList.map((t) => t.teamName).toSet()];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(28.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header Bar
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 20,
              runSpacing: 14,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withAlpha(25),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.groups_rounded, color: AppColors.primary, size: 28),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Teams & House Roster',
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppColors.textLight : AppColors.textDark,
                              ),
                            ),
                            Text(
                              'Manage house teams, team captains, member rosters, and point tally',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: isDark ? AppColors.subtextLight : AppColors.subtextDark,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => _openAddTeamSheet(),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: Text('Add New Team / House', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Top Metrics Overview Bar
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    context,
                    title: 'Total Houses / Teams',
                    value: '${teamsList.length}',
                    subtitle: 'Active House Units',
                    icon: Icons.shield_rounded,
                    color: AppColors.primary,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMetricCard(
                    context,
                    title: 'Leading House 👑',
                    value: topTeam.teamName,
                    subtitle: '${topTeam.overallPoint} Pts (1st Place)',
                    icon: Icons.military_tech_rounded,
                    color: Color(int.parse(topTeam.houseColor)),
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMetricCard(
                    context,
                    title: 'Total Championship Points',
                    value: '$totalChampionshipPoints',
                    subtitle: 'Awarded Across Events',
                    icon: Icons.stars_rounded,
                    color: const Color(0xFFF59E0B),
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMetricCard(
                    context,
                    title: 'Average Team Points',
                    value: teamsList.isNotEmpty ? '${(totalChampionshipPoints / teamsList.length).round()}' : '0',
                    subtitle: 'Per House Average',
                    icon: Icons.analytics_rounded,
                    color: AppColors.secondary,
                    isDark: isDark,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Redesigned Modern Search Bar & Multi-Filter Panel
            GlassCard(
              padding: const EdgeInsets.all(20),
              borderRadius: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 46,
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                          ),
                          child: TextField(
                            onChanged: (val) => setState(() => _searchQuery = val),
                            style: GoogleFonts.poppins(fontSize: 13, color: isDark ? AppColors.textLight : AppColors.textDark),
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColors.primary),
                              suffixIcon: _searchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear_rounded, size: 18),
                                      onPressed: () => setState(() => _searchQuery = ''),
                                    )
                                  : null,
                              hintText: 'Search house name, team captain or member name...',
                              hintStyle: GoogleFonts.poppins(fontSize: 12, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ),
                      if (_searchQuery.isNotEmpty || _selectedHouseFilter != 'All' || _selectedTeamFilter != 'All') ...[
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: () {
                            setState(() {
                              _searchQuery = '';
                              _selectedHouseFilter = 'All';
                              _selectedTeamFilter = 'All';
                            });
                          },
                          icon: const Icon(Icons.rotate_left_rounded, size: 16),
                          label: Text('Reset Filters', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            side: const BorderSide(color: AppColors.error),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Divider(height: 1),
                  const SizedBox(height: 12),

                  // House Filter Chips
                  Row(
                    children: [
                      Text('House Filter:', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? AppColors.textLight : AppColors.textDark)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: availableHouses.map((house) {
                              bool isSel = _selectedHouseFilter == house;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: FilterChip(
                                  selected: isSel,
                                  showCheckmark: false,
                                  label: Text(house),
                                  labelStyle: GoogleFonts.poppins(
                                    fontSize: 11.5,
                                    fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                                    color: isSel ? Colors.white : (isDark ? AppColors.textLight : AppColors.textDark),
                                  ),
                                  selectedColor: AppColors.primary,
                                  backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                                  side: BorderSide(color: isSel ? AppColors.primary : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0))),
                                  onSelected: (_) => setState(() => _selectedHouseFilter = house),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Team Name Filter Chips
                  Row(
                    children: [
                      Text('Team Name:', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? AppColors.textLight : AppColors.textDark)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: availableTeamNames.map((teamName) {
                              bool isSel = _selectedTeamFilter == teamName;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: FilterChip(
                                  selected: isSel,
                                  showCheckmark: false,
                                  label: Text(teamName),
                                  labelStyle: GoogleFonts.poppins(
                                    fontSize: 11.5,
                                    fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                                    color: isSel ? Colors.white : (isDark ? AppColors.textLight : AppColors.textDark),
                                  ),
                                  selectedColor: AppColors.secondary,
                                  backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                                  side: BorderSide(color: isSel ? AppColors.secondary : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0))),
                                  onSelected: (_) => setState(() => _selectedTeamFilter = teamName),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Teams Grid Cards
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.48,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
              ),
              itemCount: filteredTeams.length,
              itemBuilder: (context, idx) {
                final team = filteredTeams[idx];
                final rank = idx + 1;
                final pct = totalChampionshipPoints > 0 ? (team.overallPoint / totalChampionshipPoints * 100) : 0.0;
                Color teamColor = Color(int.parse(team.houseColor));

                return GlassCard(
                  padding: const EdgeInsets.all(20),
                  borderRadius: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: teamColor.withAlpha(30),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: teamColor.withAlpha(100), width: 1.5),
                                ),
                                child: Center(
                                  child: Icon(Icons.shield_rounded, color: teamColor, size: 24),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${team.teamName} (${team.teamHouse})',
                                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? AppColors.textLight : AppColors.textDark),
                                  ),
                                  Text(
                                    'ID: ${team.teamId} • ${team.members.length} Members',
                                    style: GoogleFonts.poppins(fontSize: 11, fontStyle: FontStyle.italic, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          // Rank Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: rank == 1 ? const Color(0xFFFEF08A) : (rank == 2 ? const Color(0xFFE2E8F0) : (rank == 3 ? const Color(0xFFFFEDD5) : teamColor.withAlpha(25))),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: teamColor.withAlpha(80)),
                            ),
                            child: Text(
                              rank == 1 ? '🥇 1st Place' : (rank == 2 ? '🥈 2nd Place' : (rank == 3 ? '🥉 3rd Place' : 'Rank #$rank')),
                              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 11, color: rank == 1 ? const Color(0xFF854D0E) : (rank == 2 ? const Color(0xFF334155) : teamColor)),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                      const Divider(height: 1),
                      const SizedBox(height: 14),

                      // Captains & Members info
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Captain:', style: GoogleFonts.poppins(fontSize: 10, color: isDark ? AppColors.subtextLight : AppColors.subtextDark)),
                                Text(team.teamCaptain?.participantName ?? 'Unassigned', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12)),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Vice Captain:', style: GoogleFonts.poppins(fontSize: 10, color: isDark ? AppColors.subtextLight : AppColors.subtextDark)),
                                Text(team.teamViceCaptain?.participantName ?? 'Unassigned', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 12)),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('Total Score:', style: GoogleFonts.poppins(fontSize: 10, color: isDark ? AppColors.subtextLight : AppColors.subtextDark)),
                              Text('${team.overallPoint} Pts', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15, color: teamColor)),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // Medal Tally
                      Row(
                        children: [
                          _buildMedalChip('🥇 ${team.overallMedals.firstCount}', const Color(0xFFEAB308)),
                          const SizedBox(width: 8),
                          _buildMedalChip('🥈 ${team.overallMedals.secondCount}', const Color(0xFF94A3B8)),
                          const SizedBox(width: 8),
                          _buildMedalChip('🥉 ${team.overallMedals.thirdCount}', const Color(0xFFD97706)),
                          const Spacer(),
                          Text('${pct.toStringAsFixed(1)}% Share', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: teamColor)),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Progress Bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: (pct / 100).clamp(0.0, 1.0),
                          minHeight: 6,
                          backgroundColor: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
                          valueColor: AlwaysStoppedAnimation<Color>(teamColor),
                        ),
                      ),

                      const Spacer(),

                      // Actions Row (Add Member + View Roster + Edit Team)
                      Row(
                        children: [
                          // 1. ADD MEMBER BUTTON (Styled like Register Student)
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _openManageTeamMembersModal(team),
                              icon: const Icon(Icons.person_add_rounded, size: 15),
                              label: Text('Add Member', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: teamColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // 2. VIEW ROSTER BUTTON
                          OutlinedButton.icon(
                            onPressed: () => _openTeamRosterModal(team),
                            icon: const Icon(Icons.badge_rounded, size: 15),
                            label: Text('View Roster (${team.members.length})', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: teamColor,
                              side: BorderSide(color: teamColor.withAlpha(100)),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // 3. EDIT TEAM BUTTON
                          IconButton(
                            onPressed: () => _openAddTeamSheet(team),
                            icon: const Icon(Icons.edit_note_rounded, size: 20),
                            color: isDark ? AppColors.subtextLight : AppColors.subtextDark,
                            tooltip: 'Edit Team Setup',
                          ),

                          // 4. DELETE TEAM BUTTON WITH CONFIRMATION ALERT DIALOG
                          IconButton(
                            onPressed: () => _confirmDeleteTeam(team),
                            icon: const Icon(Icons.delete_outline_rounded, size: 20),
                            color: AppColors.error,
                            tooltip: 'Delete Team',
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedalChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withAlpha(70)),
      ),
      child: Text(label, style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
    );
  }

  Widget _buildMetricCard(
    BuildContext context, {
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return GlassCard(
      padding: const EdgeInsets.all(18),
      borderRadius: 18,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withAlpha(30),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.poppins(fontSize: 11, color: isDark ? AppColors.subtextLight : AppColors.subtextDark)),
                Text(value, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? AppColors.textLight : AppColors.textDark)),
                Text(subtitle, style: GoogleFonts.poppins(fontSize: 10, color: color, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
