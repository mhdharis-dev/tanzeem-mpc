// Library: participants_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/models/participant_model.dart';
import '../../core/models/side_event_model.dart';
import '../../core/models/team_model.dart';
import '../../core/providers/app_state.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/glass_card.dart';
import '../../core/utils/responsive.dart';

class ParticipantsScreen extends StatefulWidget {
  const ParticipantsScreen({super.key});

  @override
  State<ParticipantsScreen> createState() => _ParticipantsScreenState();
}

class _ParticipantsScreenState extends State<ParticipantsScreen> {
  String _searchQuery = '';
  String _selectedCategoryFilter = 'All';
  String _selectedClassFilter = 'All';
  String _selectedGenderFilter = 'All';
  String _selectedTeamFilter = 'All';
  String _selectedMedalFilter = 'All';
  String _selectedParticipationFilter = 'All';

  // --- OPEN STUDENT PARTICIPATED PROGRAMS & SIDE EVENTS MODAL SHEET ---
  void _openStudentProgramsSheet(BuildContext context, ParticipantModel p, AppState appState) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Find Team Info
    TeamModel? studentTeam;
    Color houseColor = AppColors.primary;
    String teamName = 'Unassigned';

    final matchedTeams = appState.teamRecords.where((t) => t.members.any((m) => m.participantId == p.participantId)).toList();
    if (matchedTeams.isNotEmpty) {
      studentTeam = matchedTeams.first;
      teamName = studentTeam.teamName;
      try {
        houseColor = Color(int.parse(studentTeam.houseColor));
      } catch (_) {}
    }

    // Find Side Events
    int totalPoints = 0;
    int goldCount = 0;
    int silverCount = 0;
    int bronzeCount = 0;

    final studentSideEvents = <Map<String, dynamic>>[];
    for (var se in appState.sideEventRecords) {
      final matches = se.participants.where((sp) => sp.participantId == p.participantId).toList();
      if (matches.isNotEmpty) {
        final sp = matches.first;
        totalPoints += sp.point;
        if (sp.rank == 1 && sp.point > 0) goldCount++;
        if (sp.rank == 2 && sp.point > 0) silverCount++;
        if (sp.rank == 3 && sp.point > 0) bronzeCount++;

        studentSideEvents.add({
          'event': se,
          'participant': sp,
        });
      }
    }

