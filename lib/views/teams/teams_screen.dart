import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/providers/app_state.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/glass_card.dart';

class TeamItem {
  final String id;
  final String name;
  final String motto;
  final Color color;
  final String captain;
  final String viceCaptain;
  final int memberCount;
  int points;
  int goldCount;
  int silverCount;
  int bronzeCount;
  final List<Map<String, String>> members;

  TeamItem({
    required this.id,
    required this.name,
    required this.motto,
    required this.color,
    required this.captain,
    required this.viceCaptain,
    required this.memberCount,
    required this.points,
    required this.goldCount,
    required this.silverCount,
    required this.bronzeCount,
    required this.members,
  });
}

class TeamsScreen extends StatefulWidget {
  const TeamsScreen({super.key});

  @override
  State<TeamsScreen> createState() => _TeamsScreenState();
}

class _TeamsScreenState extends State<TeamsScreen> {
  String _searchQuery = '';

  final List<TeamItem> _teams = [
    TeamItem(
      id: 'T1',
      name: 'Al-Fath (Red House)',
      motto: 'Victory & Honor',
      color: const Color(0xFFEF4444),
      captain: 'Muhammed Sinan (Class 10)',
      viceCaptain: 'Ahmad Raihan (Class 9)',
      memberCount: 32,
      points: 485,
      goldCount: 8,
      silverCount: 5,
      bronzeCount: 4,
      members: [
        {'id': 'P101', 'name': 'Muhammed Sinan', 'class': 'Class 10', 'category': 'Super Senior', 'points': '45'},
        {'id': 'P102', 'name': 'Ahmad Raihan', 'class': 'Class 9', 'category': 'Senior', 'points': '38'},
        {'id': 'P103', 'name': 'Fadil Rahman', 'class': 'Class 7', 'category': 'Junior', 'points': '25'},
        {'id': 'P104', 'name': 'Ayan Muhammed', 'class': 'Class 5', 'category': 'Sub-Junior', 'points': '18'},
      ],
    ),
    TeamItem(
      id: 'T2',
      name: 'Badr (Green House)',
      motto: 'Courage & Knowledge',
      color: const Color(0xFF10B981),
      captain: 'Bilal Hassan (Class 10)',
      viceCaptain: 'Zayd Muhammed (Class 9)',
      memberCount: 30,
      points: 440,
      goldCount: 6,
      silverCount: 7,
      bronzeCount: 3,
      members: [
        {'id': 'P201', 'name': 'Bilal Hassan', 'class': 'Class 10', 'category': 'Super Senior', 'points': '40'},
        {'id': 'P202', 'name': 'Zayd Muhammed', 'class': 'Class 9', 'category': 'Senior', 'points': '32'},
        {'id': 'P203', 'name': 'Ameen Farhan', 'class': 'Class 6', 'category': 'Junior', 'points': '22'},
      ],
    ),
    TeamItem(
      id: 'T3',
      name: 'Uhud (Blue House)',
      motto: 'Steadfastness & Perseverance',
      color: const Color(0xFF3B82F6),
      captain: 'Hamza Ibrahim (Class 10)',
      viceCaptain: 'Omar Mukhtar (Class 9)',
      memberCount: 28,
      points: 395,
      goldCount: 5,
      silverCount: 4,
      bronzeCount: 6,
      members: [
        {'id': 'P301', 'name': 'Hamza Ibrahim', 'class': 'Class 10', 'category': 'Super Senior', 'points': '35'},
        {'id': 'P302', 'name': 'Omar Mukhtar', 'class': 'Class 9', 'category': 'Senior', 'points': '30'},
      ],
    ),
    TeamItem(
      id: 'T4',
      name: 'Yarmouk (Gold House)',
      motto: 'Excellence & Discipline',
      color: const Color(0xFFF59E0B),
      captain: 'Khalid Waleed (Class 10)',
      viceCaptain: 'Tariq Ziyad (Class 9)',
      memberCount: 29,
      points: 360,
      goldCount: 4,
      silverCount: 5,
      bronzeCount: 5,
      members: [
        {'id': 'P401', 'name': 'Khalid Waleed', 'class': 'Class 10', 'category': 'Super Senior', 'points': '30'},
        {'id': 'P402', 'name': 'Tariq Ziyad', 'class': 'Class 9', 'category': 'Senior', 'points': '28'},
      ],
    ),
  ];

