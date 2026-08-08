// Library: scoreboard_screen.dart  
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/models/team_model.dart';
import '../../core/providers/app_state.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/glass_card.dart';
import '../../core/utils/responsive.dart';
import 'scoreboard_pdf_service.dart';

class ScoreboardScreen extends StatefulWidget {
  const ScoreboardScreen({super.key});

  @override
  State<ScoreboardScreen> createState() => _ScoreboardScreenState();
}

class _ScoreboardScreenState extends State<ScoreboardScreen> {
  String _selectedCategoryScope = 'Overall Championship';

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDark = appState.isDarkMode;

    final realTeams = appState.teamRecords;

    // 1. Calculate Dynamic Team Standings based on scope filter
    final List<TeamModel> computedTeams = realTeams.map((t) {
      int catPoints = 0;
      int catGolds = 0;
      int catSilvers = 0;
      int catBronzes = 0;

      for (var se in appState.sideEventRecords) {
        if (_selectedCategoryScope != 'Overall Championship') {
          final catName = _selectedCategoryScope.replaceAll(' Category', '');
          if (se.participantsCategory.toLowerCase() != catName.toLowerCase()) {
            continue;
          }
        }

        for (var sp in se.participants) {
          if (t.members.any((m) => m.participantId == sp.participantId) || sp.teamId == t.teamId) {
            catPoints += sp.point;
            if (sp.rank == 1 && sp.point > 0) catGolds++;
            if (sp.rank == 2 && sp.point > 0) catSilvers++;
            if (sp.rank == 3 && sp.point > 0) catBronzes++;
          }
        }
      }

      if (catPoints == 0 && _selectedCategoryScope == 'Overall Championship') {
        catPoints = t.overallPoint;
        catGolds = t.overallMedals.firstCount;
        catSilvers = t.overallMedals.secondCount;
        catBronzes = t.overallMedals.thirdCount;
      }

      return TeamModel(
        teamId: t.teamId,
        teamName: t.teamName,
        teamHouse: t.teamHouse,
        houseColor: t.houseColor,
        teamCaptain: t.teamCaptain,
        teamViceCaptain: t.teamViceCaptain,
        totalMembers: t.members.length,
        overallPoint: catPoints,
        members: t.members,
        overallMedals: TeamMedalsModel(
          firstCount: catGolds,
          secondCount: catSilvers,
          thirdCount: catBronzes,
        ),
      );
    }).toList();

    computedTeams.sort((a, b) {
      int cmp = b.overallPoint.compareTo(a.overallPoint);
      if (cmp != 0) return cmp;
      int gCmp = b.overallMedals.firstCount.compareTo(a.overallMedals.firstCount);
      if (gCmp != 0) return gCmp;
      return b.overallMedals.secondCount.compareTo(a.overallMedals.secondCount);
    });

    TeamModel.calculateTiedRanks(computedTeams);

    // 2. Calculate Top Individual Student Performers Leaderboard
    final Map<String, Map<String, dynamic>> studentStats = {};

    for (var p in appState.realParticipants) {
      String teamName = 'Unassigned';
      final matched = appState.teamRecords.where((t) => t.members.any((m) => m.participantId == p.participantId)).toList();
      if (matched.isNotEmpty) {
        teamName = '${matched.first.teamName} (${matched.first.teamHouse})';
      }

      studentStats[p.participantId] = {
        'id': p.participantId,
        'name': p.name,
        'class': '${p.studentClass} (${p.division})',
        'category': p.category,
        'team': teamName,
        'points': 0,
        'golds': 0,
        'silvers': 0,
        'bronzes': 0,
      };
    }

    for (var se in appState.sideEventRecords) {
      if (_selectedCategoryScope != 'Overall Championship') {
        final catName = _selectedCategoryScope.replaceAll(' Category', '');
        if (se.participantsCategory.toLowerCase() != catName.toLowerCase()) {
          continue;
        }
      }

      for (var sp in se.participants) {
        if (studentStats.containsKey(sp.participantId)) {
          studentStats[sp.participantId]!['points'] = (studentStats[sp.participantId]!['points'] as int) + sp.point;
          if (sp.rank == 1 && sp.point > 0) studentStats[sp.participantId]!['golds'] = (studentStats[sp.participantId]!['golds'] as int) + 1;
          if (sp.rank == 2 && sp.point > 0) studentStats[sp.participantId]!['silvers'] = (studentStats[sp.participantId]!['silvers'] as int) + 1;
          if (sp.rank == 3 && sp.point > 0) studentStats[sp.participantId]!['bronzes'] = (studentStats[sp.participantId]!['bronzes'] as int) + 1;
        }
      }
    }

