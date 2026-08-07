// Library: live_stage_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/models/models.dart';
import '../../core/providers/app_state.dart';
import '../../core/theme/app_colors.dart';

class LiveStageScreen extends StatefulWidget {
  const LiveStageScreen({super.key});

  @override
  State<LiveStageScreen> createState() => _LiveStageScreenState();
}

class _LiveStageScreenState extends State<LiveStageScreen> {
  bool _isFullscreenMode = false;

  void _startStageBuffer(AppState appState, int seconds) {
    appState.startLiveTimer();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDark = appState.isDarkMode;

    final currentIdx = appState.liveStageProgramIndex;
    final totalPrograms = appState.programs.length;
    final hasCurrent = currentIdx >= 0 && currentIdx < totalPrograms;
    final currentProg = hasCurrent ? appState.programs[currentIdx] : null;

    final hasNext = currentIdx + 1 < totalPrograms;
    final nextProg = hasNext ? appState.programs[currentIdx + 1] : null;

    final hasPrev = currentIdx - 1 >= 0;
    final prevProg = hasPrev ? appState.programs[currentIdx - 1] : null;

    final seconds = appState.liveTimerRemainingSeconds;
    final minsStr = (seconds ~/ 60).toString().padLeft(2, '0');
    final secsStr = (seconds % 60).toString().padLeft(2, '0');
    final isOvertime = seconds <= 0;

    final scheduleSlots = appState.scheduleSlots;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF090D16) : const Color(0xFFF1F5F9),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 950;

