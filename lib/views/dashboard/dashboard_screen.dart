// Library: dashboard_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/models/models.dart';
import '../../core/providers/app_state.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/glass_card.dart';
import '../../core/utils/responsive.dart';
import '../programs/add_program_sheet.dart';
import '../programs/add_program_dialog.dart';
import '../side_events/add_side_event_sheet.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Timer _clockTimer;
  String _currentTimeString = '';

  @override
  void initState() {
    super.initState();
    _updateClock();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        _updateClock();
      }
    });
  }

  void _updateClock() {
    setState(() {
      _currentTimeString = DateFormat('hh:mm:ss a').format(DateTime.now());
    });
  }

  @override
  void dispose() {
    _clockTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDark = appState.isDarkMode;
    final isSuperAdmin = appState.userRole == 'Super Admin';
    final activeMadrasaId = appState.madrasaId;

    // 1. Madrasa-Scoped Data Calculations
    final totalMadrasas = appState.madrasas.length;
    final onlineCoordinators = appState.madrasas.where((m) => m.isOnline).length;

    // Filter Programs by active madrasa if coordinator
    final madrasaPrograms = isSuperAdmin
        ? appState.programs
        : appState.programs.where((p) => p.madrasaId.isEmpty || p.madrasaId == activeMadrasaId).toList();
    final totalProgs = madrasaPrograms.length;
    final completedProgs = madrasaPrograms.where((p) => p.status == ProgramStatus.completed).length;
    final pendingProgs = madrasaPrograms.where((p) => p.status == ProgramStatus.pending).length;
    final liveProgs = madrasaPrograms.where((p) => p.status == ProgramStatus.live).length;

    // Progress percentage
    final double festCompletionRatio = totalProgs > 0 ? (completedProgs / totalProgs) : 0.0;
    final int festCompletionPercentage = (festCompletionRatio * 100).round();

    // Filter Participants by active madrasa
    final madrasaParticipants = isSuperAdmin
        ? appState.participants
        : appState.participants.where((p) => p.madrasaId.isEmpty || p.madrasaId == activeMadrasaId).toList();
    final totalParticipants = madrasaParticipants.length;

    // Filter Side Events by active madrasa
    final madrasaSideEvents = appState.sideEventRecords;
    final totalSideEvents = madrasaSideEvents.length;

    // Filter Attendance Records & Mark Records
    final presentCount = appState.presentRecords.length;
    final markCount = appState.markRecords.length;

    // Filter Team Records
    final teamRecords = isSuperAdmin
        ? appState.teamRecords
        : appState.teamRecords.where((t) => t.madrasaId.isEmpty || t.madrasaId == activeMadrasaId).toList();

    final scheduleSlots = appState.scheduleSlots;
    final dateStr = DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now());

    // Top Team Leaderboard Calculation for active Madrasa
    TeamModel? leadingTeam;
    if (teamRecords.isNotEmpty) {
      final sorted = List<TeamModel>.from(teamRecords)..sort((a, b) => b.overallPoint.compareTo(a.overallPoint));
      leadingTeam = sorted.first;
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.all(Responsive.getPadding(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- 1. ATTRACTIVE ANIMATED HERO GLASS HEADER WITH LIVE CLOCK ---
          GlassCard(
            borderRadius: 24,
            padding: const EdgeInsets.all(28),
            customBgColor: isDark ? const Color(0xFF1E293B) : Colors.white,
            child: Stack(
              children: [
                // Ambient Glow Orbs
                Positioned(
                  right: -40,
                  top: -40,
                  child: Container(
                    width: 240,
                    height: 240,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withAlpha(25),
                    ),
                  ),
                ),
                Positioned(
                  left: -50,
                  bottom: -50,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.secondary.withAlpha(20),
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
                        // Title & Live Greeting
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 10,
                              runSpacing: 6,
                              children: [
                                Text(
                                  isSuperAdmin
                                      ? 'Super Admin Network Hub 👑'
                                      : 'Assalamu Alaikum Usthad! 🌙',
                                  style: GoogleFonts.poppins(
                                    fontSize: 22,
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
                              isSuperAdmin
                                  ? '$dateStr  •  Meelad Coordinator Hub  •  Grand Network Control'
                                  : '$dateStr  •  Madrasa ID: $activeMadrasaId  •  Meelad Fest Command Center',
                              style: GoogleFonts.poppins(
                                fontSize: 12.5,
                                color: isDark ? AppColors.subtextLight : AppColors.subtextDark,
                              ),
                            ),
                          ],
                        ),

                        // Live Clock & Live Sync Badge Card
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isDark ? AppColors.glassBorderDark : AppColors.glassBorderLight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(10),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withAlpha(30),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.access_time_filled_rounded, color: AppColors.primary, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _currentTimeString,
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: AppColors.success,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        isSuperAdmin
                                            ? '$totalMadrasas Connected ($onlineCoordinators Live)'
                                            : 'Firestore Live Synced',
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
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Overall Festival Progress Bar
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Overall Meelad Festival Progress',
                              style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
                            ),
                            Text(
                              '$festCompletionPercentage% Completed ($completedProgs/$totalProgs Programs)',
                              style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: festCompletionRatio.clamp(0.02, 1.0),
                            minHeight: 10,
                            backgroundColor: isDark ? Colors.white10 : Colors.black12,
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),

                    // --- DIRECT MANAGEMENT ACTIONS ROW ---
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (ctx) => const AddProgramSheet(),
                            );
                          },
                          icon: const Icon(Icons.add_circle_outline_rounded, size: 16),
                          label: const Text('+ Add Program Sheet'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (ctx) => const AddSideEventSheet(),
                            );
                          },
                          icon: const Icon(Icons.festival_rounded, size: 16),
                          label: const Text('+ Add Side Event'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => const AddProgramDialog(),
                            );
                          },
                          icon: const Icon(Icons.flash_on_rounded, size: 16),
                          label: const Text('Quick Single Entry'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => appState.setTabIndex(3),
                          icon: const Icon(Icons.live_tv_rounded, size: 16),
                          label: const Text('Live Auditorium Console'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => appState.setTabIndex(2),
                          icon: const Icon(Icons.auto_awesome_rounded, size: 16),
                          label: const Text('Schedule Rules'),
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

          // --- 2. MADRASA REAL-TIME METRICS CARDS (6 STAT CARDS) ---
          Text(
            isSuperAdmin ? 'Network Overview Metrics' : '${appState.madrasaName} - Real-Time Live Overview',
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

              double aspectRatio = constraints.maxWidth < 420
                  ? 2.2
                  : (constraints.maxWidth < 600 ? 2.0 : 1.8);

              return GridView.count(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: aspectRatio,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildStatCard(
                    context,
                    title: 'Madrasa Programs',
                    value: '$totalProgs',
                    subtitle: 'Done: $completedProgs • Live: $liveProgs',
                    icon: Icons.assignment_rounded,
                    color: AppColors.primary,
                  ),
                  _buildStatCard(
                    context,
                    title: 'Students Registered',
                    value: '$totalParticipants',
                    subtitle: 'Madrasa Participants',
                    icon: Icons.people_alt_rounded,
                    color: AppColors.secondary,
                  ),
                  _buildStatCard(
                    context,
                    title: 'Side Contests',
                    value: '$totalSideEvents Events',
                    subtitle: 'Off-Stage Competitions',
                    icon: Icons.festival_rounded,
                    color: const Color(0xFF10B981),
                  ),
                  _buildStatCard(
                    context,
                    title: 'Leading House',
                    value: leadingTeam != null ? leadingTeam.teamName : 'No Teams',
                    subtitle: leadingTeam != null ? '${leadingTeam.overallPoint} Pts Tally' : 'Pending',
                    icon: Icons.emoji_events_rounded,
                    color: const Color(0xFFF59E0B),
                  ),
                  _buildStatCard(
                    context,
                    title: 'Evaluated Marks',
                    value: '$markCount Scores',
                    subtitle: 'Present: $presentCount • Scores: $markCount',
                    icon: Icons.fact_check_rounded,
                    color: const Color(0xFF8B5CF6),
                  ),
                  _buildStatCard(
                    context,
                    title: 'Pending Stage Call',
                    value: '$pendingProgs',
                    subtitle: 'Awaiting Call to Stage',
                    icon: Icons.hourglass_top_rounded,
                    color: const Color(0xFFEC4899),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 24),

          // --- 3. LIVE TRACKING & STAGE READINESS CONSOLE ---
          _buildStageReadinessTrackingConsole(context, appState, madrasaPrograms, isDark),

          const SizedBox(height: 24),

          // --- 4. WORKSPACE: CATEGORY BREAKDOWN, LEADERBOARD & RECENT ACTIVITY ---
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 920;

              return isWide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // LEFT COLUMN (60%): Category Distribution + Activity Ticker Feed
                        Expanded(
                          flex: 6,
                          child: Column(
                            children: [
                              _buildCategoryAndClassDistributionWidget(context, madrasaPrograms, isDark),
                              const SizedBox(height: 20),
                              _buildRecentActivityAuditFeed(context, appState, isDark),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),

                        // RIGHT COLUMN (40%): Team Standings Leaderboard + Schedule Timeline Queue
                        Expanded(
                          flex: 4,
                          child: Column(
                            children: [
                              _buildTeamStandingsLeaderboardCard(context, teamRecords, isDark, appState),
                              const SizedBox(height: 20),
                              _buildTimelineQueuePreviewCard(context, scheduleSlots, isDark),
                            ],
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        _buildCategoryAndClassDistributionWidget(context, madrasaPrograms, isDark),
                        const SizedBox(height: 20),
                        _buildRecentActivityAuditFeed(context, appState, isDark),
                        const SizedBox(height: 20),
                        _buildTeamStandingsLeaderboardCard(context, teamRecords, isDark, appState),
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

  // --- 3. STAGE READINESS & PERFORMER TRACKING CONSOLE ---
  Widget _buildStageReadinessTrackingConsole(
    BuildContext context,
    AppState appState,
    List<Program> madrasaPrograms,
    bool isDark,
  ) {
    final liveProgram = madrasaPrograms.firstWhere(
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

    final pendingPrograms = madrasaPrograms.where((p) => p.status == ProgramStatus.pending).toList();
    final nextOnDeck = pendingPrograms.isNotEmpty ? pendingPrograms.first : null;
    final upcomingQueued = pendingPrograms.length > 1 ? pendingPrograms[1] : null;

    final isLiveActive = liveProgram.id != 'NONE';

    return GlassCard(
      borderRadius: 22,
      padding: const EdgeInsets.all(24),
      customBgColor: isLiveActive ? AppColors.primary.withAlpha(20) : (isDark ? const Color(0xFF1E293B) : Colors.white),
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
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: isLiveActive ? Colors.redAccent : Colors.amber,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (isLiveActive ? Colors.redAccent : Colors.amber).withAlpha(150),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    isLiveActive ? '🔴 LIVE AUDITORIUM STAGE TRACKER' : '⏳ AUDITORIUM STAGE IDLE',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isLiveActive ? Colors.redAccent : Colors.amber.shade800,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => appState.setTabIndex(3),
                icon: const Icon(Icons.launch_rounded, size: 14),
                label: Text('Open Stage Console', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 11.5)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // 3 Stage Tracker Columns (ON STAGE, ON DECK BACKSTAGE, UPCOMING CALL)
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 800;

              return isWide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildStageStatusColumn('ON STAGE 🔴', liveProgram.studentName, liveProgram.item, liveProgram.studentClass, isLiveActive ? Colors.redAccent : Colors.grey, isLiveActive, 'Live Performance')),
                        const SizedBox(width: 14),
                        Expanded(child: _buildStageStatusColumn('ON DECK BACKSTAGE 🟡', nextOnDeck != null ? nextOnDeck.studentName : 'None Queued', nextOnDeck != null ? nextOnDeck.item : 'N/A', nextOnDeck != null ? nextOnDeck.studentClass : 'N/A', Colors.amber, nextOnDeck != null, 'Reported Ready')),
                        const SizedBox(width: 14),
                        Expanded(child: _buildStageStatusColumn('UPCOMING CALL 📲', upcomingQueued != null ? upcomingQueued.studentName : 'None Queued', upcomingQueued != null ? upcomingQueued.item : 'N/A', upcomingQueued != null ? upcomingQueued.studentClass : 'N/A', AppColors.primary, upcomingQueued != null, 'Call Sent')),
                      ],
                    )
                  : Column(
                      children: [
                        _buildStageStatusColumn('ON STAGE 🔴', liveProgram.studentName, liveProgram.item, liveProgram.studentClass, isLiveActive ? Colors.redAccent : Colors.grey, isLiveActive, 'Live Performance'),
                        const SizedBox(height: 12),
                        _buildStageStatusColumn('ON DECK BACKSTAGE 🟡', nextOnDeck != null ? nextOnDeck.studentName : 'None Queued', nextOnDeck != null ? nextOnDeck.item : 'N/A', nextOnDeck != null ? nextOnDeck.studentClass : 'N/A', Colors.amber, nextOnDeck != null, 'Reported Ready'),
                        const SizedBox(height: 12),
                        _buildStageStatusColumn('UPCOMING CALL 📲', upcomingQueued != null ? upcomingQueued.studentName : 'None Queued', upcomingQueued != null ? upcomingQueued.item : 'N/A', upcomingQueued != null ? upcomingQueued.studentClass : 'N/A', AppColors.primary, upcomingQueued != null, 'Call Sent'),
                      ],
                    );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStageStatusColumn(
    String badgeTitle,
    String studentName,
    String itemName,
    String className,
    Color color,
    bool isActive,
    String statusDesc,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withAlpha(80), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              badgeTitle,
              style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: color),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            studentName,
            style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? AppColors.textLight : AppColors.textDark),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            'Item: $itemName',
            style: GoogleFonts.poppins(fontSize: 11.5, color: isDark ? AppColors.subtextLight : AppColors.subtextDark, fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                className,
                style: GoogleFonts.poppins(fontSize: 10.5, fontWeight: FontWeight.bold, color: color),
              ),
              Text(
                statusDesc,
                style: GoogleFonts.poppins(fontSize: 10, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- RECENT ACTIVITY AUDIT FEED ---
  Widget _buildRecentActivityAuditFeed(BuildContext context, AppState appState, bool isDark) {
    final activities = [
      {'time': 'Just now', 'event': 'Meelad Festival Schedule & Rules Synced with Cloud', 'icon': Icons.sync_rounded, 'color': AppColors.primary},
      {'time': '12 mins ago', 'event': 'Class Attendance Sheet synchronized for 5th & 7th Division', 'icon': Icons.fact_check_rounded, 'color': const Color(0xFF10B981)},
      {'time': '25 mins ago', 'event': 'Evaluated Mark Scorecards recorded for Qira\'at Competition', 'icon': Icons.stars_rounded, 'color': const Color(0xFFF59E0B)},
      {'time': '40 mins ago', 'event': 'Off-Stage Calligraphy Contest Round 1 passed by 8 candidates', 'icon': Icons.festival_rounded, 'color': const Color(0xFF8B5CF6)},
    ];

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
                  const Icon(Icons.history_rounded, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Recent Coordinator Activity Feed',
                    style: GoogleFonts.poppins(
                      fontSize: 15.5,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.textLight : AppColors.textDark,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('Live Audit Log', style: GoogleFonts.poppins(fontSize: 10.5, fontWeight: FontWeight.bold, color: AppColors.primary)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 14),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: activities.length,
            separatorBuilder: (context, index) => const Divider(height: 14, color: Colors.white10),
            itemBuilder: (context, idx) {
              final act = activities[idx];
              final Color color = act['color'] as Color;

              return Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withAlpha(25),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(act['icon'] as IconData, color: color, size: 16),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          act['event'] as String,
                          style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? AppColors.textLight : AppColors.textDark),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          act['time'] as String,
                          style: GoogleFonts.poppins(fontSize: 10, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
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

  // --- CATEGORY & CLASS REAL DISTRIBUTION WIDGET ---
  Widget _buildCategoryAndClassDistributionWidget(
    BuildContext context,
    List<Program> madrasaPrograms,
    bool isDark,
  ) {
    final subJuniorCount = madrasaPrograms.where((p) => p.studentClass.toLowerCase().contains('sub')).length;
    final juniorCount = madrasaPrograms.where((p) => p.studentClass.toLowerCase().contains('junior') && !p.studentClass.toLowerCase().contains('sub')).length;
    final seniorCount = madrasaPrograms.where((p) => p.studentClass.toLowerCase().contains('senior') && !p.studentClass.toLowerCase().contains('super')).length;
    final superSeniorCount = madrasaPrograms.where((p) => p.studentClass.toLowerCase().contains('super')).length;

    final maxVal = (madrasaPrograms.isEmpty) ? 1 : madrasaPrograms.length;

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
                'Madrasa Category Distribution',
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
                  '${madrasaPrograms.length} Programs',
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
  Widget _buildTeamStandingsLeaderboardCard(
    BuildContext context,
    List<TeamModel> teamRecords,
    bool isDark,
    AppState appState,
  ) {
    final teams = List<TeamModel>.from(teamRecords)
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
                  'No teams configured for this Madrasa.',
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