    final topPerformers = studentStats.values.where((st) => (st['points'] as int) >= 0).toList();
    topPerformers.sort((a, b) {
      int cmp = (b['points'] as int).compareTo(a['points'] as int);
      if (cmp != 0) return cmp;
      return (b['golds'] as int).compareTo(a['golds'] as int);
    });

    final first = computedTeams.isNotEmpty ? computedTeams[0] : null;
    final second = computedTeams.length > 1 ? computedTeams[1] : null;
    final third = computedTeams.length > 2 ? computedTeams[2] : null;

    int totalChampionshipPoints = computedTeams.fold(0, (sum, t) => sum + t.overallPoint);
    int totalGolds = computedTeams.fold(0, (sum, t) => sum + t.overallMedals.firstCount);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.all(Responsive.getPadding(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HERO TITLE BAR & ACTIONS ---
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 20,
              runSpacing: 16,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFF59E0B).withAlpha(80),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.emoji_events_rounded, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Championship Scoreboard',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.textLight : AppColors.textDark,
                          ),
                        ),
                        Text(
                          'Live house standings, category performance scope, and top performers',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: isDark ? AppColors.subtextLight : AppColors.subtextDark,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                Row(
                  children: [
                    // Download PDF Button
                    OutlinedButton.icon(
                      onPressed: () => ScoreboardPdfService.downloadScoreboardPdf(
                        teams: computedTeams,
                        topPerformers: topPerformers,
                        scopeCategory: _selectedCategoryScope,
                        madrasaName: appState.madrasaId,
                      ),
                      icon: const Icon(Icons.download_rounded, size: 18),
                      label: Text('Download PDF', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary, width: 1.5),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Print Scoreboard Button
                    ElevatedButton.icon(
                      onPressed: () => ScoreboardPdfService.printScoreboardPdf(
                        teams: computedTeams,
                        topPerformers: topPerformers,
                        scopeCategory: _selectedCategoryScope,
                        madrasaName: appState.madrasaId,
                      ),
                      icon: const Icon(Icons.print_rounded, size: 18),
                      label: Text('Print Scoreboard', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 3,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Category Scope Segmented Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  'Overall Championship',
                  'Primary Category',
                  'Sub-Junior Category',
                  'Junior Category',
                  'Senior Category',
                  'Super Senior Category',
                  'Alumni Category'
                ].map((scope) {
                  final isSel = _selectedCategoryScope == scope;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      selected: isSel,
                      showCheckmark: false,
                      label: Text(scope),
                      labelStyle: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                        color: isSel ? Colors.white : (isDark ? AppColors.textLight : AppColors.textDark),
                      ),
                      selectedColor: AppColors.primary,
                      backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                      side: BorderSide(
                        color: isSel ? AppColors.primary : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                      ),
                      onSelected: (_) => setState(() => _selectedCategoryScope = scope),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 20),

            // Top Championship Quick Metric Tiles
            Row(
              children: [
                _buildSummaryTile(
                  icon: Icons.shield_rounded,
                  title: '1st Place House',
                  value: first != null ? '${first.teamName} (${first.overallPoint} Pts)' : 'N/A',
                  color: first != null ? Color(int.parse(first.houseColor)) : const Color(0xFFEF4444),
                  isDark: isDark,
                ),
                const SizedBox(width: 14),
                _buildSummaryTile(
                  icon: Icons.military_tech_rounded,
                  title: 'Total Gold Medals',
                  value: '$totalGolds 🥇 Awarded',
                  color: const Color(0xFFEAB308),
                  isDark: isDark,
                ),
                const SizedBox(width: 14),
                _buildSummaryTile(
                  icon: Icons.stars_rounded,
                  title: 'Total Championship Points',
                  value: '$totalChampionshipPoints Pts',
                  color: AppColors.primary,
                  isDark: isDark,
                ),
                const SizedBox(width: 14),
                _buildSummaryTile(
                  icon: Icons.workspace_premium_rounded,
                  title: 'Top Individual Student',
                  value: topPerformers.isNotEmpty ? '${topPerformers.first['name']} (${topPerformers.first['points']} Pts)' : 'N/A',
                  color: const Color(0xFF10B981),
                  isDark: isDark,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // --- CHAMPIONSHIP PODIUM BANNER (3D STYLED TOP 3 HOUSES) ---
            if (computedTeams.isNotEmpty)
              GlassCard(
                padding: const EdgeInsets.all(24),
                borderRadius: 24,
                child: Column(
                  children: [
                    Text(
                      '🏆 MADRASA CHAMPIONSHIP PODIUM STANDINGS 🏆',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15, color: const Color(0xFFF59E0B), letterSpacing: 1.2),
                    ),
                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // 2nd Place (Silver - Left)
                        if (second != null)
                          _buildPodiumCard(
                            context,
                            rankText: '🥈 2ND PLACE',
                            teamName: second.teamName,
                            houseName: second.teamHouse,
                            points: '${second.overallPoint} Pts',
                            color: Color(int.parse(second.houseColor)),
                            height: 190,
                            isCenter: false,
                            medals: second.overallMedals,
                            isDark: isDark,
                          ),
                        if (second != null) const SizedBox(width: 24),

                        // 1st Place (Gold - Center)
                        if (first != null)
                          _buildPodiumCard(
                            context,
                            rankText: '🥇 CHAMPION',
                            teamName: first.teamName,
                            houseName: first.teamHouse,
                            points: '${first.overallPoint} Pts',
                            color: Color(int.parse(first.houseColor)),
                            height: 230,
                            isCenter: true,
                            medals: first.overallMedals,
                            isDark: isDark,
                          ),
                        if (third != null) const SizedBox(width: 24),

                        // 3rd Place (Bronze - Right)
                        if (third != null)
                          _buildPodiumCard(
                            context,
                            rankText: '🥉 3RD PLACE',
                            teamName: third.teamName,
                            houseName: third.teamHouse,
                            points: '${third.overallPoint} Pts',
                            color: Color(int.parse(third.houseColor)),
                            height: 170,
                            isCenter: false,
                            medals: third.overallMedals,
                            isDark: isDark,
                          ),
                      ],
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 28),

            // --- HOUSE CHAMPIONSHIP STANDINGS TABLE ---
            GlassCard(
              padding: const EdgeInsets.all(22),
              borderRadius: 22,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withAlpha(25),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.bar_chart_rounded, color: AppColors.primary, size: 20),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'House Championship Standings ($_selectedCategoryScope)',
                            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? AppColors.textLight : AppColors.textDark),
                          ),
                        ],
                      ),
                      Text(
                        'Live auto-calculated from side events & programs',
                        style: GoogleFonts.poppins(fontSize: 11, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  LayoutBuilder(
                    builder: (context, constraints) {
                      final double tableWidth = constraints.maxWidth > 900 ? constraints.maxWidth : 900;
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          width: tableWidth,
                          child: Column(
                            children: [
                              Container(
                                height: 42,
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    SizedBox(width: 75, child: Text('RANK', style: _headerStyle(isDark))),
                                    Expanded(flex: 3, child: Text('HOUSE / TEAM NAME', style: _headerStyle(isDark))),
                                    Expanded(flex: 2, child: Text('CAPTAIN', style: _headerStyle(isDark))),
                                    SizedBox(width: 100, child: Text('TOTAL PTS', style: _headerStyle(isDark, color: AppColors.primary))),
                                    SizedBox(width: 80, child: Text('GOLD 🥇', style: _headerStyle(isDark, color: const Color(0xFFEAB308)))),
                                    SizedBox(width: 80, child: Text('SILVER 🥈', style: _headerStyle(isDark, color: const Color(0xFF94A3B8)))),
                                    SizedBox(width: 80, child: Text('BRONZE 🥉', style: _headerStyle(isDark, color: const Color(0xFFD97706)))),
                                    SizedBox(width: 100, child: Text('MEDALS', style: _headerStyle(isDark))),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              ...computedTeams.asMap().entries.map((entry) {
                                final rank = entry.key + 1;
                                final t = entry.value;
                                Color color = Color(int.parse(t.houseColor));
                                final m = t.overallMedals;
                                final totalMedals = m.firstCount + m.secondCount + m.thirdCount;

                                return Container(
                                  height: 56,
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.symmetric(horizontal: 14),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: rank == 1
                                          ? const Color(0xFFEAB308).withAlpha(100)
                                          : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                                      width: rank == 1 ? 1.5 : 1.0,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 75,
                                        child: Text(
                                          rank == 1 ? '🥇 #1' : (rank == 2 ? '🥈 #2' : (rank == 3 ? '🥉 #3' : '#$rank')),
                                          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13, color: color),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 12,
                                              height: 12,
                                              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                                            ),
                                            const SizedBox(width: 10),
                                            Text('${t.teamName} (${t.teamHouse})', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13)),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(t.teamCaptain?.participantName ?? 'Unassigned', style: GoogleFonts.poppins(fontSize: 12)),
                                      ),
                                      SizedBox(
                                        width: 100,
                                        child: Text('${t.overallPoint} Pts', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14, color: color)),
                                      ),
                                      SizedBox(width: 80, child: Text('${m.firstCount}', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12, color: const Color(0xFFEAB308)))),
                                      SizedBox(width: 80, child: Text('${m.secondCount}', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12, color: const Color(0xFF94A3B8)))),
                                      SizedBox(width: 80, child: Text('${m.thirdCount}', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12, color: const Color(0xFFD97706)))),
                                      SizedBox(width: 100, child: Text('$totalMedals Medals', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12))),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // --- TOP INDIVIDUAL STUDENT PERFORMERS LEADERBOARD ---
            GlassCard(
              padding: const EdgeInsets.all(22),
              borderRadius: 22,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withAlpha(25),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.person_pin_rounded, color: Color(0xFF10B981), size: 20),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Top Individual Student Performers',
                            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? AppColors.textLight : AppColors.textDark),
                          ),
                        ],
                      ),
                      Text(
                        'Highest Points Earned ($_selectedCategoryScope)',
                        style: GoogleFonts.poppins(fontSize: 11, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  topPerformers.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Center(
                            child: Text(
                              'No individual score records found for this category scope.',
                              style: GoogleFonts.poppins(fontSize: 12, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
                            ),
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: topPerformers.length > 15 ? 15 : topPerformers.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 8),
                          itemBuilder: (context, idx) {
                            final p = topPerformers[idx];
                            final rank = idx + 1;

                            Color badgeColor = AppColors.primary;
                            if (rank == 1) badgeColor = const Color(0xFFEAB308);
                            if (rank == 2) badgeColor = const Color(0xFF94A3B8);
                            if (rank == 3) badgeColor = const Color(0xFFD97706);

                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: badgeColor.withAlpha(25),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '#$rank',
                                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12, color: badgeColor),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          p['name'].toString(),
                                          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13, color: isDark ? AppColors.textLight : AppColors.textDark),
                                        ),
                                        Text(
                                          'Chest ID: ${p['id']} • ${p['class']} • ${p['team']}',
                                          style: GoogleFonts.poppins(fontSize: 11, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: badgeColor.withAlpha(20),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: badgeColor.withAlpha(80)),
                                    ),
                                    child: Text(
                                      '${p['points']} Pts',
                                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13, color: badgeColor),
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
    );
  }

  Widget _buildSummaryTile({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: color.withAlpha(isDark ? 25 : 15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withAlpha(isDark ? 70 : 40)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withAlpha(35),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w500, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
                  ),
                  Text(
                    value,
                    style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: color),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPodiumCard(
    BuildContext context, {
    required String rankText,
    required String teamName,
    required String houseName,
    required String points,
    required Color color,
    required double height,
    required bool isCenter,
    required TeamMedalsModel medals,
    required bool isDark,
  }) {
    return Container(
      width: isCenter ? 220 : 180,
      height: height,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(isCenter ? 35 : 20),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color.withAlpha(isCenter ? 140 : 70), width: isCenter ? 2.5 : 1.2),
        boxShadow: isCenter
            ? [
                BoxShadow(
                  color: color.withAlpha(80),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              rankText,
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.white),
            ),
          ),
          const SizedBox(height: 10),
          Icon(Icons.shield_rounded, color: color, size: isCenter ? 36 : 28),
          const SizedBox(height: 6),
          Text(
            teamName,
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: isCenter ? 15 : 13, color: isDark ? AppColors.textLight : AppColors.textDark),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            houseName,
            style: GoogleFonts.poppins(fontSize: 10, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
          ),
          const SizedBox(height: 4),
          Text(
            points,
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: isCenter ? 16 : 14, color: color),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('🥇 ${medals.firstCount}', style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFFEAB308))),
              const SizedBox(width: 6),
              Text('🥈 ${medals.secondCount}', style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF94A3B8))),
              const SizedBox(width: 6),
              Text('🥉 ${medals.thirdCount}', style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFFD97706))),
            ],
          ),
        ],
      ),
    );
  }

  TextStyle _headerStyle(bool isDark, {Color? color}) {
    return GoogleFonts.poppins(
      fontWeight: FontWeight.bold,
      fontSize: 10,
      letterSpacing: 0.8,
      color: color ?? (isDark ? AppColors.subtextLight : AppColors.subtextDark),
    );
  }
}
