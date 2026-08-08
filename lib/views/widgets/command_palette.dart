// Library: command_palette.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/models/participant_model.dart';
import '../../core/models/program_model.dart';
import '../../core/models/side_event_model.dart';
import '../../core/models/team_model.dart';
import '../../core/providers/app_state.dart';
import '../../core/theme/app_colors.dart';

class CommandPaletteDialog extends StatefulWidget {
  const CommandPaletteDialog({super.key});

  @override
  State<CommandPaletteDialog> createState() => _CommandPaletteDialogState();
}

class _CommandPaletteDialogState extends State<CommandPaletteDialog> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String _activeTab = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDark = appState.isDarkMode;

    final q = _query.trim().toLowerCase();

    // 1. FILTER PARTICIPANTS
    final matchedParticipants = q.isEmpty
        ? <ParticipantModel>[]
        : appState.realParticipants.where((p) {
            return p.name.toLowerCase().contains(q) ||
                p.participantId.toLowerCase().contains(q) ||
                p.category.toLowerCase().contains(q) ||
                p.studentClass.toLowerCase().contains(q) ||
                p.phoneNo.toLowerCase().contains(q);
          }).toList();

    // 2. FILTER PROGRAMS
    final matchedPrograms = q.isEmpty
        ? <ProgramModel>[]
        : appState.realPrograms.where((p) {
            return p.programName.toLowerCase().contains(q) ||
                p.programId.toLowerCase().contains(q) ||
                p.participantName.toLowerCase().contains(q) ||
                p.category.toLowerCase().contains(q) ||
                p.programType.toLowerCase().contains(q) ||
                p.status.toLowerCase().contains(q);
          }).toList();

    // 3. FILTER SIDE EVENTS
    final matchedSideEvents = q.isEmpty
        ? <SideEventModel>[]
        : appState.sideEventRecords.where((se) {
            return se.sideEventName.toLowerCase().contains(q) ||
                se.sideEventId.toLowerCase().contains(q) ||
                se.participantsCategory.toLowerCase().contains(q) ||
                se.sideEventStatus.toLowerCase().contains(q);
          }).toList();

    // 4. FILTER TEAMS
    final matchedTeams = q.isEmpty
        ? <TeamModel>[]
        : appState.teamRecords.where((t) {
            return t.teamName.toLowerCase().contains(q) ||
                t.houseColor.toLowerCase().contains(q) ||
                t.overallPoint.toString().contains(q);
          }).toList();

    // 5. FILTER NAVIGATION COMMANDS
    final commands = [
      {'icon': Icons.home_rounded, 'title': 'Go to Dashboard', 'action': () => appState.setTabIndex(0)},
      {'icon': Icons.assignment_ind_rounded, 'title': 'View Participants Directory', 'action': () => appState.setTabIndex(1)},
      {'icon': Icons.mic_rounded, 'title': 'View All Programs List', 'action': () => appState.setTabIndex(2)},
      {'icon': Icons.groups_rounded, 'title': 'Teams & House Roster', 'action': () => appState.setTabIndex(3)},
      {'icon': Icons.account_balance_rounded, 'title': 'Side Events & Exhibitions', 'action': () => appState.setTabIndex(4)},
      {'icon': Icons.calendar_month_rounded, 'title': 'Auto-Generate Schedule Rules', 'action': () => appState.setTabIndex(5)},
      {'icon': Icons.star_rounded, 'title': 'Mark Coordination Scores', 'action': () => appState.setTabIndex(6)},
      {'icon': Icons.check_circle_rounded, 'title': 'Hajar / Present Coordination', 'action': () => appState.setTabIndex(7)},
      {'icon': Icons.live_tv_rounded, 'title': 'Open Live Stage LED Display', 'action': () => appState.setTabIndex(8)},
      {'icon': Icons.emoji_events_rounded, 'title': 'Championship Scoreboard', 'action': () => appState.setTabIndex(9)},
      {'icon': Icons.bar_chart_rounded, 'title': 'Reports & Analytics', 'action': () => appState.setTabIndex(10)},
      {'icon': Icons.person_rounded, 'title': 'Profile / System Settings', 'action': () => appState.setTabIndex(11)},
      {
        'icon': isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
        'title': 'Toggle Dark / Light Theme',
        'action': () => appState.toggleTheme()
      },
    ];

    final matchedCommands = commands.where((c) {
      final title = (c['title'] as String).toLowerCase();
      return title.contains(q);
    }).toList();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 720),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? AppColors.glassBorderDark : AppColors.glassBorderLight,
            width: 1.5,
          ),
          boxShadow: const [
            BoxShadow(color: Colors.black38, blurRadius: 32, offset: Offset(0, 12)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Input Header Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  const Icon(Icons.search_rounded, color: AppColors.primary, size: 26),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.textLight : AppColors.textDark,
                      ),
                      onChanged: (val) => setState(() => _query = val),
                      decoration: InputDecoration(
                        hintText: 'Search participants, programs, side events, teams...',
                        hintStyle: GoogleFonts.poppins(
                          fontSize: 14.5,
                          color: isDark ? AppColors.subtextLight : AppColors.subtextDark,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  if (_query.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                      tooltip: 'Clear search',
                    ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white10 : Colors.black12,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'ESC',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.subtextLight : AppColors.subtextDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Category Filter Chips Bar (When searching)
            if (q.isNotEmpty) ...[
              const Divider(height: 1),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    _buildTabChip('All', _activeTab == 'All', () => setState(() => _activeTab = 'All')),
                    _buildTabChip('Participants (${matchedParticipants.length})', _activeTab == 'Participants', () => setState(() => _activeTab = 'Participants')),
                    _buildTabChip('Programs (${matchedPrograms.length})', _activeTab == 'Programs', () => setState(() => _activeTab = 'Programs')),
                    _buildTabChip('Side Events (${matchedSideEvents.length})', _activeTab == 'Side Events', () => setState(() => _activeTab = 'Side Events')),
                    _buildTabChip('Teams (${matchedTeams.length})', _activeTab == 'Teams', () => setState(() => _activeTab = 'Teams')),
                    _buildTabChip('Commands (${matchedCommands.length})', _activeTab == 'Commands', () => setState(() => _activeTab = 'Commands')),
                  ],
                ),
              ),
            ],

            const Divider(height: 1),

            // Search Results Body Container
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 420),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- 1. DEFAULT COMMANDS WHEN NO QUERY IS TYPED ---
                    if (q.isEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        child: Text(
                          'SYSTEM QUICK COMMANDS',
                          style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary, letterSpacing: 0.5),
                        ),
                      ),
                      ...commands.map((cmd) => ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withAlpha(25),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(cmd['icon'] as IconData, color: AppColors.primary, size: 20),
                            ),
                            title: Text(
                              cmd['title'] as String,
                              style: GoogleFonts.poppins(fontSize: 13.5, fontWeight: FontWeight.w600, color: isDark ? AppColors.textLight : AppColors.textDark),
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.subtextDark),
                            onTap: () {
                              Navigator.pop(context);
                              (cmd['action'] as VoidCallback)();
                            },
                          )),
                    ] else ...[
                      // --- 2. PARTICIPANTS SECTION ---
                      if ((_activeTab == 'All' || _activeTab == 'Participants') && matchedParticipants.isNotEmpty) ...[
                        _buildSectionHeader('PARTICIPANTS (${matchedParticipants.length})', Icons.assignment_ind_rounded, isDark),
                        ...matchedParticipants.map((p) => ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                              leading: CircleAvatar(
                                radius: 18,
                                backgroundColor: AppColors.primary,
                                child: Text(
                                  p.name.isNotEmpty ? p.name[0].toUpperCase() : 'S',
                                  style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              ),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      p.name,
                                      style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? AppColors.textLight : AppColors.textDark),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(color: AppColors.primary.withAlpha(30), borderRadius: BorderRadius.circular(6)),
                                    child: Text('ID #${p.participantId}', style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary)),
                                  ),
                                ],
                              ),
                              subtitle: Text(
                                'Category: ${p.category} • Class: ${p.studentClass} ${p.division}',
                                style: GoogleFonts.poppins(fontSize: 11, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.subtextDark),
                              onTap: () {
                                appState.setTabIndex(1); // Go to Participants
                                Navigator.pop(context);
                              },
                            )),
                      ],

                      // --- 3. PROGRAMS SECTION ---
                      if ((_activeTab == 'All' || _activeTab == 'Programs') && matchedPrograms.isNotEmpty) ...[
                        _buildSectionHeader('PROGRAMS (${matchedPrograms.length})', Icons.mic_rounded, isDark),
                        ...matchedPrograms.map((prog) => ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(color: const Color(0xFF10B981).withAlpha(25), borderRadius: BorderRadius.circular(10)),
                                child: const Icon(Icons.mic_rounded, color: Color(0xFF10B981), size: 20),
                              ),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      prog.programName,
                                      style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? AppColors.textLight : AppColors.textDark),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(color: const Color(0xFF10B981).withAlpha(30), borderRadius: BorderRadius.circular(6)),
                                    child: Text(prog.programId, style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF10B981))),
                                  ),
                                ],
                              ),
                              subtitle: Text(
                                'Category: ${prog.category} • Type: ${prog.programType} • Status: ${prog.status.toUpperCase()}',
                                style: GoogleFonts.poppins(fontSize: 11, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.subtextDark),
                              onTap: () {
                                appState.setTabIndex(2); // Go to Programs List
                                Navigator.pop(context);
                              },
                            )),
                      ],

                      // --- 4. SIDE EVENTS SECTION ---
                      if ((_activeTab == 'All' || _activeTab == 'Side Events') && matchedSideEvents.isNotEmpty) ...[
                        _buildSectionHeader('SIDE EVENTS (${matchedSideEvents.length})', Icons.account_balance_rounded, isDark),
                        ...matchedSideEvents.map((se) => ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(color: const Color(0xFFF59E0B).withAlpha(25), borderRadius: BorderRadius.circular(10)),
                                child: const Icon(Icons.emoji_events_rounded, color: Color(0xFFF59E0B), size: 20),
                              ),
                              title: Text(
                                se.sideEventName,
                                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? AppColors.textLight : AppColors.textDark),
                              ),
                              subtitle: Text(
                                'Category: ${se.participantsCategory} • Time: ${se.scheduledTime} • Status: ${se.sideEventStatus}',
                                style: GoogleFonts.poppins(fontSize: 11, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.subtextDark),
                              onTap: () {
                                appState.setTabIndex(4); // Go to Side Events
                                Navigator.pop(context);
                              },
                            )),
                      ],

                      // --- 5. TEAMS SECTION ---
                      if ((_activeTab == 'All' || _activeTab == 'Teams') && matchedTeams.isNotEmpty) ...[
                        _buildSectionHeader('TEAMS (${matchedTeams.length})', Icons.groups_rounded, isDark),
                        ...matchedTeams.map((t) {
                          Color houseColor = AppColors.primary;
                          try {
                            houseColor = Color(int.parse(t.houseColor));
                          } catch (_) {}

                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                            leading: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(color: houseColor, shape: BoxShape.circle),
                              alignment: Alignment.center,
                              child: Text(
                                t.teamName.isNotEmpty ? t.teamName[0].toUpperCase() : 'T',
                                style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ),
                            title: Text(
                              t.teamName,
                              style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? AppColors.textLight : AppColors.textDark),
                            ),
                            subtitle: Text(
                              'Overall Points Tally: ${t.overallPoint} Pts • Members: ${t.members.length}',
                              style: GoogleFonts.poppins(fontSize: 11, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.subtextDark),
                            onTap: () {
                              appState.setTabIndex(3); // Go to Teams
                              Navigator.pop(context);
                            },
                          );
                        }),
                      ],

                      // --- 6. COMMANDS SECTION ---
                      if ((_activeTab == 'All' || _activeTab == 'Commands') && matchedCommands.isNotEmpty) ...[
                        _buildSectionHeader('NAVIGATION COMMANDS (${matchedCommands.length})', Icons.explore_rounded, isDark),
                        ...matchedCommands.map((cmd) => ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(color: AppColors.primary.withAlpha(25), borderRadius: BorderRadius.circular(10)),
                                child: Icon(cmd['icon'] as IconData, color: AppColors.primary, size: 20),
                              ),
                              title: Text(
                                cmd['title'] as String,
                                style: GoogleFonts.poppins(fontSize: 13.5, fontWeight: FontWeight.w600, color: isDark ? AppColors.textLight : AppColors.textDark),
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.subtextDark),
                              onTap: () {
                                Navigator.pop(context);
                                (cmd['action'] as VoidCallback)();
                              },
                            )),
                      ],

                      // --- EMPTY STATE ---
                      if (matchedParticipants.isEmpty &&
                          matchedPrograms.isEmpty &&
                          matchedSideEvents.isEmpty &&
                          matchedTeams.isEmpty &&
                          matchedCommands.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                          child: Center(
                            child: Column(
                              children: [
                                const Icon(Icons.search_off_rounded, size: 48, color: Colors.grey),
                                const SizedBox(height: 12),
                                Text(
                                  'No matching results found for "$_query"',
                                  style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Try searching for student names, program titles, side events, or teams.',
                                  style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabChip(String label, bool isSelected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(label, style: GoogleFonts.poppins(fontSize: 11.5, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500)),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.primary,
        labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.subtextDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 14, bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            title,
            style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary, letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }
}