          return SingleChildScrollView(
            padding: EdgeInsets.all(_isFullscreenMode ? 16.0 : 24.0),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- 1. TOP LIVE STAGE AUDITORIUM CONTROL BAR ---
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 16,
                  runSpacing: 12,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Glowing Live Badge
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: appState.isTimerRunning ? Colors.redAccent : Colors.amber.shade800,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: (appState.isTimerRunning ? Colors.redAccent : Colors.amber.shade800).withAlpha(120),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                appState.isTimerRunning ? Icons.podcasts_rounded : Icons.pause_circle_filled_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                appState.isTimerRunning ? 'LIVE ON STAGE A' : 'STAGE TIMER PAUSED',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 12,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Auditorium Live Controller',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppColors.textLight : AppColors.textDark,
                              ),
                            ),
                            Text(
                              hasCurrent
                                  ? 'Program #${currentIdx + 1} of $totalPrograms  •  ${currentProg?.stage ?? 'Main Stage'}  •  Auto-Schedule Synced ✨'
                                  : 'No active program loaded on stage',
                              style: GoogleFonts.poppins(
                                fontSize: 11.5,
                                color: isDark ? AppColors.subtextLight : AppColors.subtextDark,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      children: [
                        // Schedule Sync Badge Button
                        OutlinedButton.icon(
                          onPressed: () {
                            appState.generateAutoSchedule();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('✨ Live stage timeline resynced with Schedule Rules!'),
                                backgroundColor: AppColors.success,
                              ),
                            );
                          },
                          icon: const Icon(Icons.sync_rounded, size: 16),
                          label: Text('Sync Auto-Schedule', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 11.5)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary, width: 1.5),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),

                        // Auditorium Display Mode Button
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _isFullscreenMode = !_isFullscreenMode;
                            });
                          },
                          icon: Icon(_isFullscreenMode ? Icons.fullscreen_exit_rounded : Icons.fullscreen_rounded, size: 18),
                          label: Text(_isFullscreenMode ? 'Exit Display Mode' : 'Auditorium Display Mode', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 3,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // --- 2. UNIFIED RESPONSIVE LIVE WORKSPACE (HERO CONSOLE + TIMELINE QUEUE) ---
                Flex(
                  direction: isNarrow ? Axis.vertical : Axis.horizontal,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // LEFT / MAIN COLUMN: HERO LIVE CONSOLE & STAGE CONTROLS
                    Expanded(
                      flex: isNarrow ? 0 : 6,
                      child: Column(
                        children: [
                          // HERO STAGE CARD
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF0F172A) : Colors.white,
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                color: appState.isTimerRunning
                                    ? AppColors.primary.withAlpha(150)
                                    : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                                width: appState.isTimerRunning ? 2 : 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: (appState.isTimerRunning ? AppColors.primary : Colors.black).withAlpha(30),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                if (currentProg != null) ...[
                                  Wrap(
                                    alignment: WrapAlignment.spaceBetween,
                                    crossAxisAlignment: WrapCrossAlignment.start,
                                    spacing: 20,
                                    runSpacing: 16,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          // Student Avatar Circle
                                          Container(
                                            width: 84,
                                            height: 84,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: AppColors.primary.withAlpha(30),
                                              border: Border.all(color: AppColors.primary.withAlpha(120), width: 3),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: AppColors.primary.withAlpha(80),
                                                  blurRadius: 14,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ],
                                            ),
                                            child: Center(
                                              child: Text(
                                                currentProg.studentName.isNotEmpty ? currentProg.studentName[0].toUpperCase() : 'S',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 36,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.primary,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 18),

                                          // Performer Details
                                          ConstrainedBox(
                                            constraints: const BoxConstraints(maxWidth: 300),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Wrap(
                                                  spacing: 8,
                                                  runSpacing: 4,
                                                  children: [
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                      decoration: BoxDecoration(
                                                        color: AppColors.primary.withAlpha(30),
                                                        borderRadius: BorderRadius.circular(8),
                                                        border: Border.all(color: AppColors.primary.withAlpha(80)),
                                                      ),
                                                      child: Text(
                                                        '${currentProg.category}  •  ${currentProg.studentClass}',
                                                        style: GoogleFonts.poppins(
                                                          fontWeight: FontWeight.bold,
                                                          color: AppColors.primary,
                                                          fontSize: 11.5,
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                      decoration: BoxDecoration(
                                                        color: AppColors.secondary.withAlpha(30),
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                      child: Text(
                                                        'ID: ${currentProg.id}',
                                                        style: GoogleFonts.poppins(
                                                          fontWeight: FontWeight.bold,
                                                          color: AppColors.secondary,
                                                          fontSize: 11.5,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  currentProg.studentName,
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 26,
                                                    fontWeight: FontWeight.bold,
                                                    color: isDark ? AppColors.textLight : AppColors.textDark,
                                                    letterSpacing: -0.5,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  'Item: ${currentProg.item}',
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 17,
                                                    fontWeight: FontWeight.w600,
                                                    color: AppColors.secondary,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 6),
                                                Row(
                                                  children: [
                                                    const Icon(Icons.school_rounded, size: 14, color: AppColors.primary),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      'Teacher: ${currentProg.teacher}',
                                                      style: GoogleFonts.poppins(fontSize: 11.5, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
                                                    ),
                                                    const SizedBox(width: 14),
                                                    const Icon(Icons.location_on_rounded, size: 14, color: AppColors.warning),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      'Stage: ${currentProg.stage}',
                                                      style: GoogleFonts.poppins(fontSize: 11.5, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),

                                      // BIG DIGITAL STAGE COUNTDOWN TIMER
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                        decoration: BoxDecoration(
                                          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                                          borderRadius: BorderRadius.circular(22),
                                          border: Border.all(
                                            color: isOvertime
                                                ? Colors.redAccent
                                                : (appState.isTimerRunning ? AppColors.primary : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0))),
                                            width: 2,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: (isOvertime ? Colors.redAccent : AppColors.primary).withAlpha(40),
                                              blurRadius: 14,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              '$minsStr:$secsStr',
                                              style: GoogleFonts.poppins(
                                                fontSize: 44,
                                                fontWeight: FontWeight.bold,
                                                color: isOvertime ? Colors.redAccent : AppColors.primary,
                                                letterSpacing: 2,
                                              ),
                                            ),
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  width: 8,
                                                  height: 8,
                                                  decoration: BoxDecoration(
                                                    color: appState.isTimerRunning ? AppColors.success : Colors.amber,
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  appState.isTimerRunning ? 'LIVE COUNTDOWN' : 'TIMER PAUSED',
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 10.5,
                                                    fontWeight: FontWeight.bold,
                                                    color: isDark ? AppColors.subtextLight : AppColors.subtextDark,
                                                    letterSpacing: 1,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 24),
                                  const Divider(height: 1),
                                  const SizedBox(height: 20),

                                  // STAGE OPERATOR ACTION BUTTONS ROW
                                  Wrap(
                                    alignment: WrapAlignment.center,
                                    spacing: 12,
                                    runSpacing: 10,
                                    children: [
                                      // PREVIOUS ITEM BUTTON
                                      OutlinedButton.icon(
                                        onPressed: hasPrev ? () => appState.prevLiveProgram() : null,
                                        icon: const Icon(Icons.skip_previous_rounded, size: 18),
                                        label: Text('⏮️ Previous', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12.5)),
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        ),
                                      ),

                                      // PLAY / PAUSE TIMER BUTTON
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          if (appState.isTimerRunning) {
                                            appState.pauseLiveTimer();
                                          } else {
                                            appState.startLiveTimer();
                                          }
                                        },
                                        icon: Icon(appState.isTimerRunning ? Icons.pause_rounded : Icons.play_arrow_rounded, size: 20),
                                        label: Text(
                                          appState.isTimerRunning ? 'Pause Timer' : 'Resume Timer',
                                          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: appState.isTimerRunning ? AppColors.warning : AppColors.primary,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          elevation: 3,
                                        ),
                                      ),

                                      // MARK COMPLETE & CALL NEXT BUTTON
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          appState.updateProgramStatus(currentProg.id, ProgramStatus.completed);
                                          if (hasNext) {
                                            appState.nextLiveProgram();
                                          }
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('✅ Program completed! Next item loaded on stage.'),
                                              backgroundColor: AppColors.success,
                                            ),
                                          );
                                        },
                                        icon: const Icon(Icons.check_circle_rounded, size: 20),
                                        label: Text('✅ Mark Complete & Next', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13)),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.success,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          elevation: 3,
                                        ),
                                      ),

                                      // STAGE SETUP BUFFER BUTTON (60s)
                                      OutlinedButton.icon(
                                        onPressed: () {
                                          _startStageBuffer(appState, 60);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('⏱️ Stage setup 60s buffer started!'),
                                              backgroundColor: AppColors.warning,
                                            ),
                                          );
                                        },
                                        icon: const Icon(Icons.timer_outlined, size: 18, color: AppColors.warning),
                                        label: Text('⏱️ Setup Buffer (60s)', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12.5, color: AppColors.warning)),
                                        style: OutlinedButton.styleFrom(
                                          side: const BorderSide(color: AppColors.warning, width: 1.5),
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ] else ...[
                                  Padding(
                                    padding: const EdgeInsets.all(32.0),
                                    child: Column(
                                      children: [
                                        const Icon(Icons.desktop_access_disabled_rounded, size: 48, color: Colors.grey),
                                        const SizedBox(height: 12),
                                        Text(
                                          'No Program Loaded on Stage',
                                          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Select an item from the live timeline queue on the right to start auditorium presentation.',
                                          style: GoogleFonts.poppins(fontSize: 11.5, color: Colors.grey),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // UP NEXT & PREVIOUS ITEM PREVIEW CARDS ROW
                          Row(
                            children: [
                              // PREVIOUS ITEM PREVIEW CARD
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(18),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF0F172A) : Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 16),
                                          const SizedBox(width: 6),
                                          Text(
                                            'PREVIOUS ITEM',
                                            style: GoogleFonts.poppins(
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.success,
                                              letterSpacing: 0.8,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      if (prevProg != null) ...[
                                        Text(
                                          prevProg.studentName,
                                          style: GoogleFonts.poppins(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: isDark ? AppColors.textLight : AppColors.textDark,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          'Item: ${prevProg.item}',
                                          style: GoogleFonts.poppins(fontSize: 11.5, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ] else ...[
                                        Text(
                                          'First Program of Festival',
                                          style: GoogleFonts.poppins(fontSize: 11.5, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(width: 14),

                              // NEXT UP ON DECK PREVIEW CARD
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(18),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF0F172A) : Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: AppColors.primary.withAlpha(100), width: 1.5),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primary.withAlpha(20),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.arrow_circle_right_rounded, color: AppColors.primary, size: 16),
                                          const SizedBox(width: 6),
                                          Text(
                                            'NEXT UP ON DECK',
                                            style: GoogleFonts.poppins(
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.primary,
                                              letterSpacing: 0.8,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      if (nextProg != null) ...[
                                        Text(
                                          nextProg.studentName,
                                          style: GoogleFonts.poppins(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: isDark ? AppColors.textLight : AppColors.textDark,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          'Item: ${nextProg.item} (${nextProg.studentClass})',
                                          style: GoogleFonts.poppins(fontSize: 11.5, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ] else ...[
                                        Text(
                                          'End of Festival Schedule',
                                          style: GoogleFonts.poppins(fontSize: 11.5, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    if (!isNarrow) const SizedBox(width: 20),
                    if (isNarrow) const SizedBox(height: 20),

                    // RIGHT COLUMN: LIVE AUTO-SCHEDULED TIMELINE QUEUE PANEL ⭐⭐⭐
                    Expanded(
                      flex: isNarrow ? 0 : 4,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0F172A) : Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                        ),
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
                                      child: const Icon(Icons.format_list_bulleted_rounded, color: AppColors.primary, size: 18),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Live Schedule Timeline',
                                      style: GoogleFonts.poppins(
                                        fontSize: 15,
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
                                  child: Text(
                                    '${scheduleSlots.length} Slots',
                                    style: GoogleFonts.poppins(fontSize: 10.5, fontWeight: FontWeight.bold, color: AppColors.primary),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 14),
                            const Divider(height: 1),
                            const SizedBox(height: 14),

                            if (scheduleSlots.isEmpty)
                              Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Center(
                                  child: Text(
                                    'No schedule slots generated yet.\nGo to Schedule Screen to generate rules.',
                                    style: GoogleFonts.poppins(fontSize: 11.5, color: Colors.grey),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              )
                            else
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: scheduleSlots.length,
                                itemBuilder: (context, idx) {
                                  final slot = scheduleSlots[idx];
                                  final isPrayer = slot.type == SlotType.prayer;
                                  final isBreak = slot.type == SlotType.breakSlot;

                                  Color slotColor = AppColors.primary;
                                  if (isPrayer) slotColor = const Color(0xFF10B981);
                                  if (isBreak) slotColor = const Color(0xFFF59E0B);

                                  final isCurrentLive = slot.program != null && slot.program!.status == ProgramStatus.live;

                                  return CustomPaint(
                                    painter: _LiveStepperLinePainter(color: slotColor, isLast: idx == scheduleSlots.length - 1),
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 18),
                                      child: Container(
                                        margin: const EdgeInsets.only(bottom: 10),
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                                        decoration: BoxDecoration(
                                          color: isCurrentLive
                                              ? AppColors.primary.withAlpha(25)
                                              : (isPrayer
                                                  ? const Color(0xFF10B981).withAlpha(16)
                                                  : (isBreak
                                                      ? const Color(0xFFF59E0B).withAlpha(16)
                                                      : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC)))),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: isCurrentLive
                                                ? AppColors.primary
                                                : (isPrayer
                                                    ? const Color(0xFF10B981).withAlpha(70)
                                                    : (isBreak
                                                        ? const Color(0xFFF59E0B).withAlpha(70)
                                                        : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)))),
                                            width: isCurrentLive ? 1.5 : 1,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                                        decoration: BoxDecoration(
                                                          color: slotColor,
                                                          borderRadius: BorderRadius.circular(6),
                                                        ),
                                                        child: Text(
                                                          '${slot.startTime} - ${slot.endTime}',
                                                          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 9.5),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Expanded(
                                                        child: Text(
                                                          slot.title,
                                                          style: GoogleFonts.poppins(
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 11.5,
                                                            color: isDark ? AppColors.textLight : AppColors.textDark,
                                                          ),
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  if (slot.program != null) ...[
                                                    const SizedBox(height: 3),
                                                    Text(
                                                      '${slot.program!.studentName} • Class ${slot.program!.studentClass}',
                                                      style: GoogleFonts.poppins(fontSize: 10, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ] else if (isPrayer || isBreak) ...[
                                                    const SizedBox(height: 3),
                                                    Text(
                                                      isPrayer ? '🕌 Prayer Pause' : '☕ Refreshment Break',
                                                      style: GoogleFonts.poppins(fontSize: 10, fontStyle: FontStyle.italic, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ),

                                            if (slot.program != null) ...[
                                              InkWell(
                                                onTap: () {
                                                  final targetIdx = appState.programs.indexWhere((p) => p.id == slot.program!.id);
                                                  if (targetIdx >= 0) {
                                                    appState.startProgramLiveInFirestore(slot.program!.id, appState.madrasaId);
                                                    appState.updateProgramStatus(slot.program!.id, ProgramStatus.live);
                                                  }
                                                },
                                                borderRadius: BorderRadius.circular(8),
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                                  decoration: BoxDecoration(
                                                    color: isCurrentLive ? AppColors.success : AppColors.primary.withAlpha(25),
                                                    borderRadius: BorderRadius.circular(8),
                                                    border: Border.all(color: isCurrentLive ? AppColors.success : AppColors.primary),
                                                  ),
                                                  child: Text(
                                                    isCurrentLive ? '🔴 LIVE' : 'Call Live 🔴',
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 9.5,
                                                      fontWeight: FontWeight.bold,
                                                      color: isCurrentLive ? Colors.white : AppColors.primary,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _LiveStepperLinePainter extends CustomPainter {
  final Color color;
  final bool isLast;

  _LiveStepperLinePainter({required this.color, required this.isLast});

  @override
  void paint(Canvas canvas, Size size) {
    const nodeY = 18.0;
    const nodeX = 6.0;

    if (!isLast) {
      final linePaint = Paint()
        ..color = color.withAlpha(60)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      canvas.drawLine(const Offset(nodeX, nodeY), Offset(nodeX, size.height), linePaint);
    }

    final circlePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(nodeX, nodeY), 5, circlePaint);

    final borderPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(const Offset(nodeX, nodeY), 5, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _LiveStepperLinePainter oldDelegate) =>
      color != oldDelegate.color || isLast != oldDelegate.isLast;
}
