import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/providers/app_state.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/glass_card.dart';

class LiveStageScreen extends StatelessWidget {
  const LiveStageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDark = appState.isDarkMode;

    final currentIdx = appState.liveStageProgramIndex;
    final hasCurrent = currentIdx >= 0 && currentIdx < appState.programs.length;
    final currentProg = hasCurrent ? appState.programs[currentIdx] : null;

    final hasNext = currentIdx + 1 < appState.programs.length;
    final nextProg = hasNext ? appState.programs[currentIdx + 1] : null;

    final hasPrev = currentIdx - 1 >= 0;
    final prevProg = hasPrev ? appState.programs[currentIdx - 1] : null;

    final seconds = appState.liveTimerRemainingSeconds;
    final minsStr = (seconds ~/ 60).toString().padLeft(2, '0');
    final secsStr = (seconds % 60).toString().padLeft(2, '0');

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF090D16) : const Color(0xFFF1F5F9),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          children: [
            // Top Stage Status Bar
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 16,
              runSpacing: 12,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(color: AppColors.error.withAlpha(100), blurRadius: 12),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.podcasts_rounded, color: Colors.white, size: 18),
                          const SizedBox(width: 8),
                          Text('LIVE ON STAGE A', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12, letterSpacing: 1)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      'LED Auditorium Display Mode',
                      style: GoogleFonts.poppins(fontSize: 14, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.fullscreen_rounded),
                  label: const Text('Toggle Fullscreen Display'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // Large Hero Display - Current Performing Program
            GlassCard(
              borderRadius: 32,
              padding: const EdgeInsets.all(36),
              customBgColor: isDark ? AppColors.cardDark.withAlpha(240) : Colors.white,
              child: Column(
                children: [
                  if (currentProg != null) ...[
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.start,
                      spacing: 28,
                      runSpacing: 24,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Participant Large Avatar Photo
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: AppColors.primary.withAlpha(40),
                              backgroundImage: NetworkImage(currentProg.studentPhoto),
                              child: Text(
                                currentProg.studentName.isNotEmpty ? currentProg.studentName[0] : 'S',
                                style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withAlpha(30),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '${currentProg.category}  •  ${currentProg.studentClass}',
                                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 13),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  currentProg.studentName,
                                  style: GoogleFonts.poppins(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? AppColors.textLight : AppColors.textDark,
                                  ),
                                ),
                                Text(
                                  'Item: ${currentProg.item}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.secondary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Teacher: ${currentProg.teacher}  •  Stage: ${currentProg.stage}',
                                  style: GoogleFonts.poppins(fontSize: 14, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
                                ),
                              ],
                            ),
                          ],
                        ),

                        // Big Live Digital Countdown Timer
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: AppColors.primary.withAlpha(80), width: 2),
                          ),
                          child: Column(
                            children: [
                              Text(
                                '$minsStr:$secsStr',
                                style: GoogleFonts.poppins(
                                  fontSize: 44,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                  letterSpacing: 2,
                                ),
                              ),
                              Text(
                                'REMAINING TIME',
                                style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.subtextDark, letterSpacing: 1),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // Stage Controls Button Row
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 16,
                      runSpacing: 12,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => appState.prevLiveProgram(),
                          icon: const Icon(Icons.skip_previous_rounded),
                          label: const Text('Previous Item'),
                          style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16)),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            if (appState.isTimerRunning) {
                              appState.pauseLiveTimer();
                            } else {
                              appState.startLiveTimer();
                            }
                          },
                          icon: Icon(appState.isTimerRunning ? Icons.pause_rounded : Icons.play_arrow_rounded),
                          label: Text(appState.isTimerRunning ? 'Pause Timer' : 'Resume Timer'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: appState.isTimerRunning ? AppColors.warning : AppColors.primary,
                            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => appState.nextLiveProgram(),
                          icon: const Icon(Icons.skip_next_rounded),
                          label: const Text('Next Program Up'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondary,
                            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                          ),
                        ),
                      ],
                    ),
                  ] else
                    const Text('No current live program.'),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Next & Previous Preview Row
            Row(
              children: [
                // Up Next Preview
                Expanded(
                  child: GlassCard(
                    borderRadius: 24,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('NEXT PROGRAM UP', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary, letterSpacing: 1)),
                        const SizedBox(height: 12),
                        if (nextProg != null) ...[
                          Text(nextProg.studentName, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? AppColors.textLight : AppColors.textDark)),
                          Text('Item: ${nextProg.item} (${nextProg.studentClass})', style: GoogleFonts.poppins(fontSize: 14, color: AppColors.subtextDark)),
                        ] else
                          Text('End of Schedule', style: GoogleFonts.poppins(fontSize: 14, color: AppColors.subtextDark)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                // Previous Program Summary
                Expanded(
                  child: GlassCard(
                    borderRadius: 24,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('PREVIOUS PROGRAM', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.success, letterSpacing: 1)),
                        const SizedBox(height: 12),
                        if (prevProg != null) ...[
                          Text(prevProg.studentName, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? AppColors.textLight : AppColors.textDark)),
                          Text('Item: ${prevProg.item} (Finished)', style: GoogleFonts.poppins(fontSize: 14, color: AppColors.subtextDark)),
                        ] else
                          Text('First Item of the day', style: GoogleFonts.poppins(fontSize: 14, color: AppColors.subtextDark)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