  void _openAddTeamModal() {
    final nameCtrl = TextEditingController();
    final mottoCtrl = TextEditingController();
    final captainCtrl = TextEditingController();
    final viceCaptainCtrl = TextEditingController();
    Color selectedColor = AppColors.primary;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          final isDark = Provider.of<AppState>(context).isDarkMode;
          return AlertDialog(
            backgroundColor: isDark ? AppColors.cardDark : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(25),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.groups_rounded, color: AppColors.primary, size: 22),
                ),
                const SizedBox(width: 12),
                Text('Create New Team / House', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            content: SizedBox(
              width: 440,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameCtrl,
                      decoration: InputDecoration(
                        labelText: 'Team / House Name',
                        hintText: 'e.g. Al-Quds (Purple House)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: mottoCtrl,
                      decoration: InputDecoration(
                        labelText: 'Motto / Slogan',
                        hintText: 'e.g. Leadership & Unity',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: captainCtrl,
                      decoration: InputDecoration(
                        labelText: 'Team Captain',
                        hintText: 'Captain Name & Class',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: viceCaptainCtrl,
                      decoration: InputDecoration(
                        labelText: 'Vice Captain',
                        hintText: 'Vice Captain Name & Class',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Text('House Theme Color:', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
                        const SizedBox(width: 12),
                        Wrap(
                          spacing: 8,
                          children: [
                            const Color(0xFFEF4444),
                            const Color(0xFF10B981),
                            const Color(0xFF3B82F6),
                            const Color(0xFFF59E0B),
                            const Color(0xFF8B5CF6),
                            const Color(0xFFEC4899),
                          ].map((c) => GestureDetector(
                            onTap: () => setModalState(() => selectedColor = c),
                            child: Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                color: c,
                                shape: BoxShape.circle,
                                border: selectedColor == c ? Border.all(color: Colors.white, width: 3) : null,
                                boxShadow: selectedColor == c ? [BoxShadow(color: c.withAlpha(150), blurRadius: 6)] : null,
                              ),
                            ),
                          )).toList(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.grey)),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  if (nameCtrl.text.trim().isNotEmpty) {
                    setState(() {
                      _teams.add(TeamItem(
                        id: 'T${_teams.length + 1}',
                        name: nameCtrl.text.trim(),
                        motto: mottoCtrl.text.trim().isNotEmpty ? mottoCtrl.text.trim() : 'Unity & Excellence',
                        color: selectedColor,
                        captain: captainCtrl.text.trim().isNotEmpty ? captainCtrl.text.trim() : 'Unassigned',
                        viceCaptain: viceCaptainCtrl.text.trim().isNotEmpty ? viceCaptainCtrl.text.trim() : 'Unassigned',
                        memberCount: 0,
                        points: 0,
                        goldCount: 0,
                        silverCount: 0,
                        bronzeCount: 0,
                        members: [],
                      ));
                    });
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('✨ Team "${nameCtrl.text.trim()}" created successfully!'), backgroundColor: AppColors.success),
                    );
                  }
                },
                icon: const Icon(Icons.check_rounded, size: 16),
                label: Text('Create Team', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _openTeamRosterModal(TeamItem team) {
    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Provider.of<AppState>(context).isDarkMode;
        return AlertDialog(
          backgroundColor: isDark ? AppColors.cardDark : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(color: team.color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text('${team.name} Roster', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              Text('${team.points} Points', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14, color: team.color)),
            ],
          ),
          content: SizedBox(
            width: 520,
            height: 380,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Captain: ${team.captain}', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
                    Text('Vice Captain: ${team.viceCaptain}', style: GoogleFonts.poppins(fontSize: 12, color: isDark ? AppColors.subtextLight : AppColors.subtextDark)),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Text('Registered Team Members (${team.members.length}):', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 8),
                Expanded(
                  child: team.members.isEmpty
                      ? Center(child: Text('No members registered in this team yet.', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)))
                      : ListView.separated(
                          itemCount: team.members.length,
                          separatorBuilder: (_, _) => const Divider(height: 1),
                          itemBuilder: (context, idx) {
                            final m = team.members[idx];
                            return ListTile(
                              dense: true,
                              leading: CircleAvatar(
                                radius: 14,
                                backgroundColor: team.color.withAlpha(30),
                                child: Text('${idx + 1}', style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: team.color)),
                              ),
                              title: Text(m['name']!, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12)),
                              subtitle: Text('${m['id']} • ${m['class']} (${m['category']})', style: GoogleFonts.poppins(fontSize: 10)),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: team.color.withAlpha(25),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text('+${m['points']} Pts', style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: team.color)),
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

    final filteredTeams = _teams.where((t) {
      final matchesSearch = _searchQuery.isEmpty ||
          t.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          t.captain.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesSearch;
    }).toList();

    // Sort by points descending for leaderboard rank
    filteredTeams.sort((a, b) => b.points.compareTo(a.points));

    final totalChampionshipPoints = _teams.fold<int>(0, (sum, t) => sum + t.points);
    final topTeam = _teams.reduce((a, b) => a.points > b.points ? a : b);

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
                  onPressed: _openAddTeamModal,
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
                    value: '${_teams.length}',
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
                    value: topTeam.name.split(' ').first,
                    subtitle: '${topTeam.points} Pts (1st Place)',
                    icon: Icons.military_tech_rounded,
                    color: topTeam.color,
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
                    value: _teams.isNotEmpty ? '${(totalChampionshipPoints / _teams.length).round()}' : '0',
                    subtitle: 'Per House Average',
                    icon: Icons.analytics_rounded,
                    color: AppColors.secondary,
                    isDark: isDark,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Search Bar & Filters
            GlassCard(
              padding: const EdgeInsets.all(16),
              borderRadius: 16,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (val) => setState(() => _searchQuery = val),
                      decoration: InputDecoration(
                        hintText: 'Search house name or team captain...',
                        hintStyle: GoogleFonts.poppins(fontSize: 13, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
                        prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColors.primary),
                        border: InputBorder.none,
                      ),
                    ),
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
                childAspectRatio: 1.55,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
              ),
              itemCount: filteredTeams.length,
              itemBuilder: (context, idx) {
                final team = filteredTeams[idx];
                final rank = idx + 1;
                final pct = totalChampionshipPoints > 0 ? (team.points / totalChampionshipPoints * 100) : 0.0;

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
                                  color: team.color.withAlpha(30),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: team.color.withAlpha(100), width: 1.5),
                                ),
                                child: Center(
                                  child: Icon(Icons.shield_rounded, color: team.color, size: 24),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    team.name,
                                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? AppColors.textLight : AppColors.textDark),
                                  ),
                                  Text(
                                    '"${team.motto}"',
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
                              color: rank == 1 ? const Color(0xFFFEF08A) : (rank == 2 ? const Color(0xFFE2E8F0) : (rank == 3 ? const Color(0xFFFFEDD5) : team.color.withAlpha(25))),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: team.color.withAlpha(80)),
                            ),
                            child: Text(
                              rank == 1 ? '🥇 1st Place' : (rank == 2 ? '🥈 2nd Place' : (rank == 3 ? '🥉 3rd Place' : 'Rank #$rank')),
                              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 11, color: rank == 1 ? const Color(0xFF854D0E) : (rank == 2 ? const Color(0xFF334155) : team.color)),
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
                                Text(team.captain, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12)),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Vice Captain:', style: GoogleFonts.poppins(fontSize: 10, color: isDark ? AppColors.subtextLight : AppColors.subtextDark)),
                                Text(team.viceCaptain, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 12)),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('Total Score:', style: GoogleFonts.poppins(fontSize: 10, color: isDark ? AppColors.subtextLight : AppColors.subtextDark)),
                              Text('${team.points} Pts', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15, color: team.color)),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // Medal Tally
                      Row(
                        children: [
                          _buildMedalChip('🥇 ${team.goldCount}', const Color(0xFFEAB308)),
                          const SizedBox(width: 8),
                          _buildMedalChip('🥈 ${team.silverCount}', const Color(0xFF94A3B8)),
                          const SizedBox(width: 8),
                          _buildMedalChip('🥉 ${team.bronzeCount}', const Color(0xFFD97706)),
                          const Spacer(),
                          Text('${pct.toStringAsFixed(1)}% Share', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: team.color)),
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
                          valueColor: AlwaysStoppedAnimation<Color>(team.color),
                        ),
                      ),

                      const Spacer(),

                      // Actions
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _openTeamRosterModal(team),
                              icon: const Icon(Icons.badge_rounded, size: 16),
                              label: Text('View Roster (${team.members.length})', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold)),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: team.color,
                                side: BorderSide(color: team.color.withAlpha(100)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                team.points += 10;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('➕ Added +10 Points to ${team.name}!'), backgroundColor: AppColors.success),
                              );
                            },
                            icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.success, size: 20),
                            tooltip: 'Add Quick +10 Points',
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
