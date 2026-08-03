import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/models/models.dart';
import '../../core/providers/app_state.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/glass_card.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDark = appState.isDarkMode;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Title & Tab Switcher
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
                      'Program Schedule & Timeline',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.textLight : AppColors.textDark,
                      ),
                    ),
                    Text(
                      'Automatic timing calculator & drag-and-drop manual timeline reordering.',
                      style: GoogleFonts.poppins(fontSize: 13, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    indicator: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: isDark ? AppColors.subtextLight : AppColors.subtextDark,
                    labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13),
                    tabs: const [
                      Tab(text: '⚡ Automatic Generator'),
                      Tab(text: '✋ Manual Reorder Timeline'),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            SizedBox(
              height: 780,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildAutoGeneratorTab(context, appState, isDark),
                  _buildManualScheduleTab(context, appState, isDark),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAutoGeneratorTab(BuildContext context, AppState appState, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column: Configuration Controls Panel
        Expanded(
          flex: 4,
          child: GlassCard(
            borderRadius: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.tune_rounded, color: AppColors.primary, size: 22),
                    const SizedBox(width: 10),
                    Text(
                      'Schedule Parameters',
                      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? AppColors.textLight : AppColors.textDark),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                _buildParamTile(
                  context,
                  title: 'Festival Start Time',
                  value: appState.defaultStartTime.format(context),
                  icon: Icons.access_time_rounded,
                  isDark: isDark,
                  onTap: () async {
                    TimeOfDay? picked = await showTimePicker(context: context, initialTime: appState.defaultStartTime);
                    if (picked != null) {
                      appState.defaultStartTime = picked;
                      appState.generateAutoSchedule();
                    }
                  },
                ),
                const SizedBox(height: 14),

                _buildParamTile(
                  context,
                  title: 'Dhuhr Prayer & Lunch Break',
                  value: '${appState.dhuhrPrayerTime.format(context)} (45 mins)',
                  icon: Icons.mosque_rounded,
                  isDark: isDark,
                  onTap: () async {
                    TimeOfDay? picked = await showTimePicker(context: context, initialTime: appState.dhuhrPrayerTime);
                    if (picked != null) {
                      appState.dhuhrPrayerTime = picked;
                      appState.generateAutoSchedule();
                    }
                  },
                ),
                const SizedBox(height: 14),

                _buildParamTile(
                  context,
                  title: 'Asr Prayer Break',
                  value: '${appState.asrPrayerTime.format(context)} (30 mins)',
                  icon: Icons.mosque_outlined,
                  isDark: isDark,
                  onTap: () async {
                    TimeOfDay? picked = await showTimePicker(context: context, initialTime: appState.asrPrayerTime);
                    if (picked != null) {
                      appState.asrPrayerTime = picked;
                      appState.generateAutoSchedule();
                    }
                  },
                ),

                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      appState.generateAutoSchedule();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Schedule recalculated and prayer breaks injected!'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    },
                    icon: const Icon(Icons.bolt_rounded),
                    label: const Text('Recalculate Schedule Now'),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 24),

        // Right Column: Generated Timeline List
        Expanded(
          flex: 6,
          child: GlassCard(
            borderRadius: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Generated Timeline Slots',
                      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? AppColors.textLight : AppColors.textDark),
                    ),
                    Text(
                      '${appState.scheduleSlots.length} Slots',
                      style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Expanded(
                  child: ListView.separated(
                    itemCount: appState.scheduleSlots.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (context, idx) {
                      final slot = appState.scheduleSlots[idx];
                      final isPrayer = slot.type == SlotType.prayer;
                      final isBreak = slot.type == SlotType.breakSlot;

                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isPrayer
                              ? AppColors.accent.withAlpha(25)
                              : isBreak
                                  ? AppColors.warning.withAlpha(20)
                                  : (isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isPrayer
                                ? AppColors.accent.withAlpha(80)
                                : isBreak
                                    ? AppColors.warning.withAlpha(80)
                                    : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: isPrayer ? AppColors.accent : AppColors.primary,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${slot.startTime} - ${slot.endTime}',
                                style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                slot.title,
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: isDark ? AppColors.textLight : AppColors.textDark,
                                ),
                              ),
                            ),
                            if (slot.program != null)
                              Text(
                                '${slot.program!.studentName} (${slot.program!.studentClass})',
                                style: GoogleFonts.poppins(fontSize: 12, color: AppColors.subtextDark),
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
        ),
      ],
    );
  }

  Widget _buildManualScheduleTab(BuildContext context, AppState appState, bool isDark) {
    return GlassCard(
      borderRadius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Drag to Reorder Programs',
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? AppColors.textLight : AppColors.textDark),
              ),
              Text('Hold drag handles on right to move items up or down', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.subtextDark)),
            ],
          ),
          const SizedBox(height: 16),

          Expanded(
            child: ReorderableListView.builder(
              itemCount: appState.programs.length,
              onReorderItem: (oldIndex, newIndex) => appState.reorderProgram(oldIndex, newIndex),
              itemBuilder: (context, idx) {
                final prog = appState.programs[idx];
                return Container(
                  key: ValueKey(prog.id),
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(30),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('#${idx + 1}', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 12)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(prog.item, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? AppColors.textLight : AppColors.textDark)),
                            Text('${prog.studentName} • ${prog.studentClass} • ${prog.durationMinutes} mins', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.subtextDark)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_upward_rounded, size: 18),
                        onPressed: idx > 0 ? () => appState.reorderProgram(idx, idx - 1) : null,
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_downward_rounded, size: 18),
                        onPressed: idx < appState.programs.length - 1 ? () => appState.reorderProgram(idx, idx + 2) : null,
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.drag_handle_rounded, color: AppColors.subtextDark),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParamTile(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 20),
                const SizedBox(width: 12),
                Text(title, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? AppColors.textLight : AppColors.textDark)),
              ],
            ),
            Row(
              children: [
                Text(value, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary)),
                const SizedBox(width: 6),
                const Icon(Icons.edit_outlined, size: 16, color: AppColors.subtextDark),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
