import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/models/side_event_model.dart';
import '../../core/providers/app_state.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/glass_card.dart';
import 'add_side_event_sheet.dart';
import 'side_event_pdf_service.dart';

class SideEventsScreen extends StatefulWidget {
  const SideEventsScreen({super.key});

  @override
  State<SideEventsScreen> createState() => _SideEventsScreenState();
}

class _SideEventsScreenState extends State<SideEventsScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _selectedStatus = 'All';

  void _openAddSideEventSheet([SideEventModel? event]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddSideEventSheet(initialSideEvent: event),
    ).then((_) {
      setState(() {});
    });
  }

  // --- PROGRAM SCREEN STYLE QUICK STATUS UPDATION METHOD ---
  Future<void> _updateEventStatus(AppState appState, SideEventModel event, String newStatus) async {
    final updatedRecord = SideEventModel(
      sideEventId: event.sideEventId,
      sideEventName: event.sideEventName,
      participantsCount: event.participants.length,
      participantsCategory: event.participantsCategory,
      scheduledDate: event.scheduledDate,
      scheduledTime: event.scheduledTime,
      sideEventColor: event.sideEventColor,
      sideEventMaxPoint: event.sideEventMaxPoint,
      sideEventStatus: newStatus,
      totalRounds: event.rounds.length,
      rounds: event.rounds,
      participants: event.participants,
    );

    final messenger = ScaffoldMessenger.of(context);
    await appState.saveSideEventRecordWithStatusRule(updatedRecord);

    final isFinal = newStatus == 'completed';
    String statusLabel = newStatus == 'live now'
        ? '🔴 LIVE NOW'
        : (isFinal ? '✅ COMPLETED' : (newStatus == 'canceled' ? '❌ CANCELED' : '⏳ SCHEDULED'));

    if (mounted) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            isFinal
                ? '✅ ${event.sideEventName} status set to COMPLETED! Points, ranks & medals saved to Cloud Firestore & team scores updated!'
                : '💾 ${event.sideEventName} status set to $statusLabel. Scores, ranks & medals saved locally (Draft Mode).',
          ),
          backgroundColor: newStatus == 'live now'
              ? AppColors.error
              : (isFinal ? AppColors.success : AppColors.primary),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  // --- CONFIRM & DELETE SIDE EVENT WITH ALERT DIALOG ---
  void _confirmDeleteSideEvent(BuildContext context, AppState appState, SideEventModel event) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                  color: AppColors.error.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.delete_forever_rounded, color: AppColors.error, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Delete Side Event?',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isDark ? AppColors.textLight : AppColors.textDark,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to delete "${event.sideEventName}" (${event.sideEventId})? This action will permanently remove this event from Cloud Firestore.',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: isDark ? AppColors.subtextLight : AppColors.subtextDark,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.subtextLight : AppColors.subtextDark,
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                Navigator.of(ctx).pop();
                final success = await appState.deleteSideEventRecordFromFirestore(event.sideEventId);
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? '🗑️ Side Event "${event.sideEventName}" deleted successfully!'
                          : '❌ Failed to delete side event.',
                    ),
                    backgroundColor: success ? AppColors.success : AppColors.error,
                  ),
                );
              },
              icon: const Icon(Icons.delete_rounded, size: 16),
              label: Text('Delete Event', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
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

  // --- STUDENT REGISTRATION MODAL STRICTLY FILTERED BY EVENT CATEGORY ---
  // --- REDESIGN STUDENT REGISTRATION & UNREGISTRATION MODAL (WITH MULTI-SELECTION & BULK ACTIONS) ---
  void _openRegisterStudentModal(SideEventModel event) {
    final appState = Provider.of<AppState>(context, listen: false);
    final isDark = appState.isDarkMode;
    Color themeColor = Color(int.parse(event.sideEventColor));
    String searchQuery = '';
    int activeTabIndex = 0; // 0: Candidate Students, 1: Registered Students

    Set<String> selectedCandidateIds = {};
    Set<String> selectedRegisteredIds = {};

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final realParticipants = appState.realParticipants;

            // Strict filtering by Event's Selected Category
            final candidateStudents = realParticipants.where((p) {
              bool matchesCategory = event.participantsCategory == 'All' ||
                  event.participantsCategory.split(',').map((c) => c.trim()).any((catFilter) {
                    final studentCat = p.category.trim().toLowerCase();
                    final filterLower = catFilter.toLowerCase();
                    if (studentCat == filterLower) return true;
                    if (filterLower == 'sub-junior' && studentCat.contains('sub')) return true;
                    if (filterLower == 'junior' && studentCat.contains('junior') && !studentCat.contains('sub')) return true;
                    if (filterLower == 'senior' && studentCat.contains('senior') && !studentCat.contains('super')) return true;
                    if (filterLower == 'super senior' && studentCat.contains('super')) return true;
                    return false;
                  });

              bool notInEvent = !event.participants.any((m) => m.participantId == p.participantId);

              bool matchesSearch = searchQuery.isEmpty ||
                  p.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
                  p.participantId.toLowerCase().contains(searchQuery.toLowerCase()) ||
                  p.studentClass.toLowerCase().contains(searchQuery.toLowerCase());

              return matchesCategory && notInEvent && matchesSearch;
            }).toList();

            final registeredStudents = event.participants.where((p) {
              return searchQuery.isEmpty ||
                  p.participantName.toLowerCase().contains(searchQuery.toLowerCase()) ||
                  p.participantId.toLowerCase().contains(searchQuery.toLowerCase()) ||
                  p.participantClass.toLowerCase().contains(searchQuery.toLowerCase());
            }).toList();

            bool isAllCandidatesSelected = candidateStudents.isNotEmpty && candidateStudents.every((p) => selectedCandidateIds.contains(p.participantId));

            bool isAllRegisteredSelected = registeredStudents.isNotEmpty && registeredStudents.every((p) => selectedRegisteredIds.contains(p.participantId));

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
                        decoration: BoxDecoration(color: themeColor.withAlpha(30), shape: BoxShape.circle),
                        child: Icon(Icons.person_add_rounded, color: themeColor, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Register & Manage Students', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                            Text('${event.sideEventName} • Category: ${event.participantsCategory}', style: GoogleFonts.poppins(fontSize: 11, color: themeColor, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Segmented Tab Switcher (Candidates vs Registered)
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setModalState(() => activeTabIndex = 0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: activeTabIndex == 0 ? themeColor : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
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
                              color: activeTabIndex == 1 ? themeColor : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                'Registered (${event.participants.length})',
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
                      onChanged: (val) => setModalState(() => searchQuery = val),
                      decoration: InputDecoration(
                        hintText: activeTabIndex == 0 ? 'Search candidate by name, ID or class...' : 'Search registered student...',
                        hintStyle: GoogleFonts.poppins(fontSize: 12),
                        prefixIcon: Icon(Icons.search_rounded, color: themeColor, size: 18),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // TAB 0: CANDIDATES LIST (WITH MULTI-SELECTION)
                    if (activeTabIndex == 0) ...[
                      // Select All Header Bar
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
                                activeColor: themeColor,
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
                                Text('${selectedCandidateIds.length} Selected', style: GoogleFonts.poppins(fontSize: 11, color: themeColor, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      const SizedBox(height: 6),

                      Expanded(
                        child: candidateStudents.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.person_off_rounded, size: 36, color: isDark ? Colors.white38 : Colors.black38),
                                    const SizedBox(height: 8),
                                    Text(
                                      'No unassigned candidates found for category "${event.participantsCategory}".',
                                      style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              )
                            : ListView.separated(
                                itemCount: candidateStudents.length,
                                separatorBuilder: (_, _) => const Divider(height: 1),
                                itemBuilder: (context, idx) {
                                  final sp = candidateStudents[idx];
                                  bool isChecked = selectedCandidateIds.contains(sp.participantId);

                                  String matchedTeamId = '';
                                  String matchedTeamName = '';
                                  for (var t in appState.teamRecords) {
                                    if (t.members.any((m) => m.participantId == sp.participantId)) {
                                      matchedTeamId = t.teamId;
                                      matchedTeamName = '${t.teamName} (${t.teamHouse})';
                                      break;
                                    }
                                  }

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
                                      activeColor: themeColor,
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
                                      '${sp.participantId} • Class ${sp.studentClass} (${sp.division}) • Cat: ${sp.category}${matchedTeamName.isNotEmpty ? " • $matchedTeamName" : ""}',
                                      style: GoogleFonts.poppins(fontSize: 10),
                                    ),
                                    trailing: ElevatedButton.icon(
                                      onPressed: () async {
                                        final newCandidate = SideEventParticipantModel(
                                          participantId: sp.participantId,
                                          participantName: sp.name,
                                          participantClass: sp.studentClass,
                                          participantDiv: sp.division,
                                          point: 0,
                                          rank: event.participants.length + 1,
                                          teamId: matchedTeamId,
                                          teamName: matchedTeamName,
                                        );

                                        event.participants.add(newCandidate);
                                        SideEventModel.calculateParticipantRanks(event.participants);

                                        if (event.rounds.isNotEmpty) {
                                          event.rounds[0].participants.add(
                                            SideEventRoundParticipantModel(
                                              participantId: sp.participantId,
                                              participantName: sp.name,
                                              participantClass: sp.studentClass,
                                              participantDiv: sp.division,
                                              roundPoint: 0,
                                              roundRank: event.rounds[0].participants.length + 1,
                                              teamId: matchedTeamId,
                                              teamName: matchedTeamName,
                                              roundStatus: 'passed',
                                            ),
                                          );
                                          event.rounds[0].calculateRanks();
                                        }

                                        final updatedRecord = SideEventModel(
                                          sideEventId: event.sideEventId,
                                          sideEventName: event.sideEventName,
                                          participantsCount: event.participants.length,
                                          participantsCategory: event.participantsCategory,
                                          scheduledDate: event.scheduledDate,
                                          scheduledTime: event.scheduledTime,
                                          sideEventColor: event.sideEventColor,
                                          sideEventMaxPoint: event.sideEventMaxPoint,
                                          sideEventStatus: event.sideEventStatus,
                                          totalRounds: event.rounds.length,
                                          rounds: event.rounds,
                                          participants: event.participants,
                                        );

                                        await appState.saveSideEventRecordToFirestore(updatedRecord);

                                        setModalState(() {
                                          selectedCandidateIds.remove(sp.participantId);
                                        });
                                        setState(() {});

                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('✨ Registered ${sp.name} into ${event.sideEventName}!'),
                                              backgroundColor: AppColors.success,
                                              duration: const Duration(seconds: 1),
                                            ),
                                          );
                                        }
                                      },
                                      icon: const Icon(Icons.add_rounded, size: 14),
                                      label: Text('Register', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold)),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: themeColor,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),

                      // TAB 0 BOTTOM BULK REGISTER BUTTON
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
                                        String matchedTeamId = '';
                                        String matchedTeamName = '';
                                        for (var t in appState.teamRecords) {
                                          if (t.members.any((m) => m.participantId == sp.participantId)) {
                                            matchedTeamId = t.teamId;
                                            matchedTeamName = '${t.teamName} (${t.teamHouse})';
                                            break;
                                          }
                                        }

                                        final newCandidate = SideEventParticipantModel(
                                          participantId: sp.participantId,
                                          participantName: sp.name,
                                          participantClass: sp.studentClass,
                                          participantDiv: sp.division,
                                          point: 0,
                                          rank: event.participants.length + 1,
                                          teamId: matchedTeamId,
                                          teamName: matchedTeamName,
                                        );

                                        event.participants.add(newCandidate);

                                        if (event.rounds.isNotEmpty) {
                                          event.rounds[0].participants.add(
                                            SideEventRoundParticipantModel(
                                              participantId: sp.participantId,
                                              participantName: sp.name,
                                              participantClass: sp.studentClass,
                                              participantDiv: sp.division,
                                              roundPoint: 0,
                                              roundRank: event.rounds[0].participants.length + 1,
                                              teamId: matchedTeamId,
                                              teamName: matchedTeamName,
                                              roundStatus: 'passed',
                                            ),
                                          );
                                        }
                                      }

                                      SideEventModel.calculateParticipantRanks(event.participants);
                                      if (event.rounds.isNotEmpty) {
                                        event.rounds[0].calculateRanks();
                                      }

                                      final updatedRecord = SideEventModel(
                                        sideEventId: event.sideEventId,
                                        sideEventName: event.sideEventName,
                                        participantsCount: event.participants.length,
                                        participantsCategory: event.participantsCategory,
                                        scheduledDate: event.scheduledDate,
                                        scheduledTime: event.scheduledTime,
                                        sideEventColor: event.sideEventColor,
                                        sideEventMaxPoint: event.sideEventMaxPoint,
                                        sideEventStatus: event.sideEventStatus,
                                        totalRounds: event.rounds.length,
                                        rounds: event.rounds,
                                        participants: event.participants,
                                      );

                                      await appState.saveSideEventRecordToFirestore(updatedRecord);

                                      final count = selectedCandidateIds.length;
                                      setModalState(() {
                                        selectedCandidateIds.clear();
                                      });
                                      setState(() {});

                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('✨ Registered $count students into ${event.sideEventName}!'),
                                            backgroundColor: AppColors.success,
                                            duration: const Duration(seconds: 2),
                                          ),
                                        );
                                      }
                                    },
                              icon: const Icon(Icons.how_to_reg_rounded, size: 18),
                              label: Text(
                                'Register Selected Students (${selectedCandidateIds.length})',
                                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: themeColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                        ),
                    ],

                    // TAB 1: REGISTERED STUDENTS LIST (WITH MULTI-UNREGISTER)
                    if (activeTabIndex == 1) ...[
                      // Select All Header Bar for Registered
                      if (registeredStudents.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Checkbox(
                                value: isAllRegisteredSelected,
                                activeColor: AppColors.error,
                                onChanged: (val) {
                                  setModalState(() {
                                    if (val == true) {
                                      selectedRegisteredIds.addAll(registeredStudents.map((e) => e.participantId));
                                    } else {
                                      selectedRegisteredIds.clear();
                                    }
                                  });
                                },
                              ),
                              Text('Select All Registered (${registeredStudents.length})', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold)),
                              const Spacer(),
                              if (selectedRegisteredIds.isNotEmpty)
                                Text('${selectedRegisteredIds.length} Selected', style: GoogleFonts.poppins(fontSize: 11, color: AppColors.error, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      const SizedBox(height: 6),

                      Expanded(
                        child: registeredStudents.isEmpty
                            ? Center(
                                child: Text('No students currently registered for this event.', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                              )
                            : ListView.separated(
                                itemCount: registeredStudents.length,
                                separatorBuilder: (_, _) => const Divider(height: 1),
                                itemBuilder: (context, idx) {
                                  final p = registeredStudents[idx];
                                  bool isChecked = selectedRegisteredIds.contains(p.participantId);

                                  return ListTile(
                                    dense: true,
                                    onTap: () {
                                      setModalState(() {
                                        if (isChecked) {
                                          selectedRegisteredIds.remove(p.participantId);
                                        } else {
                                          selectedRegisteredIds.add(p.participantId);
                                        }
                                      });
                                    },
                                    leading: Checkbox(
                                      value: isChecked,
                                      activeColor: AppColors.error,
                                      onChanged: (val) {
                                        setModalState(() {
                                          if (val == true) {
                                            selectedRegisteredIds.add(p.participantId);
                                          } else {
                                            selectedRegisteredIds.remove(p.participantId);
                                          }
                                        });
                                      },
                                    ),
                                    title: Text(p.participantName, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12)),
                                    subtitle: Text(
                                      '${p.participantId} • Class ${p.participantClass} (${p.participantDiv}) ${p.teamName.isNotEmpty ? "• ${p.teamName}" : ""}',
                                      style: GoogleFonts.poppins(fontSize: 10),
                                    ),
                                    trailing: OutlinedButton.icon(
                                      onPressed: () async {
                                        event.participants.removeWhere((x) => x.participantId == p.participantId);
                                        SideEventModel.calculateParticipantRanks(event.participants);

                                        for (var r in event.rounds) {
                                          r.participants.removeWhere((x) => x.participantId == p.participantId);
                                          r.calculateRanks();
                                        }

                                        final updatedRecord = SideEventModel(
                                          sideEventId: event.sideEventId,
                                          sideEventName: event.sideEventName,
                                          participantsCount: event.participants.length,
                                          participantsCategory: event.participantsCategory,
                                          scheduledDate: event.scheduledDate,
                                          scheduledTime: event.scheduledTime,
                                          sideEventColor: event.sideEventColor,
                                          sideEventMaxPoint: event.sideEventMaxPoint,
                                          sideEventStatus: event.sideEventStatus,
                                          totalRounds: event.rounds.length,
                                          rounds: event.rounds,
                                          participants: event.participants,
                                        );

                                        await appState.saveSideEventRecordToFirestore(updatedRecord);

                                        setModalState(() {
                                          selectedRegisteredIds.remove(p.participantId);
                                        });
                                        setState(() {});

                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('🗑️ Unregistered ${p.participantName} from ${event.sideEventName}.'),
                                              backgroundColor: AppColors.error,
                                              duration: const Duration(seconds: 1),
                                            ),
                                          );
                                        }
                                      },
                                      icon: const Icon(Icons.person_remove_rounded, size: 14, color: AppColors.error),
                                      label: Text('Unregister', style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.error)),
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

                      // TAB 1 BOTTOM BULK UNREGISTER BUTTON
                      if (registeredStudents.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: SizedBox(
                            width: double.infinity,
                            height: 44,
                            child: ElevatedButton.icon(
                              onPressed: selectedRegisteredIds.isEmpty
                                  ? null
                                  : () async {
                                      event.participants.removeWhere((x) => selectedRegisteredIds.contains(x.participantId));
                                      SideEventModel.calculateParticipantRanks(event.participants);

                                      for (var r in event.rounds) {
                                        r.participants.removeWhere((x) => selectedRegisteredIds.contains(x.participantId));
                                        r.calculateRanks();
                                      }

                                      final updatedRecord = SideEventModel(
                                        sideEventId: event.sideEventId,
                                        sideEventName: event.sideEventName,
                                        participantsCount: event.participants.length,
                                        participantsCategory: event.participantsCategory,
                                        scheduledDate: event.scheduledDate,
                                        scheduledTime: event.scheduledTime,
                                        sideEventColor: event.sideEventColor,
                                        sideEventMaxPoint: event.sideEventMaxPoint,
                                        sideEventStatus: event.sideEventStatus,
                                        totalRounds: event.rounds.length,
                                        rounds: event.rounds,
                                        participants: event.participants,
                                      );

                                      await appState.saveSideEventRecordToFirestore(updatedRecord);

                                      final count = selectedRegisteredIds.length;
                                      setModalState(() {
                                        selectedRegisteredIds.clear();
                                      });
                                      setState(() {});

                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('🗑️ Unregistered $count students from ${event.sideEventName}.'),
                                            backgroundColor: AppColors.error,
                                            duration: const Duration(seconds: 2),
                                          ),
                                        );
                                      }
                                    },
                              icon: const Icon(Icons.person_remove_rounded, size: 18),
                              label: Text(
                                'Unregister Selected Students (${selectedRegisteredIds.length})',
                                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
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

  // --- REAL FULL-WORKING SIDE EVENT RESULT SHEET PDF DOWNLOADER ---
  void _downloadEventResultPDF(SideEventModel event) async {
    final appState = Provider.of<AppState>(context, listen: false);
    final madrasaName = appState.madrasaName.isNotEmpty ? appState.madrasaName : 'Tanzeem Madrasa Cluster';

    try {
      await SideEventPdfService.downloadResultPdf(event, madrasaName);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('📄 Generated & downloaded valid PDF for ${event.sideEventName}!'),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error generating binary PDF: $e');
    }
  }

  // --- REDESIGNED MULTI-ROUND ROSTER & SCORE MANAGEMENT MODAL ---
  void _openEventRosterModal(SideEventModel event) {
    final appState = Provider.of<AppState>(context, listen: false);
    final isDark = appState.isDarkMode;
    Color themeColor = Color(int.parse(event.sideEventColor));
    bool isCompleted = event.sideEventStatus == 'completed';

    // Ensure rounds list is initialized
    if (event.rounds.isEmpty) {
      final round1Candidates = event.participants
          .map((p) => SideEventRoundParticipantModel(
                participantId: p.participantId,
                participantName: p.participantName,
                participantClass: p.participantClass,
                participantDiv: p.participantDiv,
                roundPoint: p.point,
                roundRank: p.rank,
                teamId: p.teamId,
                teamName: p.teamName,
                roundStatus: 'passed',
              ))
          .toList();

      event.rounds.add(
        SideEventRoundModel(
          roundNumber: 1,
          minPointToPass: 0,
          participants: round1Candidates,
        ),
      );
    }

    int activeRoundIndex = 0;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setRosterState) {
            final activeRound = event.rounds[activeRoundIndex.clamp(0, event.rounds.length - 1)];

            return AlertDialog(
              backgroundColor: isDark ? AppColors.cardDark : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Section Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: themeColor.withAlpha(30), shape: BoxShape.circle),
                        child: Icon(Icons.stars_rounded, color: themeColor, size: 22),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${event.sideEventName} Score & Round Sheet',
                              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            if (isCompleted)
                              Text('🔒 Watch Mode (Completed Event - Read Only)', style: GoogleFonts.poppins(fontSize: 10, color: AppColors.error, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: themeColor.withAlpha(25), borderRadius: BorderRadius.circular(8)),
                        child: Text(
                          'Max Mark: ${event.sideEventMaxPoint}',
                          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12, color: themeColor),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Divider(height: 1),
                  const SizedBox(height: 10),

                  // Round Tabs & "+ Add Next Round" Action Button
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        ...List.generate(event.rounds.length, (idx) {
                          bool isSel = activeRoundIndex == idx;
                          String roundTitle = '${idx + 1}${idx == 0 ? "st" : (idx == 1 ? "nd" : (idx == 2 ? "rd" : "th"))} Round';

                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                FilterChip(
                                  selected: isSel,
                                  showCheckmark: false,
                                  avatar: CircleAvatar(
                                    radius: 10,
                                    backgroundColor: isSel ? Colors.white : themeColor.withAlpha(40),
                                    child: Text('${idx + 1}', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isSel ? themeColor : Colors.white)),
                                  ),
                                  label: Text(roundTitle),
                                  labelStyle: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: isSel ? Colors.white : (isDark ? AppColors.textLight : AppColors.textDark)),
                                  selectedColor: themeColor,
                                  backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                                  onSelected: (_) => setRosterState(() => activeRoundIndex = idx),
                                ),
                                if (!isCompleted && event.rounds.length > 1 && idx > 0) ...[
                                  InkWell(
                                    onTap: () {
                                      setRosterState(() {
                                        event.rounds.removeAt(idx);
                                        if (activeRoundIndex >= event.rounds.length) {
                                          activeRoundIndex = event.rounds.length - 1;
                                        }
                                      });
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('🗑️ Removed Round ${idx + 1}'),
                                          backgroundColor: AppColors.error,
                                          duration: const Duration(seconds: 1),
                                        ),
                                      );
                                    },
                                    borderRadius: BorderRadius.circular(12),
                                    child: const Padding(
                                      padding: EdgeInsets.all(4.0),
                                      child: Icon(Icons.remove_circle_rounded, size: 18, color: AppColors.error),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        }),
                        if (!isCompleted) ...[
                          const SizedBox(width: 8),
                          // Add Next Round Button
                          ElevatedButton.icon(
                            onPressed: () {
                              final currentRound = event.rounds.last;
                              currentRound.updateQualificationStatuses();

                              final passedCandidates = currentRound.participants.where((p) => p.roundPoint >= currentRound.minPointToPass).toList();

                              if (passedCandidates.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('⚠️ Cannot create next round! No candidates scored >= ${currentRound.minPointToPass} in Round ${currentRound.roundNumber}.'),
                                    backgroundColor: AppColors.error,
                                  ),
                                );
                                return;
                              }

                              final nextRoundNumber = event.rounds.length + 1;
                              final nextRoundCandidates = passedCandidates
                                  .map((p) => SideEventRoundParticipantModel(
                                        participantId: p.participantId,
                                        participantName: p.participantName,
                                        participantClass: p.participantClass,
                                        participantDiv: p.participantDiv,
                                        roundPoint: 0,
                                        roundRank: 1,
                                        teamId: p.teamId,
                                        teamName: p.teamName,
                                        roundStatus: 'passed',
                                      ))
                                  .toList();

                              final newRound = SideEventRoundModel(
                                roundNumber: nextRoundNumber,
                                minPointToPass: (currentRound.minPointToPass + 5).clamp(0, event.sideEventMaxPoint),
                                participants: nextRoundCandidates,
                              );
                              newRound.calculateRanks();

                              setRosterState(() {
                                event.rounds.add(newRound);
                                activeRoundIndex = event.rounds.length - 1;
                              });

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('✨ Round $nextRoundNumber created with ${passedCandidates.length} qualified candidates!'),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            },
                            icon: const Icon(Icons.add_rounded, size: 16),
                            label: Text('+ Add Next Round', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.secondary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: 620,
                height: 480,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Position Winners Podium Banner in Roster Sheet
                    Builder(
                      builder: (context) {
                        final sortedList = List<SideEventParticipantModel>.from(event.participants);
                        sortedList.sort((a, b) => b.point.compareTo(a.point));
                        final topWinners = sortedList.where((p) => p.point > 0).take(3).toList();

                        if (topWinners.isEmpty) return const SizedBox.shrink();

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: themeColor.withAlpha(80)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text('👑 ', style: TextStyle(fontSize: 14)),
                                  Text(
                                    'Event Position Winners:',
                                    style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? AppColors.textLight : AppColors.textDark),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: topWinners.map((w) {
                                  Color teamColor = themeColor;
                                  final matchTeam = appState.teamRecords.where((t) => t.teamId == w.teamId || w.teamName.toLowerCase().contains(t.teamName.toLowerCase())).toList();
                                  if (matchTeam.isNotEmpty) {
                                    try {
                                      teamColor = Color(int.parse(matchTeam.first.houseColor));
                                    } catch (_) {}
                                  }

                                  final rankBadge = w.rank == 1 ? '🥇 1st Place' : (w.rank == 2 ? '🥈 2nd Place' : '🥉 3rd Place');

                                  return Expanded(
                                    child: Container(
                                      margin: const EdgeInsets.only(right: 6),
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: teamColor.withAlpha(25),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: teamColor.withAlpha(90)),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(rankBadge, style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold)),
                                          const SizedBox(height: 2),
                                          Text(
                                            w.participantName,
                                            style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: isDark ? AppColors.textLight : AppColors.textDark),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                                decoration: BoxDecoration(color: teamColor, borderRadius: BorderRadius.circular(4)),
                                                child: Text(
                                                  w.teamName.isNotEmpty ? w.teamName : 'No Team',
                                                  style: GoogleFonts.poppins(fontSize: 8.5, fontWeight: FontWeight.bold, color: Colors.white),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              Text('${w.point} Pts', style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: teamColor)),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    // Round Cutoff Min Point Configuration Header
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.filter_list_rounded, color: themeColor, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Round ${activeRound.roundNumber} Min Cutoff Mark to Pass:',
                            style: GoogleFonts.poppins(fontSize: 11.5, fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          SizedBox(
                            width: 90,
                            height: 38,
                            child: Container(
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF0F172A) : Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: themeColor.withAlpha(120)),
                              ),
                              child: TextField(
                                readOnly: isCompleted,
                                controller: TextEditingController(text: '${activeRound.minPointToPass}'),
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                onChanged: (val) {
                                  if (isCompleted) return;
                                  activeRound.minPointToPass = int.tryParse(val) ?? 0;
                                  activeRound.updateQualificationStatuses();
                                  setRosterState(() {});
                                },
                                style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold),
                                decoration: const InputDecoration(
                                  hintText: 'Min Pts',
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                                ),
                              ),
                            ),
                          ),
                          if (!isCompleted && event.rounds.length > 1 && activeRoundIndex > 0) ...[
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: () {
                                setRosterState(() {
                                  event.rounds.removeAt(activeRoundIndex);
                                  if (activeRoundIndex >= event.rounds.length) {
                                    activeRoundIndex = event.rounds.length - 1;
                                  }
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('🗑️ Removed Round ${activeRoundIndex + 2}'),
                                    backgroundColor: AppColors.error,
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.delete_forever_rounded, color: AppColors.error, size: 20),
                              tooltip: 'Delete This Round',
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Students Score Entry Table for Active Round
                    Expanded(
                      child: activeRound.participants.isEmpty
                          ? Center(
                              child: Text(
                                'No candidates qualified in Round ${activeRound.roundNumber}.',
                                style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                              ),
                            )
                          : ListView.separated(
                              itemCount: activeRound.participants.length,
                              separatorBuilder: (_, _) => const Divider(height: 1),
                              itemBuilder: (context, idx) {
                                final p = activeRound.participants[idx];
                                bool isPassed = p.roundPoint >= activeRound.minPointToPass;
                                final rankStr = p.roundRank == 1 ? '🥇 1st' : (p.roundRank == 2 ? '🥈 2nd' : (p.roundRank == 3 ? '🥉 3rd' : '#${p.roundRank}'));

                                return ListTile(
                                  dense: true,
                                  leading: CircleAvatar(
                                    radius: 14,
                                    backgroundColor: themeColor.withAlpha(30),
                                    child: Text(rankStr, style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.bold, color: themeColor)),
                                  ),
                                  title: Row(
                                    children: [
                                      Text(p.participantName, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12)),
                                      const SizedBox(width: 8),
                                      // Passed / Failed Badge
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: isPassed ? AppColors.success.withAlpha(20) : AppColors.error.withAlpha(20),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          isPassed ? 'Passed ✅' : 'Failed ❌',
                                          style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.bold, color: isPassed ? AppColors.success : AppColors.error),
                                        ),
                                      ),
                                    ],
                                  ),
                                  subtitle: Text(
                                    '${p.participantId} • Class ${p.participantClass} (${p.participantDiv}) ${p.teamName.isNotEmpty ? "• ${p.teamName}" : ""}',
                                    style: GoogleFonts.poppins(fontSize: 10),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // REDESIGNED SCORE INPUT FIELD (SEARCH BAR STYLING)
                                      Container(
                                        width: 105,
                                        height: 38,
                                        decoration: BoxDecoration(
                                          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                                        ),
                                        child: TextField(
                                          readOnly: isCompleted,
                                          controller: TextEditingController(text: '${p.roundPoint}'),
                                          keyboardType: TextInputType.number,
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? AppColors.textLight : AppColors.textDark),
                                          onChanged: (val) {
                                            if (isCompleted) return;
                                            int entered = int.tryParse(val) ?? 0;

                                            // MAX MARK VALIDATION: Must be <= sideEventMaxPoint
                                            if (entered > event.sideEventMaxPoint) {
                                              entered = event.sideEventMaxPoint;
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('⚠️ Entered mark cannot exceed Max Mark (${event.sideEventMaxPoint})! Capped at ${event.sideEventMaxPoint}.'),
                                                  backgroundColor: AppColors.warning,
                                                  duration: const Duration(seconds: 2),
                                                ),
                                              );
                                            }

                                            p.roundPoint = entered;
                                            activeRound.calculateRanks();
                                            activeRound.updateQualificationStatuses();

                                            // Sync back to top level participants if in Round 1
                                            if (activeRound.roundNumber == 1) {
                                              final topIdx = event.participants.indexWhere((x) => x.participantId == p.participantId);
                                              if (topIdx != -1) {
                                                event.participants[topIdx].point = p.roundPoint;
                                                event.participants[topIdx].rank = p.roundRank;
                                              }
                                            }

                                            setRosterState(() {});
                                          },
                                          decoration: InputDecoration(
                                            hintText: 'Score',
                                            hintStyle: GoogleFonts.poppins(fontSize: 11, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
                                            border: InputBorder.none,
                                            contentPadding: const EdgeInsets.symmetric(vertical: 8),
                                          ),
                                        ),
                                      ),
                                      if (!isCompleted)
                                        IconButton(
                                          icon: const Icon(Icons.remove_circle_outline_rounded, size: 18, color: AppColors.error),
                                          onPressed: () {
                                            setRosterState(() {
                                              activeRound.participants.removeAt(idx);
                                              activeRound.calculateRanks();
                                              activeRound.updateQualificationStatuses();
                                            });
                                          },
                                        ),
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
                if (!isCompleted)
                  ElevatedButton.icon(
                    onPressed: () async {
                      for (var r in event.rounds) {
                        r.calculateRanks();
                        r.updateQualificationStatuses();
                      }

                      final updatedRecord = SideEventModel(
                        sideEventId: event.sideEventId,
                        sideEventName: event.sideEventName,
                        participantsCount: event.participants.length,
                        participantsCategory: event.participantsCategory,
                        scheduledDate: event.scheduledDate,
                        scheduledTime: event.scheduledTime,
                        sideEventColor: event.sideEventColor,
                        sideEventMaxPoint: event.sideEventMaxPoint,
                        sideEventStatus: event.sideEventStatus,
                        totalRounds: event.rounds.length,
                        rounds: event.rounds,
                        participants: event.participants,
                      );

                      await appState.saveSideEventRecordWithStatusRule(updatedRecord);

                      if (ctx.mounted) {
                        Navigator.of(ctx).pop();
                        final isFinal = event.sideEventStatus == 'completed';
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isFinal
                                  ? '✅ Event completed! Scores & ranks published to Cloud Firestore & team scores updated!'
                                  : '💾 Scores saved locally in SharedPreferences (Draft Mode). Mark event as COMPLETED to sync to Cloud Firestore.',
                            ),
                            backgroundColor: isFinal ? AppColors.success : AppColors.secondary,
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.save_rounded, size: 16),
                    label: Text('Save Round Scores & Ranks', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(backgroundColor: themeColor, foregroundColor: Colors.white),
                  ),
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text('Close', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDark = appState.isDarkMode;

    // REAL FIRESTORE VALUES ONLY (No dummy data)
    final eventsList = appState.sideEventRecords;

    final filteredEvents = eventsList.where((e) {
      final matchesSearch = _searchQuery.isEmpty ||
          e.sideEventName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          e.participantsCategory.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesCategory = _selectedCategory == 'All' || e.participantsCategory == _selectedCategory;
      final matchesStatus = _selectedStatus == 'All' || e.sideEventStatus == _selectedStatus;

      return matchesSearch && matchesCategory && matchesStatus;
    }).toList();

    final liveCount = eventsList.where((e) => e.sideEventStatus == 'live now').length;
    final scheduledCount = eventsList.where((e) => e.sideEventStatus == 'pending').length;
    final totalRegistrations = eventsList.fold<int>(0, (sum, e) => sum + e.participants.length);

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
                            color: AppColors.secondary.withAlpha(25),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.festival_rounded, color: AppColors.secondary, size: 28),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Side Events & Exhibitions',
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppColors.textLight : AppColors.textDark,
                              ),
                            ),
                            Text(
                              'Off-stage contests, calligraphy, quiz, exhibitions, and venue registrations',
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
                  onPressed: () => _openAddSideEventSheet(),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: Text('Host New Side Event', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
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
                    title: 'Total Side Events',
                    value: '${eventsList.length}',
                    subtitle: 'Off-Stage Contests',
                    icon: Icons.event_available_rounded,
                    color: AppColors.secondary,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMetricCard(
                    context,
                    title: 'Live / Ongoing Contests 🔴',
                    value: '$liveCount',
                    subtitle: 'Currently Active',
                    icon: Icons.sensors_rounded,
                    color: const Color(0xFFEF4444),
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMetricCard(
                    context,
                    title: 'Scheduled Upcoming',
                    value: '$scheduledCount',
                    subtitle: 'Pending Schedule',
                    icon: Icons.schedule_rounded,
                    color: const Color(0xFF3B82F6),
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMetricCard(
                    context,
                    title: 'Total Registrations',
                    value: '$totalRegistrations',
                    subtitle: 'Candidates Enrolled',
                    icon: Icons.how_to_reg_rounded,
                    color: const Color(0xFF10B981),
                    isDark: isDark,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Redesigned Modern Search & Filter Panel
            GlassCard(
              padding: const EdgeInsets.all(20),
              borderRadius: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Search Field & Reset Action Bar
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
                              prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColors.secondary),
                              suffixIcon: _searchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear_rounded, size: 18),
                                      onPressed: () => setState(() => _searchQuery = ''),
                                    )
                                  : null,
                              hintText: 'Search side event by name or category...',
                              hintStyle: GoogleFonts.poppins(fontSize: 12, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ),
                      if (_searchQuery.isNotEmpty || _selectedCategory != 'All' || _selectedStatus != 'All') ...[
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: () {
                            setState(() {
                              _searchQuery = '';
                              _selectedCategory = 'All';
                              _selectedStatus = 'All';
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

                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 14),

                  // Filter Row 1: Category Pill Filters
                  Row(
                    children: [
                      Text('Category:', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? AppColors.textLight : AppColors.textDark)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: ['All', 'Sub-Junior', 'Junior', 'Senior', 'Super Senior'].map((cat) {
                              bool isSel = _selectedCategory == cat;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: FilterChip(
                                  selected: isSel,
                                  showCheckmark: false,
                                  label: Text(cat),
                                  labelStyle: GoogleFonts.poppins(
                                    fontSize: 11.5,
                                    fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                                    color: isSel ? Colors.white : (isDark ? AppColors.textLight : AppColors.textDark),
                                  ),
                                  selectedColor: AppColors.secondary,
                                  backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                                  side: BorderSide(color: isSel ? AppColors.secondary : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0))),
                                  onSelected: (_) => setState(() => _selectedCategory = cat),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Filter Row 2: Status Pill Filters
                  Row(
                    children: [
                      Text('Status:', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? AppColors.textLight : AppColors.textDark)),
                      const SizedBox(width: 24),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              {'value': 'All', 'label': 'All Statuses', 'icon': '📋'},
                              {'value': 'pending', 'label': 'Scheduled', 'icon': '⏳'},
                              {'value': 'live now', 'label': 'Live Now', 'icon': '🔴'},
                              {'value': 'completed', 'label': 'Completed', 'icon': '✅'},
                              {'value': 'canceled', 'label': 'Canceled', 'icon': '❌'},
                            ].map((st) {
                              final val = st['value']!;
                              final label = st['label']!;
                              final icon = st['icon']!;
                              bool isSel = _selectedStatus == val;

                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: FilterChip(
                                  selected: isSel,
                                  showCheckmark: false,
                                  avatar: Text(icon, style: const TextStyle(fontSize: 11)),
                                  label: Text(label),
                                  labelStyle: GoogleFonts.poppins(
                                    fontSize: 11.5,
                                    fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                                    color: isSel ? Colors.white : (isDark ? AppColors.textLight : AppColors.textDark),
                                  ),
                                  selectedColor: val == 'live now'
                                      ? const Color(0xFFEF4444)
                                      : (val == 'completed' ? const Color(0xFF10B981) : AppColors.primary),
                                  backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                                  side: BorderSide(color: isSel ? AppColors.primary : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0))),
                                  onSelected: (_) => setState(() => _selectedStatus = val),
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

            // Display REAL Firestore Side Events or Empty State
            if (filteredEvents.isEmpty)
              GlassCard(
                padding: const EdgeInsets.all(40),
                borderRadius: 20,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withAlpha(20),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.event_busy_rounded, size: 48, color: AppColors.secondary),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        eventsList.isEmpty ? 'No Side Events Configured Yet' : 'No Side Events Found',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18, color: isDark ? AppColors.textLight : AppColors.textDark),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        eventsList.isEmpty
                            ? 'Configure off-stage contests, calligraphy, quiz, or exhibitions by clicking below.'
                            : 'Try adjusting your search query or category status filters.',
                        style: GoogleFonts.poppins(fontSize: 13, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () => _openAddSideEventSheet(),
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: Text('Host New Side Event', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.48,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                ),
                itemCount: filteredEvents.length,
                itemBuilder: (context, idx) {
                  final event = filteredEvents[idx];
                  Color eventColor = Color(int.parse(event.sideEventColor));

                  String statusBadgeText;
                  Color statusBadgeColor;
                  if (event.sideEventStatus == 'live now') {
                    statusBadgeText = '🔴 Live Now';
                    statusBadgeColor = const Color(0xFFEF4444);
                  } else if (event.sideEventStatus == 'completed') {
                    statusBadgeText = '✅ Completed';
                    statusBadgeColor = const Color(0xFF10B981);
                  } else if (event.sideEventStatus == 'canceled') {
                    statusBadgeText = '❌ Canceled';
                    statusBadgeColor = Colors.grey;
                  } else {
                    statusBadgeText = '⏳ Scheduled';
                    statusBadgeColor = const Color(0xFF3B82F6);
                  }

                  return GlassCard(
                    padding: const EdgeInsets.all(20),
                    borderRadius: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Row with Interactive Status Popup Menu
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: eventColor.withAlpha(30),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: eventColor.withAlpha(100)),
                                  ),
                                  child: Center(
                                    child: Icon(Icons.festival_rounded, color: eventColor, size: 22),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      event.sideEventName,
                                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15, color: isDark ? AppColors.textLight : AppColors.textDark),
                                    ),
                                    Text(
                                      'ID: ${event.sideEventId} • Max ${event.sideEventMaxPoint} Pts • ${event.rounds.length} Rounds',
                                      style: GoogleFonts.poppins(fontSize: 11, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            // Interactive Status Updation Badge Popup
                            PopupMenuButton<String>(
                              tooltip: 'Update Event Status',
                              onSelected: (newStatus) => _updateEventStatus(appState, event, newStatus),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 'live now',
                                  child: Row(
                                    children: [
                                      const Icon(Icons.sensors_rounded, color: Color(0xFFEF4444), size: 18),
                                      const SizedBox(width: 8),
                                      Text('🔴 Set Live Now', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFFEF4444))),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'completed',
                                  child: Row(
                                    children: [
                                      const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 18),
                                      const SizedBox(width: 8),
                                      Text('✅ Set Completed', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF10B981))),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'pending',
                                  child: Row(
                                    children: [
                                      const Icon(Icons.schedule_rounded, color: Color(0xFF3B82F6), size: 18),
                                      const SizedBox(width: 8),
                                      Text('⏳ Reset to Scheduled', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF3B82F6))),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'canceled',
                                  child: Row(
                                    children: [
                                      const Icon(Icons.cancel_rounded, color: Colors.grey, size: 18),
                                      const SizedBox(width: 8),
                                      Text('❌ Set Canceled', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                                    ],
                                  ),
                                ),
                              ],
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: statusBadgeColor.withAlpha(25),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: statusBadgeColor.withAlpha(80)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      statusBadgeText,
                                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 11, color: statusBadgeColor),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(Icons.arrow_drop_down_rounded, size: 16, color: statusBadgeColor),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),
                        const Divider(height: 1),
                        const SizedBox(height: 14),

                        // Category & Schedule Timing Details
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Row(
                                children: [
                                  const Icon(Icons.category_rounded, size: 16, color: AppColors.secondary),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      'Cat: ${event.participantsCategory}',
                                      style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: eventColor),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 2,
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_month_rounded, size: 16, color: AppColors.primary),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      event.scheduledDate,
                                      style: GoogleFonts.poppins(fontSize: 11),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        Row(
                          children: [
                            const Icon(Icons.access_time_rounded, size: 16, color: AppColors.warning),
                            const SizedBox(width: 6),
                            Text(event.scheduledTime, style: GoogleFonts.poppins(fontSize: 11)),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // --- TOP POSITION WINNERS SUMMARY CONTAINER IN CARD WHITESPACE ---
                        _buildCardWinnersSummary(event, appState, isDark),

                        const Spacer(),

                        // Action Buttons Row (Status Dependent Rules)
                        Row(
                          children: [
                            // 1. REGISTER STUDENT BUTTON (Hidden if completed)
                            if (event.sideEventStatus != 'completed') ...[
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _openRegisterStudentModal(event),
                                  icon: const Icon(Icons.person_add_rounded, size: 15),
                                  label: Text('Register Student', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: eventColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],

                            // 2. DOWNLOAD RESULT BUTTON (Only shown if status is COMPLETED!)
                            if (event.sideEventStatus == 'completed') ...[
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _downloadEventResultPDF(event),
                                  icon: const Icon(Icons.download_rounded, size: 15),
                                  label: Text('Download Result', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF10B981),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],

                            // 3. ROSTER & SCORES BUTTON
                            // - Pending/Canceled: Cannot access, shows warning toast
                            // - Live Now: Can access & edit
                            // - Completed: Can access, but watch only (read-only)
                            OutlinedButton.icon(
                              onPressed: (event.sideEventStatus == 'pending' || event.sideEventStatus == 'canceled')
                                  ? () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('⚠️ Rounds & Score sheet can only be accessed when event is LIVE NOW or COMPLETED.'),
                                          backgroundColor: AppColors.warning,
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                    }
                                  : () => _openEventRosterModal(event),
                              icon: Icon(event.sideEventStatus == 'completed' ? Icons.visibility_rounded : Icons.military_tech_rounded, size: 15),
                              label: Text(
                                event.sideEventStatus == 'completed' ? 'Watch Scores' : 'Rounds & Scores',
                                style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: (event.sideEventStatus == 'pending' || event.sideEventStatus == 'canceled') ? Colors.grey : eventColor,
                                side: BorderSide(color: (event.sideEventStatus == 'pending' || event.sideEventStatus == 'canceled') ? Colors.grey.withAlpha(80) : eventColor.withAlpha(100)),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                            const SizedBox(width: 8),

                            // 4. EDIT EVENT SETUP BUTTON
                            IconButton(
                              onPressed: () => _openAddSideEventSheet(event),
                              icon: const Icon(Icons.edit_note_rounded, size: 20),
                              color: isDark ? AppColors.subtextLight : AppColors.subtextDark,
                              tooltip: 'Edit Event Setup',
                            ),

                            // 5. DELETE EVENT BUTTON
                            IconButton(
                              onPressed: () => _confirmDeleteSideEvent(context, appState, event),
                              icon: const Icon(Icons.delete_outline_rounded, size: 20),
                              color: AppColors.error,
                              tooltip: 'Delete Side Event',
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

  Widget _buildCardWinnersSummary(SideEventModel event, AppState appState, bool isDark) {
    Color themeColor = Color(int.parse(event.sideEventColor));
    final participants = List<SideEventParticipantModel>.from(event.participants);
    participants.sort((a, b) => b.point.compareTo(a.point));

    final topWinners = participants.where((p) => p.point > 0).take(3).toList();

    if (topWinners.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Icon(Icons.emoji_events_outlined, size: 16, color: Colors.grey.shade400),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                event.participants.isEmpty
                    ? 'No candidates registered yet.'
                    : '${event.participants.length} Registered • Awaiting score entry',
                style: GoogleFonts.poppins(fontSize: 10.5, color: isDark ? AppColors.subtextLight : AppColors.subtextDark, fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🏆 ', style: TextStyle(fontSize: 11)),
              Text('Top Position Winners:', style: GoogleFonts.poppins(fontSize: 10.5, fontWeight: FontWeight.bold, color: isDark ? AppColors.textLight : AppColors.textDark)),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: topWinners.map((w) {
              Color teamColor = themeColor;
              final matchTeam = appState.teamRecords.where((t) => t.teamId == w.teamId || w.teamName.toLowerCase().contains(t.teamName.toLowerCase())).toList();
              if (matchTeam.isNotEmpty) {
                try {
                  teamColor = Color(int.parse(matchTeam.first.houseColor));
                } catch (_) {}
              }

              final rankBadge = w.rank == 1 ? '🥇 1st' : (w.rank == 2 ? '🥈 2nd' : '🥉 3rd');

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: teamColor.withAlpha(22),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: teamColor.withAlpha(80), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(rankBadge, style: GoogleFonts.poppins(fontSize: 9.5, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 5),
                    Text(w.participantName, style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: isDark ? AppColors.textLight : AppColors.textDark)),
                    const SizedBox(width: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(color: teamColor, borderRadius: BorderRadius.circular(4)),
                      child: Text(
                        w.teamName.isNotEmpty ? w.teamName : 'No Team',
                        style: GoogleFonts.poppins(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text('${w.point} Pts', style: GoogleFonts.poppins(fontSize: 9.5, fontWeight: FontWeight.bold, color: teamColor)),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
