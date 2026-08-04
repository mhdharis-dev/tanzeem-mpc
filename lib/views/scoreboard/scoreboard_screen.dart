import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/providers/app_state.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/glass_card.dart';

class ScoreboardScreen extends StatefulWidget {
  const ScoreboardScreen({super.key});

  @override
  State<ScoreboardScreen> createState() => _ScoreboardScreenState();
}

class _ScoreboardScreenState extends State<ScoreboardScreen> {
  String _selectedCategoryScope = 'Overall Championship';

  final List<Map<String, dynamic>> _houseStandings = [
    {
      'rank': 1,
      'name': 'Al-Fath (Red House)',
      'color': const Color(0xFFEF4444),
      'captain': 'Muhammed Sinan',
      'points': 485,
      'golds': 8,
      'silvers': 5,
      'bronzes': 4,
      'totalMedals': 17,
      'winRate': '47.0%',
    },
    {
      'rank': 2,
      'name': 'Badr (Green House)',
      'color': const Color(0xFF10B981),
      'captain': 'Bilal Hassan',
      'points': 440,
      'golds': 6,
      'silvers': 7,
      'bronzes': 3,
      'totalMedals': 16,
      'winRate': '42.6%',
    },
    {
      'rank': 3,
      'name': 'Uhud (Blue House)',
      'color': const Color(0xFF3B82F6),
      'captain': 'Hamza Ibrahim',
      'points': 395,
      'golds': 5,
      'silvers': 4,
      'bronzes': 6,
      'totalMedals': 15,
      'winRate': '38.2%',
    },
    {
      'rank': 4,
      'name': 'Yarmouk (Gold House)',
      'color': const Color(0xFFF59E0B),
      'captain': 'Khalid Waleed',
      'points': 360,
      'golds': 4,
      'silvers': 5,
      'bronzes': 5,
      'totalMedals': 14,
      'winRate': '34.9%',
    },
  ];

  final List<Map<String, dynamic>> _topPerformers = [
    {'rank': 1, 'name': 'Muhammed Sinan', 'id': 'P101', 'class': 'Class 10', 'team': 'Al-Fath (Red House)', 'points': 45, 'badge': '🥇 Winner'},
    {'rank': 2, 'name': 'Bilal Hassan', 'id': 'P201', 'class': 'Class 10', 'team': 'Badr (Green House)', 'points': 40, 'badge': '🥈 Runner Up'},
    {'rank': 3, 'name': 'Ahmad Raihan', 'id': 'P102', 'class': 'Class 9', 'team': 'Al-Fath (Red House)', 'points': 38, 'badge': '🥉 3rd Place'},
    {'rank': 4, 'name': 'Hamza Ibrahim', 'id': 'P301', 'class': 'Class 10', 'team': 'Uhud (Blue House)', 'points': 35, 'badge': 'Star Performer'},
    {'rank': 5, 'name': 'Zayd Muhammed', 'id': 'P202', 'class': 'Class 9', 'team': 'Badr (Green House)', 'points': 32, 'badge': 'Star Performer'},
    {'rank': 6, 'name': 'Khalid Waleed', 'id': 'P401', 'class': 'Class 10', 'team': 'Yarmouk (Gold House)', 'points': 30, 'badge': 'Top 10'},
    {'rank': 7, 'name': 'Omar Mukhtar', 'id': 'P302', 'class': 'Class 9', 'team': 'Uhud (Blue House)', 'points': 30, 'badge': 'Top 10'},
    {'rank': 8, 'name': 'Tariq Ziyad', 'id': 'P402', 'class': 'Class 9', 'team': 'Yarmouk (Gold House)', 'points': 28, 'badge': 'Top 10'},
  ];

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDark = appState.isDarkMode;