    // Find Stage Programs
    final studentPrograms = appState.realPrograms.where((prog) =>
      prog.participantId == p.participantId ||
      prog.participantName.toLowerCase() == p.name.toLowerCase()
    ).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(ctx).size.height * 0.90,
            ),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              border: Border.all(color: isDark ? AppColors.glassBorderDark : AppColors.glassBorderLight),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
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

              // Student Summary Card Header
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: houseColor.withAlpha(30),
                    child: Text(
                      p.name.isNotEmpty ? p.name[0].toUpperCase() : 'S',
                      style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: houseColor),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                p.name,
                                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? AppColors.textLight : AppColors.textDark),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(6)),
                              child: Text(
                                'Chest #${p.participantId}',
                                style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${p.studentClass} (${p.division}) • ${p.category}',
                          style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.secondary),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 10,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(color: houseColor, borderRadius: BorderRadius.circular(6)),
                              child: Text(
                                teamName,
                                style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ),
                            Text('🏆 Total: $totalPoints Pts', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary)),
                            Text('🥇 $goldCount  🥈 $silverCount  🥉 $bronzeCount', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 12),

              // Tabbed Content: Side Events vs Stage Programs
              Expanded(
                child: DefaultTabController(
                  length: 2,
                  child: Column(
                    children: [
                      TabBar(
                        labelColor: AppColors.primary,
                        unselectedLabelColor: isDark ? AppColors.subtextLight : AppColors.subtextDark,
                        indicatorColor: AppColors.primary,
                        tabs: [
                          Tab(text: 'Side Events (${studentSideEvents.length})'),
                          Tab(text: 'Stage Programs (${studentPrograms.length})'),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Expanded(
                        child: TabBarView(
                          children: [
                            // 1. SIDE EVENTS LIST
                            studentSideEvents.isEmpty
                                ? Center(
                                    child: Text('No side events registered for this student.', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                                  )
                                : ListView.separated(
                                    itemCount: studentSideEvents.length,
                                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                                    itemBuilder: (context, idx) {
                                      final item = studentSideEvents[idx];
                                      final SideEventModel event = item['event'];
                                      final SideEventParticipantModel sp = item['participant'];
                                      final Color eventColor = Color(int.parse(event.sideEventColor));

                                      final rankBadge = sp.rank == 1
                                          ? '🥇 1st Rank'
                                          : (sp.rank == 2 ? '🥈 2nd Rank' : (sp.rank == 3 ? '🥉 3rd Rank' : 'Rank #${sp.rank}'));

                                      return Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                                          borderRadius: BorderRadius.circular(14),
                                          border: Border.all(color: eventColor.withAlpha(90)),
                                        ),
                                        child: Row(
                                          children: [
                                            // Event Color indicator badge
                                            Container(
                                              width: 10,
                                              height: 48,
                                              decoration: BoxDecoration(color: eventColor, borderRadius: BorderRadius.circular(6)),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Text(event.sideEventName, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13, color: isDark ? AppColors.textLight : AppColors.textDark)),
                                                      const SizedBox(width: 8),
                                                      Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                                        decoration: BoxDecoration(color: eventColor.withAlpha(30), borderRadius: BorderRadius.circular(4)),
                                                        child: Text(event.sideEventId, style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.bold, color: eventColor)),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 3),
                                                  Text(
                                                    'Category: ${event.participantsCategory} • Status: ${event.sideEventStatus.toUpperCase()}',
                                                    style: GoogleFonts.poppins(fontSize: 10.5, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
                                                  ),
                                                  const SizedBox(height: 3),
                                                  Row(
                                                    children: [
                                                      const Icon(Icons.access_time_rounded, size: 12, color: AppColors.warning),
                                                      const SizedBox(width: 4),
                                                      Text('${event.scheduledDate} (${event.scheduledTime})', style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600)),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                  decoration: BoxDecoration(color: AppColors.primary.withAlpha(25), borderRadius: BorderRadius.circular(6)),
                                                  child: Text(
                                                    '${sp.point} / ${event.sideEventMaxPoint} Pts',
                                                    style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(rankBadge, style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold)),
                                              ],
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),

                            // 2. STAGE PROGRAMS LIST (No event color, student point, or rank)
                            studentPrograms.isEmpty
                                ? Center(
                                    child: Text('No stage programs registered for this student.', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                                  )
                                : ListView.separated(
                                    itemCount: studentPrograms.length,
                                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                                    itemBuilder: (context, idx) {
                                      final prog = studentPrograms[idx];

                                      return Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                                          borderRadius: BorderRadius.circular(14),
                                          border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(10),
                                              decoration: BoxDecoration(color: AppColors.secondary.withAlpha(25), shape: BoxShape.circle),
                                              child: const Icon(Icons.mic_external_on_rounded, color: AppColors.secondary, size: 20),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Text(prog.programName, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13, color: isDark ? AppColors.textLight : AppColors.textDark)),
                                                      const SizedBox(width: 8),
                                                      Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                                        decoration: BoxDecoration(color: AppColors.secondary.withAlpha(30), borderRadius: BorderRadius.circular(4)),
                                                        child: Text(prog.programId, style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.secondary)),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 3),
                                                  Text(
                                                    'Category: ${prog.category} • Type: ${prog.programType.toUpperCase()}',
                                                    style: GoogleFonts.poppins(fontSize: 10.5, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
                                                  ),
                                                  const SizedBox(height: 3),
                                                  Row(
                                                    children: [
                                                      const Icon(Icons.schedule_rounded, size: 12, color: AppColors.primary),
                                                      const SizedBox(width: 4),
                                                      Text('Start Time: ${prog.startTime} • Duration: ${prog.duration}', style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600)),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: prog.status == 'live' ? AppColors.error : (prog.status == 'completed' ? AppColors.success : AppColors.primary),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                prog.status.toUpperCase(),
                                                style: GoogleFonts.poppins(fontSize: 9.5, fontWeight: FontWeight.bold, color: Colors.white),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
  }

  void _showAddParticipantBottomSheet(BuildContext context, AppState appState) {
    final nextId = ParticipantModel.generateNextParticipantId(appState.realParticipants.length);

    final nameController = TextEditingController();
    final classController = TextEditingController(text: 'Class 5');
    final divisionController = TextEditingController(text: 'A');
    final parentNameController = TextEditingController();
    final phoneController = TextEditingController();

    String selectedGender = 'Male';
    String selectedCategory = 'Junior';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        final isDark = Theme.of(bottomSheetContext).brightness == Brightness.dark;
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom,
          ),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.88,
            ),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              border: Border.all(color: isDark ? AppColors.glassBorderDark : AppColors.glassBorderLight),
            ),
            padding: const EdgeInsets.all(24.0),
            child: StatefulBuilder(
              builder: (context, setState) {
                return Column(
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
                            color: AppColors.primary.withAlpha(25),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.person_add_alt_1_rounded, color: AppColors.primary, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Register New Participant',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: isDark ? AppColors.textLight : AppColors.textDark,
                                ),
                              ),
                              Text(
                                'Auto Generated ID: $nextId',
                                style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.of(bottomSheetContext).pop(),
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
                            // Participant ID (Read-only Badge)
                            Text('Participant ID', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 12, color: isDark ? AppColors.subtextLight : AppColors.subtextDark)),
                            const SizedBox(height: 4),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withAlpha(15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.primary.withAlpha(60)),
                              ),
                              child: Text(
                                nextId,
                                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primary),
                              ),
                            ),
                            const SizedBox(height: 14),

                            // Student Name
                            Text('Student Name', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13, color: isDark ? AppColors.textLight : AppColors.textDark)),
                            const SizedBox(height: 6),
                            TextField(
                              controller: nameController,
                              decoration: const InputDecoration(
                                hintText: 'e.g. Ahammed Fayiz',
                                prefixIcon: Icon(Icons.person_outline_rounded, size: 20),
                              ),
                            ),
                            const SizedBox(height: 14),

                            // Class & Division in a Row
                            Row(
                              children: [
                                Expanded(
                                  flex: 6,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Student Class', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13, color: isDark ? AppColors.textLight : AppColors.textDark)),
                                      const SizedBox(height: 6),
                                      TextField(
                                        controller: classController,
                                        decoration: const InputDecoration(
                                          hintText: 'e.g. Class 5',
                                          prefixIcon: Icon(Icons.school_outlined, size: 20),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  flex: 4,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Division', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13, color: isDark ? AppColors.textLight : AppColors.textDark)),
                                      const SizedBox(height: 6),
                                      TextField(
                                        controller: divisionController,
                                        decoration: const InputDecoration(
                                          hintText: 'Default A',
                                          prefixIcon: Icon(Icons.grid_3x3_rounded, size: 20),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // Gender Selection Choice Chips
                            Text('Gender', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13, color: isDark ? AppColors.textLight : AppColors.textDark)),
                            const SizedBox(height: 6),
                            Row(
                              children: ['Male', 'Female'].map((g) {
                                final isSelected = selectedGender == g;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 12.0),
                                  child: ChoiceChip(
                                    label: Text(g, style: GoogleFonts.poppins(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                                    selected: isSelected,
                                    onSelected: (val) {
                                      if (val) setState(() => selectedGender = g);
                                    },
                                    selectedColor: AppColors.primary,
                                    labelStyle: TextStyle(color: isSelected ? Colors.white : (isDark ? AppColors.textLight : AppColors.textDark)),
                                    backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 14),

                            // Competition Category Dropdown
                            Text('Category', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13, color: isDark ? AppColors.textLight : AppColors.textDark)),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<String>(
                              initialValue: selectedCategory,
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.category_outlined, size: 20),
                              ),
                              items: const [
                                DropdownMenuItem(value: 'Primary', child: Text('Primary')),
                                DropdownMenuItem(value: 'Sub-Junior', child: Text('Sub-Junior')),
                                DropdownMenuItem(value: 'Junior', child: Text('Junior')),
                                DropdownMenuItem(value: 'Senior', child: Text('Senior')),
                                DropdownMenuItem(value: 'Super Senior', child: Text('Super Senior')),
                                DropdownMenuItem(value: 'Alumni', child: Text('Alumni')),
                              ],
                              onChanged: (val) {
                                if (val != null) setState(() => selectedCategory = val);
                              },
                            ),
                            const SizedBox(height: 14),

                            // Parent Name
                            Text('Parent Name', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13, color: isDark ? AppColors.textLight : AppColors.textDark)),
                            const SizedBox(height: 6),
                            TextField(
                              controller: parentNameController,
                              decoration: const InputDecoration(
                                hintText: 'e.g. Usman Musliyar',
                                prefixIcon: Icon(Icons.family_restroom_rounded, size: 20),
                              ),
                            ),
                            const SizedBox(height: 14),

                            // Phone Number
                            Text('Phone Number', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13, color: isDark ? AppColors.textLight : AppColors.textDark)),
                            const SizedBox(height: 6),
                            TextField(
                              controller: phoneController,
                              keyboardType: TextInputType.phone,
                              decoration: const InputDecoration(
                                hintText: 'e.g. 9876543210',
                                prefixIcon: Icon(Icons.phone_outlined, size: 20),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (nameController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please enter Student Name'), backgroundColor: AppColors.error),
                            );
                            return;
                          }

                          final nowStr = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());

                          final newParticipant = ParticipantModel(
                            participantId: nextId,
                            name: nameController.text.trim(),
                            studentClass: classController.text.trim(),
                            gender: selectedGender,
                            division: divisionController.text.trim().isNotEmpty ? divisionController.text.trim() : 'A',
                            category: selectedCategory,
                            parentName: parentNameController.text.trim(),
                            phoneNo: phoneController.text.trim(),
                            madrasaId: appState.madrasaId,
                            createdAt: nowStr,
                          );

                          final messenger = ScaffoldMessenger.of(context);
                          final nav = Navigator.of(bottomSheetContext);

                          await appState.addParticipantToFirestore(newParticipant);

                          nav.pop();
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text('Participant ${newParticipant.name} (${newParticipant.participantId}) added to Firestore!'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text('Save'),  
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _resetFilters() {
    setState(() {
      _searchQuery = '';
      _selectedCategoryFilter = 'All';
      _selectedClassFilter = 'All';
      _selectedGenderFilter = 'All';
      _selectedTeamFilter = 'All';
      _selectedMedalFilter = 'All';
      _selectedParticipationFilter = 'All';
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDark = appState.isDarkMode;

    final realParticipants = appState.realParticipants;

    // Filter Logic for Class, Category, Gender, Team, Medals, and Participation
    final filteredParticipants = realParticipants.where((p) {
      final q = _searchQuery.trim().toLowerCase();

      final matchesSearch = q.isEmpty ||
          p.name.toLowerCase().contains(q) ||
          p.participantId.toLowerCase().contains(q) ||
          p.category.toLowerCase().contains(q) ||
          p.studentClass.toLowerCase().contains(q) ||
          p.parentName.toLowerCase().contains(q) ||
          p.phoneNo.contains(q);

      if (!matchesSearch) return false;

      if (_selectedCategoryFilter != 'All' &&
          p.category.toLowerCase() != _selectedCategoryFilter.toLowerCase()) {
        return false;
      }

      if (_selectedClassFilter != 'All' &&
          p.studentClass.toLowerCase() != _selectedClassFilter.toLowerCase()) {
        return false;
      }

      if (_selectedGenderFilter != 'All' &&
          p.gender.toLowerCase() != _selectedGenderFilter.toLowerCase()) {
        return false;
      }

      // 4. Team / House Filter
      if (_selectedTeamFilter != 'All') {
        final matchedTeams = appState.teamRecords.where((t) => t.members.any((m) => m.participantId == p.participantId)).toList();
        if (_selectedTeamFilter == 'Unassigned') {
          if (matchedTeams.isNotEmpty) return false;
        } else {
          if (matchedTeams.isEmpty || (matchedTeams.first.teamId != _selectedTeamFilter && matchedTeams.first.teamName != _selectedTeamFilter)) {
            return false;
          }
        }
      }

      // 5. Medal Winners Filter
      if (_selectedMedalFilter != 'All') {
        int gold = 0, silver = 0, bronze = 0;
        for (var se in appState.sideEventRecords) {
          final matches = se.participants.where((sp) => sp.participantId == p.participantId).toList();
          if (matches.isNotEmpty && matches.first.point > 0) {
            if (matches.first.rank == 1) gold++;
            if (matches.first.rank == 2) silver++;
            if (matches.first.rank == 3) bronze++;
          }
        }
        if (_selectedMedalFilter == 'Gold' && gold == 0) return false;
        if (_selectedMedalFilter == 'Silver' && silver == 0) return false;
        if (_selectedMedalFilter == 'Bronze' && bronze == 0) return false;
        if (_selectedMedalFilter == 'Winners' && (gold + silver + bronze) == 0) return false;
      }

      // 6. Participation Filter
      if (_selectedParticipationFilter != 'All') {
        bool inSideEvent = appState.sideEventRecords.any((se) => se.participants.any((sp) => sp.participantId == p.participantId));
        bool inStageProg = appState.realPrograms.any((prog) => prog.participantId == p.participantId || prog.participantName.toLowerCase() == p.name.toLowerCase());

        if (_selectedParticipationFilter == 'SideEvents' && !inSideEvent) return false;
        if (_selectedParticipationFilter == 'StagePrograms' && !inStageProg) return false;
        if (_selectedParticipationFilter == 'NoEvents' && (inSideEvent || inStageProg)) return false;
      }

      return true;
    }).toList();

    final hasActiveFilters = _searchQuery.isNotEmpty ||
        _selectedCategoryFilter != 'All' ||
        _selectedClassFilter != 'All' ||
        _selectedGenderFilter != 'All' ||
        _selectedTeamFilter != 'All' ||
        _selectedMedalFilter != 'All' ||
        _selectedParticipationFilter != 'All';

    final classOptions = ['All', 'Class 1', 'Class 2', 'Class 3', 'Class 4', 'Class 5', 'Class 6', 'Class 7', 'Class 8', 'Class 9', 'Class 10','Class 11','Class 12'];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.all(Responsive.getPadding(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Title & Action Bar
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 20,
              runSpacing: 14,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Participant Directory',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.textLight : AppColors.textDark,
                      ),
                    ),
                    Text(
                      'Manage registered student competitors synced with Cloud Firestore.',
                      style: GoogleFonts.poppins(fontSize: 13, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
                    ),
                  ],
                ),

                Wrap(
                  spacing: 12,
                  runSpacing: 10,
                  children: [
                    // Search Box
                    Container(
                      width: 280,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                      ),
                      child: TextField(
                        onChanged: (val) => setState(() => _searchQuery = val),
                        decoration: InputDecoration(
                          hintText: 'Search participant, ID, class, parent...',
                          hintStyle: GoogleFonts.poppins(fontSize: 12, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
                          prefixIcon: const Icon(Icons.search_rounded, size: 20),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded, size: 18),
                                  onPressed: () => setState(() => _searchQuery = ''),
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),

                    ElevatedButton.icon(
                      onPressed: () => _showAddParticipantBottomSheet(context, appState),
                      icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
                      label: const Text('Add Participant'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Comprehensive Filter Toolbar Card (Category, Class, Gender)
            GlassCard(
              borderRadius: 22,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.filter_alt_rounded, size: 20, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text(
                            'Directory Filters',
                            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? AppColors.textLight : AppColors.textDark),
                          ),
                        ],
                      ),
                      if (hasActiveFilters)
                        TextButton.icon(
                          onPressed: _resetFilters,
                          icon: const Icon(Icons.refresh_rounded, size: 16, color: AppColors.error),
                          label: Text('Reset Filters', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.error)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 16,
                    runSpacing: 14,
                    children: [
                      // 1. Category Filter Choice Chips
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Category:', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: isDark ? AppColors.subtextLight : AppColors.subtextDark)),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 6,
                            children: ['All', 'Primary', 'Sub-Junior', 'Junior', 'Senior', 'Super Senior' , 'Alumni'].map((cat) {
                              final isSel = _selectedCategoryFilter == cat;
                              return ChoiceChip(
                                label: Text(cat, style: GoogleFonts.poppins(fontSize: 11, fontWeight: isSel ? FontWeight.bold : FontWeight.normal)),
                                selected: isSel,
                                onSelected: (val) {
                                  if (val) setState(() => _selectedCategoryFilter = cat);
                                },
                                selectedColor: AppColors.primary,
                                labelStyle: TextStyle(color: isSel ? Colors.white : (isDark ? AppColors.textLight : AppColors.textDark)),
                                backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              );
                            }).toList(),
                          ),
                        ],
                      ),

                      // 2. Gender Filter Choice Chips
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Gender:', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: isDark ? AppColors.subtextLight : AppColors.subtextDark)),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 6,
                            children: ['All', 'Male', 'Female'].map((gen) {
                              final isSel = _selectedGenderFilter == gen;
                              return ChoiceChip(
                                label: Text(
                                  gen == 'All' ? 'All Genders' : gen,
                                  style: GoogleFonts.poppins(fontSize: 11, fontWeight: isSel ? FontWeight.bold : FontWeight.normal),
                                ),
                                selected: isSel,
                                onSelected: (val) {
                                  if (val) setState(() => _selectedGenderFilter = gen);
                                },
                                selectedColor: AppColors.secondary,
                                labelStyle: TextStyle(color: isSel ? Colors.white : (isDark ? AppColors.textLight : AppColors.textDark)),
                                backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              );
                            }).toList(),
                          ),
                        ],
                      ),

                      // 3. Class Wise Dropdown Filter
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Class Wise:', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: isDark ? AppColors.subtextLight : AppColors.subtextDark)),
                          const SizedBox(height: 4),
                          Container(
                            height: 38,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: classOptions.contains(_selectedClassFilter) ? _selectedClassFilter : 'All',
                                style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                                dropdownColor: isDark ? AppColors.cardDark : Colors.white,
                                items: classOptions.map((c) {
                                  return DropdownMenuItem(
                                    value: c,
                                    child: Text(c == 'All' ? 'All Classes' : c),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) setState(() => _selectedClassFilter = val);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),

                      // 4. Team / House Dropdown Filter
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('House Team:', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: isDark ? AppColors.subtextLight : AppColors.subtextDark)),
                          const SizedBox(height: 4),
                          Container(
                            height: 38,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedTeamFilter,
                                style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                                dropdownColor: isDark ? AppColors.cardDark : Colors.white,
                                items: [
                                  const DropdownMenuItem(value: 'All', child: Text('All Teams')),
                                  const DropdownMenuItem(value: 'Unassigned', child: Text('Unassigned Team')),
                                  ...appState.teamRecords.map((t) {
                                    return DropdownMenuItem(
                                      value: t.teamId,
                                      child: Text(t.teamName),
                                    );
                                  }),
                                ],
                                onChanged: (val) {
                                  if (val != null) setState(() => _selectedTeamFilter = val);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),

                      // 5. Medal Winners Dropdown Filter
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Medals & Winners:', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: isDark ? AppColors.subtextLight : AppColors.subtextDark)),
                          const SizedBox(height: 4),
                          Container(
                            height: 38,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedMedalFilter,
                                style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                                dropdownColor: isDark ? AppColors.cardDark : Colors.white,
                                items: const [
                                  DropdownMenuItem(value: 'All', child: Text('All Students')),
                                  DropdownMenuItem(value: 'Gold', child: Text('🥇 1st Rank (Gold)')),
                                  DropdownMenuItem(value: 'Silver', child: Text('🥈 2nd Rank (Silver)')),
                                  DropdownMenuItem(value: 'Bronze', child: Text('🥉 3rd Rank (Bronze)')),
                                  DropdownMenuItem(value: 'Winners', child: Text('🏆 Any Medal Winner')),
                                ],
                                onChanged: (val) {
                                  if (val != null) setState(() => _selectedMedalFilter = val);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),

                      // 6. Event Participation Status Filter
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Participation:', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: isDark ? AppColors.subtextLight : AppColors.subtextDark)),
                          const SizedBox(height: 4),
                          Container(
                            height: 38,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedParticipationFilter,
                                style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                                dropdownColor: isDark ? AppColors.cardDark : Colors.white,
                                items: const [
                                  DropdownMenuItem(value: 'All', child: Text('All Participants')),
                                  DropdownMenuItem(value: 'SideEvents', child: Text('Registered in Side Events')),
                                  DropdownMenuItem(value: 'StagePrograms', child: Text('Registered in Stage Programs')),
                                  DropdownMenuItem(value: 'NoEvents', child: Text('No Events Registered')),
                                ],
                                onChanged: (val) {
                                  if (val != null) setState(() => _selectedParticipationFilter = val);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Registered Participants Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Cloud Participants (${filteredParticipants.length})',
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? AppColors.textLight : AppColors.textDark),
                ),
                Text(
                  'Synced with Firestore',
                  style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Participant Grid or Empty State Card
            if (filteredParticipants.isEmpty)
              GlassCard(
                borderRadius: 24,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(48.0),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withAlpha(20),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.person_search_rounded, size: 48, color: AppColors.primary),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No Participants Found',
                          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? AppColors.textLight : AppColors.textDark),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          hasActiveFilters
                              ? 'No participants match the selected filter criteria. Try resetting filters.'
                              : 'No registered participants in Cloud Firestore. Click "Add Participant" to register.',
                          style: GoogleFonts.poppins(fontSize: 12, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
                          textAlign: TextAlign.center,
                        ),
                        if (hasActiveFilters) ...[
                          const SizedBox(height: 16),
                          OutlinedButton.icon(
                            onPressed: _resetFilters,
                            icon: const Icon(Icons.refresh_rounded, size: 16),
                            label: const Text('Reset All Filters'),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 400,
                  mainAxisSpacing: 18,
                  crossAxisSpacing: 18,
                  mainAxisExtent: 245,
                ),
                itemCount: filteredParticipants.length,
                itemBuilder: (context, idx) {
                  final p = filteredParticipants[idx];

                  // Find Student Team Info & House Color
                  TeamModel? studentTeam;
                  Color houseColor = AppColors.primary;
                  String teamName = 'Unassigned';

                  final matchedTeams = appState.teamRecords.where((t) => t.members.any((m) => m.participantId == p.participantId)).toList();
                  if (matchedTeams.isNotEmpty) {
                    studentTeam = matchedTeams.first;
                    teamName = studentTeam.teamName;
                    try {
                      houseColor = Color(int.parse(studentTeam.houseColor));
                    } catch (_) {}
                  }

                  // Find Student Points & Earned Medal Counts
                  int totalPoints = 0;
                  int goldCount = 0;
                  int silverCount = 0;
                  int bronzeCount = 0;

                  for (var se in appState.sideEventRecords) {
                    final matches = se.participants.where((sp) => sp.participantId == p.participantId).toList();
                    if (matches.isNotEmpty) {
                      final sp = matches.first;
                      totalPoints += sp.point;
                      if (sp.rank == 1 && sp.point > 0) goldCount++;
                      if (sp.rank == 2 && sp.point > 0) silverCount++;
                      if (sp.rank == 3 && sp.point > 0) bronzeCount++;
                    }
                  }

                  return GlassCard(
                    borderRadius: 20,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. Top Badges Row (Chest Card Badge & Team House Color Badge)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Chest Number Card Badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.badge_rounded, size: 12, color: Colors.white),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Chest #${p.participantId}',
                                    style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                            // Team Name Badge with House Color
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: houseColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                teamName,
                                style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // 2. Main Student Details Row
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: houseColor.withAlpha(30),
                              child: Text(
                                p.name.isNotEmpty ? p.name[0].toUpperCase() : 'P',
                                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: houseColor),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p.name,
                                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13.5, color: isDark ? AppColors.textLight : AppColors.textDark),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    '${p.studentClass} (${p.division}) • ${p.category}',
                                    style: GoogleFonts.poppins(fontSize: 10.5, fontWeight: FontWeight.w600, color: AppColors.secondary),
                                  ),
                                  Text(
                                    'Parent: ${p.parentName.isNotEmpty ? p.parentName : "N/A"}',
                                    style: GoogleFonts.poppins(fontSize: 10, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // 3. Performance Summary Bar (Total Points & Medal Counters)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.emoji_events_rounded, size: 14, color: AppColors.warning),
                                  const SizedBox(width: 4),
                                  Text(
                                    '$totalPoints Pts',
                                    style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text('🥇 $goldCount', style: GoogleFonts.poppins(fontSize: 10.5, fontWeight: FontWeight.bold)),
                                  const SizedBox(width: 8),
                                  Text('🥈 $silverCount', style: GoogleFonts.poppins(fontSize: 10.5, fontWeight: FontWeight.bold)),
                                  const SizedBox(width: 8),
                                  Text('🥉 $bronzeCount', style: GoogleFonts.poppins(fontSize: 10.5, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const Spacer(),

                        // 4. View Programs & Events Action Button (Replaces WhatsApp button)
                        SizedBox(
                          width: double.infinity,
                          height: 36,
                          child: ElevatedButton.icon(
                            onPressed: () => _openStudentProgramsSheet(context, p, appState),
                            icon: const Icon(Icons.event_note_rounded, size: 15),
                            label: Text('View Programs & Events', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: EdgeInsets.zero,
                            ),
                          ),
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
}
