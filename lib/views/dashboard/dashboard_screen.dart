// Library: dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/models/models.dart';
import '../../core/providers/app_state.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/glass_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDark = appState.isDarkMode;
    final isSuperAdmin = appState.userRole == 'Super Admin';

    // Real Data calculations from AppState
    final totalMadrasas = appState.madrasas.length;
    final onlineCoordinators = appState.madrasas.where((m) => m.isOnline).length;

    final totalProgs = appState.programs.length;
    final completedProgs = appState.programs.where((p) => p.status == ProgramStatus.completed).length;
    final pendingProgs = appState.programs.where((p) => p.status == ProgramStatus.pending).length;
    final liveProgs = appState.programs.where((p) => p.status == ProgramStatus.live).length;

    final totalParticipants = appState.participants.length;
    final presentCount = appState.presentRecords.length;
    final markCount = appState.markRecords.length;
    final teamRecords = appState.teamRecords;
    final scheduleSlots = appState.scheduleSlots;

    final dateStr = DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now());

    // Top Team Leaderboard Calculation
    TeamModel? leadingTeam;
    if (teamRecords.isNotEmpty) {
      final sorted = List<TeamModel>.from(teamRecords)..sort((a, b) => b.overallPoint.compareTo(a.overallPoint));
      leadingTeam = sorted.first;
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- 1. HERO WELCOME GRADIENT GLASS HEADER ---
          GlassCard(
            borderRadius: 24,
            padding: const EdgeInsets.all(28),
            customBgColor: isDark ? const Color(0xFF1E293B) : Colors.white,
            child: Stack(
              children: [
                Positioned(
                  right: -40,
                  top: -40,
                  child: Container(
                    width: 240,
                    height: 240,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withAlpha(30),
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 20,
                      runSpacing: 16,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 10,
                              runSpacing: 6,
                              children: [
                                Text(
                                  isSuperAdmin ? 'Welcome, Super Admin 👑' : 'Coordinator Control Dashboard 👋',
                                  style: GoogleFonts.poppins(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? AppColors.textLight : AppColors.textDark,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isSuperAdmin ? AppColors.accent.withAlpha(40) : AppColors.primary.withAlpha(40),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSuperAdmin ? AppColors.accent.withAlpha(100) : AppColors.primary.withAlpha(100),
                                    ),
                                  ),
                                  child: Text(
                                    isSuperAdmin ? 'SUPER ADMIN' : appState.madrasaName,
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: isSuperAdmin ? AppColors.accent : AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '$dateStr  •  Meelad Coordinator Hub  •  Grand Auditorium',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: isDark ? AppColors.subtextLight : AppColors.subtextDark,
                              ),
                            ),
                          ],
                        ),

                        // System Status Pill Card
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDark ? AppColors.glassBorderDark : AppColors.glassBorderLight,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: AppColors.success,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Cloud Firestore Live Sync',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12.5,
                                      color: isDark ? AppColors.textLight : AppColors.textDark,
                                    ),
                                  ),
                                  Text(
                                    '$totalMadrasas Madrasas Network Connected',
                                    style: GoogleFonts.poppins(
                                      fontSize: 10.5,
                                      color: AppColors.success,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Quick Nav Action Chips Row
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => appState.setTabIndex(3), // Live stage tab
                          icon: const Icon(Icons.live_tv_rounded, size: 16),
                          label: const Text('Live Stage Auditorium Console'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => appState.setTabIndex(1), // Programs Tab
                          icon: const Icon(Icons.assignment_outlined, size: 16),
                          label: const Text('Programs List'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => appState.setTabIndex(2), // Schedule Tab
                          icon: const Icon(Icons.auto_awesome_rounded, size: 16),
                          label: const Text('Auto-Schedule Rules'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => appState.setTabIndex(4), // Coordination tab
                          icon: const Icon(Icons.how_to_reg_outlined, size: 16),
                          label: const Text('Attendance & Marks'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => appState.setTabIndex(5), // Teams tab
                          icon: const Icon(Icons.emoji_events_outlined, size: 16),
                          label: const Text('Team Tally'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

          // --- 2. OVERVIEW METRICS CARDS GRID (6 STAT CARDS) ---
          Text(
            'Real-Time Live Overview',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textLight : AppColors.textDark,
            ),
          ),
          const SizedBox(height: 14),

          LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount = constraints.maxWidth > 1150
                  ? 6
                  : constraints.maxWidth > 800
                      ? 3
                      : constraints.maxWidth > 500
                          ? 2
                          : 1;

              return GridView.count(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 1.8,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildStatCard(
                    context,
                    title: 'Total Programs',
                    value: '$totalProgs',
                    subtitle: 'Finished: $completedProgs • Live: $liveProgs',
                    icon: Icons.assignment_rounded,
                    color: AppColors.primary,
                  ),
                  _buildStatCard(
                    context,
                    title: 'Participants',
                    value: '$totalParticipants',
                    subtitle: 'Students Enrolled',
                    icon: Icons.people_alt_rounded,
                    color: AppColors.secondary,
                  ),
                  _buildStatCard(
                    context,
                    title: 'Madrasa Network',
                    value: '$totalMadrasas',
                    subtitle: 'Online: $onlineCoordinators Active',
                    icon: Icons.domain_rounded,
                    color: const Color(0xFF10B981),
                  ),
                  _buildStatCard(
                    context,
                    title: 'Leading House',
                    value: leadingTeam != null ? leadingTeam.teamName : 'No Teams',
                    subtitle: leadingTeam != null ? '${leadingTeam.overallPoint} Points Tally' : 'Tally Pending',
                    icon: Icons.emoji_events_rounded,
                    color: const Color(0xFFF59E0B),
                  ),
                  _buildStatCard(
                    context,
                    title: 'Evaluated Marks',
                    value: '$markCount Marks',
                    subtitle: 'Present: $presentCount Records',
                    icon: Icons.fact_check_rounded,
                    color: const Color(0xFF8B5CF6),
                  ),
                  _buildStatCard(
                    context,
                    title: 'Pending Programs',
                    value: '$pendingProgs',
                    subtitle: 'Awaiting call to stage',
                    icon: Icons.hourglass_top_rounded,
                    color: const Color(0xFFEC4899),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 24),

          // --- 3. UNIFIED RESPONSIVE WORKSPACE (LIVE LED CONSOLE + TIMELINE & LEADERBOARD) ---
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 920;

              return isWide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // LEFT COLUMN (60%): Live Auditorium Banner + Real Distribution Charts
                        Expanded(
                          flex: 6,
                          child: Column(
                            children: [
                              _buildLiveAuditoriumConsoleCard(context, appState, isDark),
                              const SizedBox(height: 20),
                              _buildCategoryAndClassDistributionWidget(context, appState, isDark),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),

                        // RIGHT COLUMN (40%): Real Team Standings Leaderboard + Timeline Queue
                        Expanded(
                          flex: 4,
                          child: Column(
                            children: [
                              _buildTeamStandingsLeaderboardCard(context, appState, isDark),
                              const SizedBox(height: 20),
                              _buildTimelineQueuePreviewCard(context, scheduleSlots, isDark),
                            ],
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        _buildLiveAuditoriumConsoleCard(context, appState, isDark),
                        const SizedBox(height: 20),
                        _buildCategoryAndClassDistributionWidget(context, appState, isDark),
                        const SizedBox(height: 20),
                        _buildTeamStandingsLeaderboardCard(context, appState, isDark),
                        const SizedBox(height: 20),
                        _buildTimelineQueuePreviewCard(context, scheduleSlots, isDark),
                      ],
                    );
            },
          ),
        ],
      ),
    );
  }

  // --- LIVE AUDITORIUM LED CONSOLE WIDGET ---
  Widget _buildLiveAuditoriumConsoleCard(BuildContext context, AppState appState, bool isDark) {
    final liveProgram = appState.programs.firstWhere(
      (p) => p.status == ProgramStatus.live,
      orElse: () => Program(
        id: 'NONE',
        number: '#00',
        studentName: 'No Performer Live',
        studentPhoto: '',
        studentClass: 'N/A',
        category: 'Auditorium Idle',
        item: 'Stage Idle',
        durationMinutes: 12,
        stage: 'Main Stage',
        status: ProgramStatus.pending,
        startTime: '08:30 AM',
        teacher: 'Co-ordinator',
      ),
    );

    final isLiveActive = liveProgram.id != 'NONE';

    return GlassCard(
      borderRadius: 22,
      padding: const EdgeInsets.all(22),
      customBgColor: isLiveActive ? AppColors.primary.withAlpha(22) : (isDark ? const Color(0xFF1E293B) : Colors.white),
      customBorderColor: isLiveActive ? AppColors.primary.withAlpha(100) : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: isLiveActive ? Colors.redAccent : Colors.amber,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isLiveActive ? '🔴 LIVE ON AUDITORIUM STAGE' : '⏳ AUDITORIUM STAGE IDLE',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 12.5,
                      color: isLiveActive ? Colors.redAccent : Colors.amber.shade800,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => appState.setTabIndex(3), // Launch Live Stage LED View
                icon: const Icon(Icons.launch_rounded, size: 14),
                label: Text('Open Stage Console', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 11.5)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (isLiveActive) ...[
            Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withAlpha(30),
                    border: Border.all(color: AppColors.primary, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      liveProgram.studentName.isNotEmpty ? liveProgram.studentName[0].toUpperCase() : 'S',
                      style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        liveProgram.studentName,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.textLight : AppColors.textDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Item: ${liveProgram.item}  •  ${liveProgram.studentClass} (${liveProgram.category})',
                        style: GoogleFonts.poppins(fontSize: 12, color: AppColors.secondary, fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ] else ...[
            Text(
              'No performance currently live. Launch the Live Stage Console to call programs to stage.',
              style: GoogleFonts.poppins(fontSize: 12, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
            ),
          ],
        ],
      ),
    );
  }

  // --- CATEGORY & CLASS REAL DISTRIBUTION WIDGET ---
  Widget _buildCategoryAndClassDistributionWidget(BuildContext context, AppState appState, bool isDark) {
    final progs = appState.programs;

    // Real computations
    final subJuniorCount = progs.where((p) => p.studentClass.toLowerCase().contains('sub')).length;
    final juniorCount = progs.where((p) => p.studentClass.toLowerCase().contains('junior') && !p.studentClass.toLowerCase().contains('sub')).length;
    final seniorCount = progs.where((p) => p.studentClass.toLowerCase().contains('senior') && !p.studentClass.toLowerCase().contains('super')).length;
    final superSeniorCount = progs.where((p) => p.studentClass.toLowerCase().contains('super')).length;

    final maxVal = (progs.isEmpty) ? 1 : progs.length;

    return GlassCard(
      borderRadius: 22,
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Class Distribution Breakdown',
                style: GoogleFonts.poppins(
                  fontSize: 15.5,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textLight : AppColors.textDark,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${progs.length} Total Programs',
                  style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _buildClassBarItem(context, 'Sub-Junior', subJuniorCount / maxVal, '$subJuniorCount Items', AppColors.primary),
          _buildClassBarItem(context, 'Junior', juniorCount / maxVal, '$juniorCount Items', AppColors.secondary),
          _buildClassBarItem(context, 'Senior', seniorCount / maxVal, '$seniorCount Items', const Color(0xFF10B981)),
          _buildClassBarItem(context, 'Super Senior', superSeniorCount / maxVal, '$superSeniorCount Items', const Color(0xFF8B5CF6)),
        ],
      ),
    );
  }

  // --- TEAM POINTS & MEDAL STANDINGS LEADERBOARD CARD ---
  Widget _buildTeamStandingsLeaderboardCard(BuildContext context, AppState appState, bool isDark) {
    final teams = List<TeamModel>.from(appState.teamRecords)
      ..sort((a, b) => b.overallPoint.compareTo(a.overallPoint));

    return GlassCard(
      borderRadius: 22,
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.emoji_events_rounded, color: Color(0xFFF59E0B), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Team Medal Leaderboard',
                    style: GoogleFonts.poppins(
                      fontSize: 15.5,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.textLight : AppColors.textDark,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () => appState.setTabIndex(5),
                child: Text(
                  'View All',
                  style: GoogleFonts.poppins(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 14),
          if (teams.isEmpty)
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Center(
                child: Text(
                  'No teams configured in cluster.',
                  style: GoogleFonts.poppins(fontSize: 11.5, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: teams.take(4).length,
              separatorBuilder: (context, index) => const Divider(height: 14, color: Colors.white10),
              itemBuilder: (context, idx) {
                final team = teams[idx];
                final rank = idx + 1;

                Color rankColor = AppColors.primary;
                if (rank == 1) rankColor = const Color(0xFFF59E0B);
                if (rank == 2) rankColor = const Color(0xFF94A3B8);
                if (rank == 3) rankColor = const Color(0xFFD97706);

                return Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: rankColor.withAlpha(30),
                        shape: BoxShape.circle,
                        border: Border.all(color: rankColor, width: 1.5),
                      ),
                      child: Center(
                        child: Text(
                          '#$rank',
                          style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: rankColor),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            team.teamName,
                            style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? AppColors.textLight : AppColors.textDark),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '🥇 ${team.overallMedals.firstCount}  🥈 ${team.overallMedals.secondCount}  🥉 ${team.overallMedals.thirdCount}',
                            style: GoogleFonts.poppins(fontSize: 10.5, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: rankColor.withAlpha(20),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${team.overallPoint} Pts',
                        style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: rankColor),
                      ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  // --- TIMELINE QUEUE PREVIEW CARD ---
  Widget _buildTimelineQueuePreviewCard(BuildContext context, List<ScheduleSlot> scheduleSlots, bool isDark) {
    return GlassCard(
      borderRadius: 22,
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Auto-Scheduled Timeline',
                style: GoogleFonts.poppins(
                  fontSize: 15.5,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textLight : AppColors.textDark,
                ),
              ),
              Text(
                '${scheduleSlots.length} Items',
                style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 14),
          if (scheduleSlots.isEmpty)
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Center(
                child: Text(
                  'No auto-generated schedule slots.',
                  style: GoogleFonts.poppins(fontSize: 11.5, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: scheduleSlots.take(4).length,
              separatorBuilder: (context, index) => const Divider(height: 14, color: Colors.white10),
              itemBuilder: (context, idx) {
                final slot = scheduleSlots[idx];
                return Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(20),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        slot.startTime,
                        style: GoogleFonts.poppins(fontSize: 10.5, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            slot.title,
                            style: GoogleFonts.poppins(
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.textLight : AppColors.textDark,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            slot.program != null ? '${slot.program!.studentName} • ${slot.program!.studentClass}' : 'Break / Pause',
                            style: GoogleFonts.poppins(fontSize: 10.5, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassCard(
      borderRadius: 18,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 10.5,
                    color: isDark ? AppColors.subtextLight : AppColors.subtextDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textLight : AppColors.textDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassBarItem(BuildContext context, String title, double progress, String count, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(fontSize: 12.5, fontWeight: FontWeight.w600, color: isDark ? AppColors.textLight : AppColors.textDark),
              ),
              Text(
                count,
                style: GoogleFonts.poppins(fontSize: 11.5, fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress.clamp(0.05, 1.0),
              minHeight: 7,
              backgroundColor: isDark ? Colors.white10 : Colors.black12,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}