    final first = _houseStandings[0];
    final second = _houseStandings[1];
    final third = _houseStandings[2];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(28.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Bar
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
                            color: const Color(0xFFF59E0B).withAlpha(25),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.military_tech_rounded, color: Color(0xFFF59E0B), size: 28),
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
                              'Live house championship standings, overall medal tally, and top performers',
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
                Row(
                  children: [
                    // Category Scope Filter
                    DropdownButton<String>(
                      value: _selectedCategoryScope,
                      underline: const SizedBox(),
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
                      style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? AppColors.textLight : AppColors.textDark),
                      dropdownColor: isDark ? AppColors.cardDark : Colors.white,
                      items: ['Overall Championship', 'Sub-Junior Category', 'Junior Category', 'Senior Category', 'Super Senior Category']
                          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (val) => setState(() => _selectedCategoryScope = val!),
                    ),
                    const SizedBox(width: 14),
                    ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('🖨️ Exporting official Scoreboard report PDF...'), backgroundColor: AppColors.primary),
                        );
                      },
                      icon: const Icon(Icons.print_rounded, size: 18),
                      label: Text('Print Scoreboard', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Podium Banner (Top 3 Houses)
            GlassCard(
              padding: const EdgeInsets.all(24),
              borderRadius: 24,
              child: Column(
                children: [
                  Text(
                    '🏆 MADRASA CHAMPIONSHIP PODIUM 🏆',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15, color: const Color(0xFFF59E0B), letterSpacing: 1.2),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // 2nd Place (Silver - Left)
                      _buildPodiumCard(
                        context,
                        rankText: '🥈 2ND PLACE',
                        teamName: second['name'],
                        points: '${second['points']} Pts',
                        color: second['color'],
                        height: 180,
                        isCenter: false,
                        isDark: isDark,
                      ),
                      const SizedBox(width: 20),
                      // 1st Place (Gold - Center)
                      _buildPodiumCard(
                        context,
                        rankText: '🥇 CHAMPION',
                        teamName: first['name'],
                        points: '${first['points']} Pts',
                        color: first['color'],
                        height: 220,
                        isCenter: true,
                        isDark: isDark,
                      ),
                      const SizedBox(width: 20),
                      // 3rd Place (Bronze - Right)
                      _buildPodiumCard(
                        context,
                        rankText: '🥉 3RD PLACE',
                        teamName: third['name'],
                        points: '${third['points']} Pts',
                        color: third['color'],
                        height: 160,
                        isCenter: false,
                        isDark: isDark,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // House Championship Standings Table
            GlassCard(
              padding: const EdgeInsets.all(20),
              borderRadius: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'House Championship Standings',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? AppColors.textLight : AppColors.textDark),
                      ),
                      Text(
                        'Updated Live from Coordination Sheets',
                        style: GoogleFonts.poppins(fontSize: 11, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

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
                                height: 40,
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    SizedBox(width: 70, child: Text('RANK', style: _headerStyle(isDark))),
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
                              const SizedBox(height: 6),
                              ..._houseStandings.map((h) {
                                final color = h['color'] as Color;
                                final rank = h['rank'] as int;

                                return Container(
                                  height: 52,
                                  margin: const EdgeInsets.only(bottom: 6),
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: isDark ? AppColors.cardDark : Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
                                  ),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 70,
                                        child: Text(
                                          rank == 1 ? '🥇 #1' : (rank == 2 ? '🥈 #2' : (rank == 3 ? '🥉 #3' : '#$rank')),
                                          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13, color: color),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Row(
                                          children: [
                                            Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                                            const SizedBox(width: 10),
                                            Text(h['name'], style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13)),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(h['captain'], style: GoogleFonts.poppins(fontSize: 12)),
                                      ),
                                      SizedBox(
                                        width: 100,
                                        child: Text('${h['points']} Pts', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13, color: color)),
                                      ),
                                      SizedBox(width: 80, child: Text('${h['golds']}', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12, color: const Color(0xFFEAB308)))),
                                      SizedBox(width: 80, child: Text('${h['silvers']}', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12, color: const Color(0xFF94A3B8)))),
                                      SizedBox(width: 80, child: Text('${h['bronzes']}', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12, color: const Color(0xFFD97706)))),
                                      SizedBox(width: 100, child: Text('${h['totalMedals']} Medals', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12))),
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

            // Top Individual Student Performers Leaderboard
            GlassCard(
              padding: const EdgeInsets.all(20),
              borderRadius: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Top Individual Student Performers',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? AppColors.textLight : AppColors.textDark),
                      ),
                      Text(
                        'Highest Points Earned Across All Events',
                        style: GoogleFonts.poppins(fontSize: 11, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _topPerformers.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, idx) {
                      final p = _topPerformers[idx];
                      final rank = p['rank'] as int;

                      Color badgeColor = AppColors.primary;
                      if (rank == 1) badgeColor = const Color(0xFFEAB308);
                      if (rank == 2) badgeColor = const Color(0xFF94A3B8);
                      if (rank == 3) badgeColor = const Color(0xFFD97706);

                      return ListTile(
                        dense: true,
                        leading: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: badgeColor.withAlpha(25),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '#$rank',
                              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 11, color: badgeColor),
                            ),
                          ),
                        ),
                        title: Text(p['name'], style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13)),
                        subtitle: Text('${p['id']} • ${p['class']} • House: ${p['team']}', style: GoogleFonts.poppins(fontSize: 11)),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: badgeColor.withAlpha(20),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: badgeColor.withAlpha(80)),
                          ),
                          child: Text(
                            '${p['points']} Pts',
                            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12, color: badgeColor),
                          ),
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

  Widget _buildPodiumCard(
    BuildContext context, {
    required String rankText,
    required String teamName,
    required String points,
    required Color color,
    required double height,
    required bool isCenter,
    required bool isDark,
  }) {
    return Container(
      width: isCenter ? 220 : 180,
      height: height,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(isCenter ? 35 : 20),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(isCenter ? 120 : 60), width: isCenter ? 2 : 1),
        boxShadow: isCenter ? [BoxShadow(color: color.withAlpha(60), blurRadius: 16, offset: const Offset(0, 4))] : null,
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
          const SizedBox(height: 8),
          Text(
            teamName,
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: isCenter ? 14 : 12, color: isDark ? AppColors.textLight : AppColors.textDark),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            points,
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: isCenter ? 16 : 14, color: color),
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
