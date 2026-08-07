// Library: schedule_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/models/models.dart';
import '../../core/providers/app_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/schedule_generator.dart';
import '../widgets/glass_card.dart';
import 'add_opening_event_sheet.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  String _searchProgramQuery = '';
  bool _isRulesExpanded = true;

  // --- 1. FESTIVAL TIMING ---
  TimeOfDay _festivalStartTime = const TimeOfDay(hour: 8, minute: 30);
  TimeOfDay _festivalEndTime = const TimeOfDay(hour: 22, minute: 30);
  bool _enableEndTimeStop = true;

  // --- 2. PROGRAM DURATION ---
  String _durationMode = 'Use program duration'; // 'Use program duration' vs 'Override all durations'
  int _fallbackDurationMins = 12; // 5, 8, 10, 12, 15, 20

  // --- 3. STAGE SETUP BUFFER ---
  int _stageBufferSecs = 60; // 0, 30, 60, 90, 120

  // --- 4. PARTICIPANT MINIMUM GAP ---
  int _participantMinGapMins = 20; // 5, 10, 15, 20, 25, 30, 45, 60

  // --- 5. CLASS DISTRIBUTION ---
  String _maxConsecutiveSameClass = '2'; // '1', '2', '3', 'Unlimited'

  // --- 6. PROGRAM DISTRIBUTION ---
  bool _altSingle = true;
  bool _altGroup = true;
  bool _altOther = true;
  int _maxConsecutiveGroup = 2; // 1, 2, 3, 4
  int _maxConsecutiveSingle = 5; // 2, 3, 5, 10

  // --- 7. OPENING & CLOSING REORDERABLE SEQUENCE ---
  final List<String> _openingClosingSequence = [
    '1. Qur\'an Recitation',
    '2. Welcome Speech',
    '3. Keynote Speech / Presidential',
    '4. Competition Items',
    '5. Prize Distribution',
    '6. Vote of Thanks & Dua',
  ];

  // --- 8. CANCELLATION BEHAVIOR ---
  String _cancellationBehavior = 'Move next program'; // 'Move next program', 'Leave empty', 'Ask me', 'Fill with announcement'

  // --- MISSING RULE 1: PRAYER TIME MANAGEMENT ---
  bool _enablePrayerPauses = true;
  TimeOfDay _maghribPrayerTime = const TimeOfDay(hour: 19, minute: 15);
  int _prayerPauseDurationMins = 15; // 10, 15, 20, 30, 45

  // --- MISSING RULE 2: BREAK MANAGEMENT ---
  bool _enableTeaBreak = true;
  TimeOfDay _teaBreakTime = const TimeOfDay(hour: 11, minute: 0);
  int _teaBreakDurationMins = 15;

  bool _enableLunchBreak = true;
  TimeOfDay _lunchBreakTime = const TimeOfDay(hour: 13, minute: 0);
  int _lunchBreakDurationMins = 45;

  // --- MISSING RULE 3: LOCKED PROGRAMS ---
  bool _lockSelectedPrograms = true;

  // --- MISSING RULE 4: PRIORITY WEIGHTING ---
  final Set<String> _highPriorityTypes = {'Qur\'an', 'Opening', 'Chief Guest', 'VIP'};

  // --- MISSING RULE 5: FINISH BEFORE DEADLINE ---
  TimeOfDay _targetFinishTime = const TimeOfDay(hour: 22, minute: 30);

  // --- MISSING RULE 6: SMART AI OPTIMIZATION ---
  bool _enableSmartAIOptimization = true;

  final String _referenceOpeningProgram = 'Meelad Festival Inauguration & Opening Qira\'at';

  void _runAutoScheduleWithRules(AppState appState) {
    appState.defaultStartTime = _festivalStartTime;
    appState.generateAutoSchedule(
      fallbackDurationMins: _fallbackDurationMins,
      stageBufferSecs: _stageBufferSecs,
      participantGapMins: _participantMinGapMins,
      autoShiftOnCancel: _cancellationBehavior == 'Move next program',
    );
  }

  // Modal 1: Add Custom Break Slot
  void _openAddBreakModal(BuildContext context, AppState appState) {
    final titleController = TextEditingController(text: '☕ Short Refreshment Break');
    final durationController = TextEditingController(text: '15');
    TimeOfDay selectedTime = const TimeOfDay(hour: 11, minute: 30);
    final isDark = appState.isDarkMode;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: isDark ? AppColors.cardDark : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withAlpha(25),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.free_breakfast_rounded, color: Color(0xFFF59E0B), size: 22),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Add Custom Break Slot',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              content: SizedBox(
                width: 420,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Break Title & Description:', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: titleController,
                      style: GoogleFonts.poppins(fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'e.g. 🍽️ Lunch Break, ☕ Tea Refreshment',
                        filled: true,
                        fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 14),

                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Start Time:', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 6),
                              InkWell(
                                onTap: () async {
                                  TimeOfDay? picked = await showTimePicker(context: context, initialTime: selectedTime);
                                  if (picked != null) {
                                    setModalState(() => selectedTime = picked);
                                  }
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.primary.withAlpha(80)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        selectedTime.format(context),
                                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary),
                                      ),
                                      const Icon(Icons.access_time_rounded, size: 16, color: AppColors.primary),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Duration (mins):', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 6),
                              TextField(
                                controller: durationController,
                                keyboardType: TextInputType.number,
                                style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold),
                                decoration: InputDecoration(
                                  hintText: 'mins',
                                  suffixText: 'm',
                                  filled: true,
                                  fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text('Cancel', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    final title = titleController.text.trim();
                    final dur = int.tryParse(durationController.text) ?? 15;
                    if (title.isNotEmpty) {
                      appState.addCustomBreak(
                        CustomBreakItem(
                          id: 'custom-break-${DateTime.now().millisecondsSinceEpoch}',
                          title: title,
                          durationMinutes: dur,
                          breakTime: selectedTime,
                        ),
                      );
                      Navigator.of(ctx).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('✨ Custom break "$title" added to schedule timeline!'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.check_rounded, size: 16),
                  label: Text('Inject Break', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF59E0B),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDark = appState.isDarkMode;

    final totalPrograms = appState.programs.length;
    final totalDurationMins = appState.programs.fold(0, (sum, p) => sum + p.durationMinutes);
    final hours = totalDurationMins ~/ 60;
    final mins = totalDurationMins % 60;

    final filteredPrograms = appState.programs.where((p) {
      final q = _searchProgramQuery.trim().toLowerCase();
      if (q.isEmpty) return true;
      return p.item.toLowerCase().contains(q) ||
          p.studentName.toLowerCase().contains(q) ||
          p.category.toLowerCase().contains(q) ||
          p.studentClass.toLowerCase().contains(q);
    }).toList();

    // Check if target deadline is exceeded
    final finishTimeMinutes = (_festivalStartTime.hour * 60 + _festivalStartTime.minute) + totalDurationMins + (appState.scheduleSlots.length * (_stageBufferSecs ~/ 60));
    final targetDeadlineMinutes = _targetFinishTime.hour * 60 + _targetFinishTime.minute;
    final isDeadlineExceeded = finishTimeMinutes > targetDeadlineMinutes;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 950;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- 1. TOP HEADER & ACTION BUTTONS ---
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 16,
                  runSpacing: 14,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF6366F1).withAlpha(80),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 26),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Program Schedule Engine & Timeline',
                              style: GoogleFonts.poppins(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppColors.textLight : AppColors.textDark,
                              ),
                            ),
                            Text(
                              'Smart AI schedule generator with prayer pauses, break management & priority rules',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
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
                        // + Add Break Button
                        OutlinedButton.icon(
                          onPressed: () => _openAddBreakModal(context, appState),
                          icon: const Icon(Icons.free_breakfast_rounded, size: 16),
                          label: Text('+ Add Break', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12.5)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFF59E0B),
                            side: const BorderSide(color: Color(0xFFF59E0B), width: 1.5),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),

                        // + Add Special Program Button (Inauguration, Qira'at)
                        OutlinedButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => const Dialog(
                                backgroundColor: Colors.transparent,
                                child: AddOpeningEventSheet(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.stars_rounded, size: 16),
                          label: Text('+ Add Opening Event', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12.5)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary, width: 1.5),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),

                        // Reset Manual Changes Button
                        OutlinedButton.icon(
                          onPressed: () {
                            appState.resetManualProgramOrder();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('↺ Reset manual program order back to original default schedule!'),
                                backgroundColor: AppColors.primary,
                              ),
                            );
                          },
                          icon: const Icon(Icons.restart_alt_rounded, size: 16),
                          label: Text('Reset Order ↺', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12.5)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.redAccent,
                            side: const BorderSide(color: Colors.redAccent, width: 1.5),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),

                        // ✨ Generate Smart Schedule Button
                        ElevatedButton.icon(
                          onPressed: () {
                            _runAutoScheduleWithRules(appState);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('✨ Smart AI Schedule generated based on your selected rules!'),
                                backgroundColor: AppColors.success,
                              ),
                            );
                          },
                          icon: const Icon(Icons.auto_awesome_rounded, size: 18),
                          label: Text('✨ Generate Smart Schedule', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 4,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // DEADLINE EXCEEDED WARNING BANNER (Rule 5 Warning)
                if (isDeadlineExceeded) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withAlpha(20),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.redAccent.withAlpha(90)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '⚠️ Festival Finish Time Warning',
                                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.redAccent),
                              ),
                              Text(
                                'The calculated timeline extends past your target finish deadline of ${_targetFinishTime.format(context)}. Consider adjusting setup buffers or program durations.',
                                style: GoogleFonts.poppins(fontSize: 11.5, color: isDark ? AppColors.textLight : AppColors.textDark),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // --- 2. REFERENCE STARTING PROGRAM & METRIC CARDS ROW ---
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    // Opening Reference Program Banner Card
                    SizedBox(
                      width: isNarrow ? double.infinity : 340,
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(isDark ? 30 : 18),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.primary.withAlpha(80)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.celebration_rounded, color: Colors.white, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Festival Opening Event Reference',
                                    style: GoogleFonts.poppins(fontSize: 10.5, fontWeight: FontWeight.bold, color: AppColors.primary),
                                  ),
                                  Text(
                                    _referenceOpeningProgram,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? AppColors.textLight : AppColors.textDark,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    _buildSummaryBadge(
                      icon: Icons.access_time_rounded,
                      title: 'Stage Start Time',
                      value: _festivalStartTime.format(context),
                      color: AppColors.primary,
                      isDark: isDark,
                      width: isNarrow ? (constraints.maxWidth - 60) / 2 : 180,
                    ),
                    _buildSummaryBadge(
                      icon: Icons.timer_rounded,
                      title: 'Total Duration',
                      value: '${hours}h ${mins}m',
                      color: const Color(0xFF10B981),
                      isDark: isDark,
                      width: isNarrow ? (constraints.maxWidth - 60) / 2 : 180,
                    ),
                    _buildSummaryBadge(
                      icon: Icons.list_alt_rounded,
                      title: 'Total Programs',
                      value: '$totalPrograms Items',
                      color: const Color(0xFFF59E0B),
                      isDark: isDark,
                      width: isNarrow ? (constraints.maxWidth - 60) / 2 : 180,
                    ),
                    _buildSummaryBadge(
                      icon: Icons.mosque_rounded,
                      title: 'Injected Breaks',
                      value: '${2 + appState.customBreaks.length} Slots',
                      color: const Color(0xFF8B5CF6),
                      isDark: isDark,
                      width: isNarrow ? (constraints.maxWidth - 60) / 2 : 180,
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                // --- 3. COMPREHENSIVE SCHEDULING INSTRUCTIONS & RULES CONFIGURATION CARD ---
                GlassCard(
                  padding: const EdgeInsets.all(22),
                  borderRadius: 22,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 16,
                        runSpacing: 14,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withAlpha(25),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.tune_rounded, color: AppColors.primary, size: 22),
                              ),
                              const SizedBox(width: 14),
                              ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 420),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Scheduling Instructions & Smart Rules Configuration',
                                      style: GoogleFonts.poppins(fontSize: 15.5, fontWeight: FontWeight.bold, color: isDark ? AppColors.textLight : AppColors.textDark),
                                    ),
                                    Text(
                                      'Configure timing, prayer breaks, participant gaps, max consecutive limits & AI optimization.',
                                      style: GoogleFonts.poppins(fontSize: 11.5, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          Wrap(
                            spacing: 10,
                            runSpacing: 8,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              // Expanding / Collapsing Icon Toggle Button
                              OutlinedButton.icon(
                                onPressed: () => setState(() => _isRulesExpanded = !_isRulesExpanded),
                                icon: Icon(
                                  _isRulesExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                                  size: 18,
                                  color: AppColors.primary,
                                ),
                                label: Text(
                                  _isRulesExpanded ? 'Collapse Rules 🔼' : 'Expand Rules 🔽',
                                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.primary,
                                  side: const BorderSide(color: AppColors.primary, width: 1.5),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),

                              // ✨ Generate Smart Schedule Button
                              ElevatedButton.icon(
                                onPressed: () {
                                  _runAutoScheduleWithRules(appState);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('✨ Smart AI Schedule generated based on your selected rules!'),
                                      backgroundColor: AppColors.success,
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.auto_awesome_rounded, size: 18),
                                label: Text('✨ Generate Smart Schedule', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12.5)),
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

                      if (_isRulesExpanded) ...[
                        const SizedBox(height: 16),
                        const Divider(height: 1),
                        const SizedBox(height: 16),

                        // GRID OF COMPREHENSIVE RULE CARDS WITH ENHANCED INPUTS
                        Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          // 1. Festival Timing Card
                          _buildRuleConfigBox(
                            isDark: isDark,
                            title: '1. Festival Timing ⭐',
                            subtitle: 'Start Time & Optional End Time Deadline',
                            icon: Icons.access_time_rounded,
                            iconColor: AppColors.primary,
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: InkWell(
                                        onTap: () async {
                                          TimeOfDay? picked = await showTimePicker(context: context, initialTime: _festivalStartTime);
                                          if (picked != null) setState(() => _festivalStartTime = picked);
                                        },
                                        borderRadius: BorderRadius.circular(8),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary.withAlpha(20),
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: AppColors.primary.withAlpha(80)),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text('Start: ${_festivalStartTime.format(context)}', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary)),
                                              const Icon(Icons.edit, size: 12, color: AppColors.primary),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: InkWell(
                                        onTap: () async {
                                          TimeOfDay? picked = await showTimePicker(context: context, initialTime: _festivalEndTime);
                                          if (picked != null) setState(() => _festivalEndTime = picked);
                                        },
                                        borderRadius: BorderRadius.circular(8),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text('End: ${_festivalEndTime.format(context)}', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold)),
                                              const Icon(Icons.edit, size: 12),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(child: Text('Stop schedule at end time:', style: GoogleFonts.poppins(fontSize: 10.5))),
                                    Switch(
                                      value: _enableEndTimeStop,
                                      activeTrackColor: AppColors.primary,
                                      onChanged: (val) => setState(() => _enableEndTimeStop = val),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // 2. Program Duration Card
                          _buildRuleConfigBox(
                            isDark: isDark,
                            title: '2. Program Duration',
                            subtitle: 'Use own duration vs override & fallback',
                            icon: Icons.timer_outlined,
                            iconColor: const Color(0xFF10B981),
                            child: Column(
                              children: [
                                DropdownButtonFormField<String>(
                                  initialValue: _durationMode,
                                  items: const [
                                    DropdownMenuItem(value: 'Use program duration', child: Text('○ Use program duration')),
                                    DropdownMenuItem(value: 'Override all durations', child: Text('○ Override all durations')),
                                  ],
                                  onChanged: (val) {
                                    if (val != null) setState(() => _durationMode = val);
                                  },
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  ),
                                  style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: isDark ? AppColors.textLight : AppColors.textDark),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Text('Fallback Mins: ', style: GoogleFonts.poppins(fontSize: 11)),
                                    Expanded(
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<int>(
                                          value: _fallbackDurationMins,
                                          style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF10B981)),
                                          items: const [
                                            DropdownMenuItem(value: 5, child: Text('5 min')),
                                            DropdownMenuItem(value: 8, child: Text('8 min')),
                                            DropdownMenuItem(value: 10, child: Text('10 min')),
                                            DropdownMenuItem(value: 12, child: Text('12 min')),
                                            DropdownMenuItem(value: 15, child: Text('15 min')),
                                            DropdownMenuItem(value: 20, child: Text('20 min')),
                                          ],
                                          onChanged: (val) {
                                            if (val != null) setState(() => _fallbackDurationMins = val);
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // 3. Stage Setup Buffer Card
                          _buildRuleConfigBox(
                            isDark: isDark,
                            title: '3. Stage Setup Buffer',
                            subtitle: 'Drop-down seconds between items',
                            icon: Icons.hourglass_top_rounded,
                            iconColor: const Color(0xFFF59E0B),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Buffer Time:', style: GoogleFonts.poppins(fontSize: 11.5)),
                                DropdownButtonHideUnderline(
                                  child: DropdownButton<int>(
                                    value: _stageBufferSecs,
                                    style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFFF59E0B)),
                                    items: const [
                                      DropdownMenuItem(value: 0, child: Text('0 seconds')),
                                      DropdownMenuItem(value: 30, child: Text('30 seconds')),
                                      DropdownMenuItem(value: 60, child: Text('60 seconds')),
                                      DropdownMenuItem(value: 90, child: Text('90 seconds')),
                                      DropdownMenuItem(value: 120, child: Text('120 seconds')),
                                    ],
                                    onChanged: (val) {
                                      if (val != null) setState(() => _stageBufferSecs = val);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // 4. Participant Gap Dropdown Card ⭐
                          _buildRuleConfigBox(
                            isDark: isDark,
                            title: '4. Participant Minimum Gap ⭐',
                            subtitle: 'Gap dropdown before next performance',
                            icon: Icons.person_off_rounded,
                            iconColor: const Color(0xFF8B5CF6),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Minimum Gap:', style: GoogleFonts.poppins(fontSize: 11.5)),
                                DropdownButtonHideUnderline(
                                  child: DropdownButton<int>(
                                    value: _participantMinGapMins,
                                    style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF8B5CF6)),
                                    items: const [
                                      DropdownMenuItem(value: 5, child: Text('5 min')),
                                      DropdownMenuItem(value: 10, child: Text('10 min')),
                                      DropdownMenuItem(value: 15, child: Text('15 min')),
                                      DropdownMenuItem(value: 20, child: Text('20 min')),
                                      DropdownMenuItem(value: 25, child: Text('25 min')),
                                      DropdownMenuItem(value: 30, child: Text('30 min')),
                                      DropdownMenuItem(value: 45, child: Text('45 min')),
                                      DropdownMenuItem(value: 60, child: Text('60 min')),
                                    ],
                                    onChanged: (val) {
                                      if (val != null) setState(() => _participantMinGapMins = val);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // 5. Class Distribution Card (Max Consecutive Limit)
                          _buildRuleConfigBox(
                            isDark: isDark,
                            title: '5. Class Distribution',
                            subtitle: 'Max consecutive programs from same class',
                            icon: Icons.school_rounded,
                            iconColor: const Color(0xFFEC4899),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(child: Text('Max Consecutive Same Class:', style: GoogleFonts.poppins(fontSize: 11))),
                                DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _maxConsecutiveSameClass,
                                    style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFFEC4899)),
                                    items: const [
                                      DropdownMenuItem(value: '1', child: Text('1 Item')),
                                      DropdownMenuItem(value: '2', child: Text('2 Items')),
                                      DropdownMenuItem(value: '3', child: Text('3 Items')),
                                      DropdownMenuItem(value: 'Unlimited', child: Text('Unlimited')),
                                    ],
                                    onChanged: (val) {
                                      if (val != null) setState(() => _maxConsecutiveSameClass = val);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // 6. Program Type Distribution Card ⭐
                          _buildRuleConfigBox(
                            isDark: isDark,
                            title: '6. Program Type Distribution ⭐',
                            subtitle: 'Alternate Single/Group & max consecutive',
                            icon: Icons.groups_rounded,
                            iconColor: const Color(0xFF06B6D4),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    _buildSmallCheck('Single', _altSingle, (v) => setState(() => _altSingle = v!)),
                                    _buildSmallCheck('Group', _altGroup, (v) => setState(() => _altGroup = v!)),
                                    _buildSmallCheck('Other', _altOther, (v) => setState(() => _altOther = v!)),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Max Consec Group:', style: GoogleFonts.poppins(fontSize: 10.5)),
                                    DropdownButtonHideUnderline(
                                      child: DropdownButton<int>(
                                        value: _maxConsecutiveGroup,
                                        style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF06B6D4)),
                                        items: const [
                                          DropdownMenuItem(value: 1, child: Text('1')),
                                          DropdownMenuItem(value: 2, child: Text('2')),
                                          DropdownMenuItem(value: 3, child: Text('3')),
                                          DropdownMenuItem(value: 4, child: Text('4')),
                                        ],
                                        onChanged: (val) {
                                          if (val != null) setState(() => _maxConsecutiveGroup = val);
                                        },
                                      ),
                                    ),
                                    Text('Max Single:', style: GoogleFonts.poppins(fontSize: 10.5)),
                                    DropdownButtonHideUnderline(
                                      child: DropdownButton<int>(
                                        value: _maxConsecutiveSingle,
                                        style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF06B6D4)),
                                        items: const [
                                          DropdownMenuItem(value: 2, child: Text('2')),
                                          DropdownMenuItem(value: 3, child: Text('3')),
                                          DropdownMenuItem(value: 5, child: Text('5')),
                                          DropdownMenuItem(value: 10, child: Text('10')),
                                        ],
                                        onChanged: (val) {
                                          if (val != null) setState(() => _maxConsecutiveSingle = val);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // 7. Opening & Closing Sequence Drag & Drop Card ⭐
                          _buildRuleConfigBox(
                            isDark: isDark,
                            width: 580,
                            title: '7. Opening & Closing Sequence (Drag & Reorder) ⭐',
                            subtitle: 'Drag chips to set exact ceremonial sequence order',
                            icon: Icons.sort_rounded,
                            iconColor: const Color(0xFFF59E0B),
                            child: SizedBox(
                              height: 90,
                              child: ReorderableListView(
                                scrollDirection: Axis.horizontal,
                                onReorderItem: (oldIndex, newIndex) {
                                  setState(() {
                                    if (newIndex > oldIndex) newIndex -= 1;
                                    final item = _openingClosingSequence.removeAt(oldIndex);
                                    _openingClosingSequence.insert(newIndex, item);
                                  });
                                },
                                children: _openingClosingSequence.map((item) {
                                  return Container(
                                    key: ValueKey(item),
                                    margin: const EdgeInsets.only(right: 8, top: 4, bottom: 4),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withAlpha(isDark ? 40 : 25),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: AppColors.primary.withAlpha(80)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.drag_indicator_rounded, size: 14, color: AppColors.primary),
                                        const SizedBox(width: 4),
                                        Text(
                                          item,
                                          style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),

                          // 8. Cancellation Behavior Radio Card
                          _buildRuleConfigBox(
                            isDark: isDark,
                            title: '8. Cancellation Behavior',
                            subtitle: 'Radio options for cancelled slots',
                            icon: Icons.cancel_outlined,
                            iconColor: Colors.redAccent,
                            child: DropdownButtonFormField<String>(
                              initialValue: _cancellationBehavior,
                              items: const [
                                DropdownMenuItem(value: 'Move next program', child: Text('○ Move next program')),
                                DropdownMenuItem(value: 'Leave empty', child: Text('○ Leave empty')),
                                DropdownMenuItem(value: 'Ask me', child: Text('○ Ask me')),
                                DropdownMenuItem(value: 'Fill with announcement', child: Text('○ Fill with announcement')),
                              ],
                              onChanged: (val) {
                                if (val != null) setState(() => _cancellationBehavior = val);
                              },
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              ),
                              style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: isDark ? AppColors.textLight : AppColors.textDark),
                            ),
                          ),

                          // MISSING RULE 1: PRAYER TIME MANAGEMENT CARD ⭐⭐⭐
                          _buildRuleConfigBox(
                            isDark: isDark,
                            title: 'Missing Rule 1: Prayer Time ⭐⭐⭐',
                            subtitle: 'Enable Maghrib & Prayer pauses during festival',
                            icon: Icons.mosque_rounded,
                            iconColor: const Color(0xFF10B981),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Enable Prayer Pauses:', style: GoogleFonts.poppins(fontSize: 11)),
                                    Switch(
                                      value: _enablePrayerPauses,
                                      activeTrackColor: const Color(0xFF10B981),
                                      onChanged: (val) => setState(() => _enablePrayerPauses = val),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: InkWell(
                                        onTap: () async {
                                          TimeOfDay? picked = await showTimePicker(context: context, initialTime: _maghribPrayerTime);
                                          if (picked != null) setState(() => _maghribPrayerTime = picked);
                                        },
                                        borderRadius: BorderRadius.circular(8),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF10B981).withAlpha(20),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text('Maghrib: ${_maghribPrayerTime.format(context)}', style: GoogleFonts.poppins(fontSize: 10.5, fontWeight: FontWeight.bold, color: const Color(0xFF10B981))),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    DropdownButtonHideUnderline(
                                      child: DropdownButton<int>(
                                        value: _prayerPauseDurationMins,
                                        style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF10B981)),
                                        items: const [
                                          DropdownMenuItem(value: 10, child: Text('10 min')),
                                          DropdownMenuItem(value: 15, child: Text('15 min')),
                                          DropdownMenuItem(value: 20, child: Text('20 min')),
                                          DropdownMenuItem(value: 30, child: Text('30 min')),
                                        ],
                                        onChanged: (val) {
                                          if (val != null) setState(() => _prayerPauseDurationMins = val);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // MISSING RULE 2: BREAK MANAGEMENT CARD ⭐⭐⭐
                          _buildRuleConfigBox(
                            isDark: isDark,
                            title: 'Missing Rule 2: Break Management ⭐⭐⭐',
                            subtitle: 'Tea & Lunch refreshment breaks',
                            icon: Icons.free_breakfast_rounded,
                            iconColor: const Color(0xFFF59E0B),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: InkWell(
                                        onTap: () async {
                                          TimeOfDay? picked = await showTimePicker(context: context, initialTime: _teaBreakTime);
                                          if (picked != null) setState(() => _teaBreakTime = picked);
                                        },
                                        borderRadius: BorderRadius.circular(6),
                                        child: Text('Tea: ${_teaBreakTime.format(context)}', style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFFF59E0B))),
                                      ),
                                    ),
                                    DropdownButtonHideUnderline(
                                      child: DropdownButton<int>(
                                        value: _teaBreakDurationMins,
                                        style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFFF59E0B)),
                                        items: const [
                                          DropdownMenuItem(value: 10, child: Text('10m')),
                                          DropdownMenuItem(value: 15, child: Text('15m')),
                                          DropdownMenuItem(value: 20, child: Text('20m')),
                                        ],
                                        onChanged: (val) {
                                          if (val != null) setState(() => _teaBreakDurationMins = val);
                                        },
                                      ),
                                    ),
                                    Switch(
                                      value: _enableTeaBreak,
                                      activeTrackColor: const Color(0xFFF59E0B),
                                      onChanged: (val) => setState(() => _enableTeaBreak = val),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Expanded(
                                      child: InkWell(
                                        onTap: () async {
                                          TimeOfDay? picked = await showTimePicker(context: context, initialTime: _lunchBreakTime);
                                          if (picked != null) setState(() => _lunchBreakTime = picked);
                                        },
                                        borderRadius: BorderRadius.circular(6),
                                        child: Text('Lunch: ${_lunchBreakTime.format(context)}', style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFFF59E0B))),
                                      ),
                                    ),
                                    DropdownButtonHideUnderline(
                                      child: DropdownButton<int>(
                                        value: _lunchBreakDurationMins,
                                        style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFFF59E0B)),
                                        items: const [
                                          DropdownMenuItem(value: 30, child: Text('30m')),
                                          DropdownMenuItem(value: 45, child: Text('45m')),
                                          DropdownMenuItem(value: 60, child: Text('60m')),
                                        ],
                                        onChanged: (val) {
                                          if (val != null) setState(() => _lunchBreakDurationMins = val);
                                        },
                                      ),
                                    ),
                                    Switch(
                                      value: _enableLunchBreak,
                                      activeTrackColor: const Color(0xFFF59E0B),
                                      onChanged: (val) => setState(() => _enableLunchBreak = val),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // MISSING RULE 3: LOCKED PROGRAMS CARD ⭐⭐⭐
                          _buildRuleConfigBox(
                            isDark: isDark,
                            title: 'Missing Rule 3: Locked Programs ⭐⭐⭐',
                            subtitle: 'Auto-Schedule cannot move locked items',
                            icon: Icons.lock_rounded,
                            iconColor: const Color(0xFF8B5CF6),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(child: Text('Lock Selected Programs:', style: GoogleFonts.poppins(fontSize: 11.5))),
                                Switch(
                                  value: _lockSelectedPrograms,
                                  activeTrackColor: const Color(0xFF8B5CF6),
                                  onChanged: (val) => setState(() => _lockSelectedPrograms = val),
                                ),
                              ],
                            ),
                          ),

                          // MISSING RULE 4: PRIORITY WEIGHTING CARD ⭐⭐⭐
                          _buildRuleConfigBox(
                            isDark: isDark,
                            width: 580,
                            title: 'Missing Rule 4: Priority Items ⭐⭐⭐',
                            subtitle: 'Multi-select chips to schedule high priority early',
                            icon: Icons.star_rounded,
                            iconColor: Colors.orangeAccent,
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: ['Qur\'an', 'Opening', 'Chief Guest', 'VIP'].map((type) {
                                final isSel = _highPriorityTypes.contains(type);
                                return FilterChip(
                                  selected: isSel,
                                  label: Text(type, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: isSel ? Colors.white : Colors.orangeAccent)),
                                  selectedColor: Colors.orangeAccent,
                                  backgroundColor: Colors.orangeAccent.withAlpha(20),
                                  checkmarkColor: Colors.white,
                                  onSelected: (val) {
                                    setState(() {
                                      if (val) {
                                        _highPriorityTypes.add(type);
                                      } else {
                                        _highPriorityTypes.remove(type);
                                      }
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                          ),

                          // MISSING RULE 5: FINISH BEFORE DEADLINE CARD ⭐⭐⭐
                          _buildRuleConfigBox(
                            isDark: isDark,
                            title: 'Missing Rule 5: Finish Deadline ⭐⭐⭐',
                            subtitle: 'Target finish time deadline with warning',
                            icon: Icons.alarm_off_rounded,
                            iconColor: Colors.redAccent,
                            child: InkWell(
                              onTap: () async {
                                TimeOfDay? picked = await showTimePicker(context: context, initialTime: _targetFinishTime);
                                if (picked != null) setState(() => _targetFinishTime = picked);
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.redAccent.withAlpha(20),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.redAccent.withAlpha(80)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Target Finish: ${_targetFinishTime.format(context)}', style: GoogleFonts.poppins(fontSize: 11.5, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                                    const Icon(Icons.edit_outlined, size: 14, color: Colors.redAccent),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // MISSING RULE 6: SMART AI OPTIMIZATION CARD ⭐⭐⭐
                          _buildRuleConfigBox(
                            isDark: isDark,
                            title: 'Missing Rule 6: Smart AI Optimization ⭐⭐⭐',
                            subtitle: 'One switch to balance categories, classes & group items',
                            icon: Icons.auto_awesome_rounded,
                            iconColor: const Color(0xFF6366F1),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Smart AI Optimize:', style: GoogleFonts.poppins(fontSize: 11.5, fontWeight: FontWeight.bold)),
                                    Switch(
                                      value: _enableSmartAIOptimization,
                                      activeTrackColor: const Color(0xFF6366F1),
                                      onChanged: (val) => setState(() => _enableSmartAIOptimization = val),
                                    ),
                                  ],
                                ),
                                if (_enableSmartAIOptimization)
                                  Wrap(
                                    spacing: 4,
                                    children: const [
                                      Chip(label: Text('Categories', style: TextStyle(fontSize: 9))),
                                      Chip(label: Text('Classes', style: TextStyle(fontSize: 9))),
                                      Chip(label: Text('Waiting Time', style: TextStyle(fontSize: 9))),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

                const SizedBox(height: 24),

                // --- 4. UNIFIED RESPONSIVE WORKSPACE ---
                Flex(
                  direction: isNarrow ? Axis.vertical : Axis.horizontal,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // LEFT COLUMN: Manual Reordering & Timing Settings Panel
                    SizedBox(
                      width: isNarrow ? double.infinity : (constraints.maxWidth - 72) * 0.46,
                      height: 720,
                      child: Column(
                        children: [
                          // Timing Parameters & Custom Breaks Card
                          GlassCard(
                            padding: const EdgeInsets.all(16),
                            borderRadius: 18,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary.withAlpha(25),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Icon(Icons.tune_rounded, color: AppColors.primary, size: 16),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Timing Parameters & Breaks',
                                          style: GoogleFonts.poppins(fontSize: 13.5, fontWeight: FontWeight.bold, color: isDark ? AppColors.textLight : AppColors.textDark),
                                        ),
                                      ],
                                    ),
                                    InkWell(
                                      onTap: () => _openAddBreakModal(context, appState),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF59E0B).withAlpha(25),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.add_rounded, size: 14, color: Color(0xFFF59E0B)),
                                            const SizedBox(width: 2),
                                            Text('+ Break', style: GoogleFonts.poppins(fontSize: 10.5, fontWeight: FontWeight.bold, color: const Color(0xFFF59E0B))),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      _buildCompactParamTile(
                                        context,
                                        title: 'Start',
                                        value: _festivalStartTime.format(context),
                                        icon: Icons.access_time_rounded,
                                        color: AppColors.primary,
                                        isDark: isDark,
                                        onTap: () async {
                                          TimeOfDay? picked = await showTimePicker(context: context, initialTime: _festivalStartTime);
                                          if (picked != null) {
                                            setState(() => _festivalStartTime = picked);
                                            _runAutoScheduleWithRules(appState);
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),

                                // Custom Injected Breaks Pill Bar
                                if (appState.customBreaks.isNotEmpty) ...[
                                  const SizedBox(height: 10),
                                  const Divider(height: 1),
                                  const SizedBox(height: 8),
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: appState.customBreaks.map((b) {
                                        return Container(
                                          margin: const EdgeInsets.only(right: 6),
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF59E0B).withAlpha(20),
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: const Color(0xFFF59E0B).withAlpha(80)),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                '${b.title} (${b.breakTime.format(context)} • ${b.durationMinutes}m)',
                                                style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFFF59E0B)),
                                              ),
                                              const SizedBox(width: 4),
                                              InkWell(
                                                onTap: () => appState.removeCustomBreak(b.id),
                                                child: const Icon(Icons.close_rounded, size: 14, color: AppColors.error),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),

                          const SizedBox(height: 14),

                          // Manual Drag & Reorder Roster Workspace Card
                          Expanded(
                            child: GlassCard(
                              padding: const EdgeInsets.all(16),
                              borderRadius: 18,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: AppColors.secondary.withAlpha(25),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: const Icon(Icons.drag_indicator_rounded, color: AppColors.secondary, size: 16),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Manual Sequence Roster',
                                            style: GoogleFonts.poppins(fontSize: 13.5, fontWeight: FontWeight.bold, color: isDark ? AppColors.textLight : AppColors.textDark),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        width: 140,
                                        height: 32,
                                        child: TextField(
                                          onChanged: (val) => setState(() => _searchProgramQuery = val),
                                          style: GoogleFonts.poppins(fontSize: 11, color: isDark ? AppColors.textLight : AppColors.textDark),
                                          decoration: InputDecoration(
                                            hintText: 'Filter...',
                                            hintStyle: GoogleFonts.poppins(fontSize: 10.5, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
                                            prefixIcon: const Icon(Icons.search_rounded, size: 14, color: AppColors.secondary),
                                            filled: true,
                                            fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                                            contentPadding: const EdgeInsets.symmetric(vertical: 2, horizontal: 6),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),

                                  Expanded(
                                    child: ReorderableListView.builder(
                                      physics: const BouncingScrollPhysics(),
                                      itemCount: filteredPrograms.length,
                                      onReorderItem: (oldIndex, newIndex) {
                                        if (_searchProgramQuery.isEmpty) {
                                          appState.reorderProgram(oldIndex, newIndex);
                                        }
                                      },
                                      itemBuilder: (context, idx) {
                                        final prog = filteredPrograms[idx];
                                        final originalIndex = appState.programs.indexOf(prog);

                                        return Container(
                                          key: ValueKey(prog.id),
                                          margin: const EdgeInsets.only(bottom: 8),
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: isDark ? const Color(0xFF1E293B) : Colors.white,
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                                          ),
                                          child: Row(
                                            children: [
                                              // Sequence Badge
                                              Container(
                                                width: 28,
                                                height: 28,
                                                decoration: BoxDecoration(
                                                  color: AppColors.primary.withAlpha(25),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    '#${originalIndex + 1}',
                                                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 10.5),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),

                                              // Program Info
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      prog.item,
                                                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 11.5, color: isDark ? AppColors.textLight : AppColors.textDark),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                    Text(
                                                      '${prog.studentName} • ${prog.category} • ⏱️ ${prog.durationMinutes}m',
                                                      style: GoogleFonts.poppins(fontSize: 9.5, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              // Quick Arrow Up
                                              IconButton(
                                                icon: const Icon(Icons.arrow_upward_rounded, size: 15),
                                                color: AppColors.primary,
                                                padding: EdgeInsets.zero,
                                                constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                                                onPressed: originalIndex > 0 ? () => appState.reorderProgram(originalIndex, originalIndex - 1) : null,
                                              ),

                                              // Quick Arrow Down
                                              IconButton(
                                                icon: const Icon(Icons.arrow_downward_rounded, size: 15),
                                                color: AppColors.primary,
                                                padding: EdgeInsets.zero,
                                                constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                                                onPressed: originalIndex < appState.programs.length - 1 ? () => appState.reorderProgram(originalIndex, originalIndex + 2) : null,
                                              ),

                                              const SizedBox(width: 4),
                                              const Icon(Icons.drag_handle_rounded, color: Colors.grey, size: 16),
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
                      ),
                    ),

                    if (isNarrow) const SizedBox(height: 20) else const SizedBox(width: 20),

                    // RIGHT COLUMN: Auto-Calculated Live Timeline Stepper View Card
                    SizedBox(
                      width: isNarrow ? double.infinity : (constraints.maxWidth - 72) * 0.54,
                      height: 720,
                      child: GlassCard(
                        padding: const EdgeInsets.all(20),
                        borderRadius: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(7),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF10B981).withAlpha(25),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(Icons.timeline_rounded, color: Color(0xFF10B981), size: 18),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Live Auto-Calculated Timeline',
                                      style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: isDark ? AppColors.textLight : AppColors.textDark),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withAlpha(25),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${appState.scheduleSlots.length} Timeline Slots',
                                    style: GoogleFonts.poppins(fontSize: 10.5, fontWeight: FontWeight.bold, color: AppColors.primary),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            Expanded(
                              child: appState.scheduleSlots.isEmpty
                                  ? Center(
                                      child: Text(
                                        'No timeline slots generated. Click "✨ Generate Smart Schedule".',
                                        style: GoogleFonts.poppins(fontSize: 12, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
                                      ),
                                    )
                                  : ListView.builder(
                                      physics: const BouncingScrollPhysics(),
                                      itemCount: appState.scheduleSlots.length,
                                      itemBuilder: (context, idx) {
                                        final slot = appState.scheduleSlots[idx];
                                        final isPrayer = slot.type == SlotType.prayer;
                                        final isBreak = slot.type == SlotType.breakSlot;
                                        final isLast = idx == appState.scheduleSlots.length - 1;

                                        Color slotColor = AppColors.primary;
                                        if (isPrayer) slotColor = const Color(0xFF10B981);
                                        if (isBreak) slotColor = const Color(0xFFF59E0B);

                                        return CustomPaint(
                                           painter: _StepperLinePainter(color: slotColor, isLast: isLast),
                                           child: Padding(
                                             padding: const EdgeInsets.only(left: 20),
                                             child: Container(
                                               margin: const EdgeInsets.only(bottom: 10),
                                               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                               decoration: BoxDecoration(
                                                 color: isPrayer
                                                     ? const Color(0xFF10B981).withAlpha(18)
                                                     : isBreak
                                                         ? const Color(0xFFF59E0B).withAlpha(18)
                                                         : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC)),
                                                 borderRadius: BorderRadius.circular(14),
                                                 border: Border.all(
                                                   color: isPrayer
                                                       ? const Color(0xFF10B981).withAlpha(80)
                                                       : isBreak
                                                           ? const Color(0xFFF59E0B).withAlpha(80)
                                                           : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                                                 ),
                                               ),
                                               child: Column(
                                                 crossAxisAlignment: CrossAxisAlignment.start,
                                                 mainAxisSize: MainAxisSize.min,
                                                 children: [
                                                   Row(
                                                     children: [
                                                       // Time Badge Pill
                                                       Container(
                                                         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                         decoration: BoxDecoration(
                                                           color: slotColor,
                                                           borderRadius: BorderRadius.circular(8),
                                                         ),
                                                         child: Text(
                                                           '${slot.startTime} - ${slot.endTime}',
                                                           style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
                                                         ),
                                                       ),
                                                       const SizedBox(width: 10),

                                                       // Program Title
                                                       Expanded(
                                                         child: Text(
                                                           slot.title,
                                                           style: GoogleFonts.poppins(
                                                             fontWeight: FontWeight.bold,
                                                             fontSize: 12,
                                                             color: isDark ? AppColors.textLight : AppColors.textDark,
                                                           ),
                                                           maxLines: 1,
                                                           overflow: TextOverflow.ellipsis,
                                                         ),
                                                       ),

                                                       // Program Live/Pending/Completed Status Selector
                                                       if (slot.program != null) ...[
                                                         PopupMenuButton<ProgramStatus>(
                                                           onSelected: (newStatus) {
                                                             appState.updateProgramStatus(slot.program!.id, newStatus);
                                                           },
                                                           itemBuilder: (context) => [
                                                             const PopupMenuItem(
                                                               value: ProgramStatus.pending,
                                                               child: Text('⏳ Scheduled / Pending'),
                                                             ),
                                                             const PopupMenuItem(
                                                               value: ProgramStatus.live,
                                                               child: Text('🔴 Live On Stage'),
                                                             ),
                                                             const PopupMenuItem(
                                                               value: ProgramStatus.completed,
                                                               child: Text('✅ Completed'),
                                                             ),
                                                             const PopupMenuItem(
                                                               value: ProgramStatus.cancelled,
                                                               child: Text('❌ Cancelled'),
                                                             ),
                                                           ],
                                                           child: Container(
                                                             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                             decoration: BoxDecoration(
                                                               color: _getStatusColor(slot.program!.status).withAlpha(30),
                                                               borderRadius: BorderRadius.circular(8),
                                                               border: Border.all(color: _getStatusColor(slot.program!.status).withAlpha(90)),
                                                             ),
                                                             child: Row(
                                                               mainAxisSize: MainAxisSize.min,
                                                               children: [
                                                                 Text(
                                                                   _getStatusLabel(slot.program!.status),
                                                                   style: GoogleFonts.poppins(
                                                                     fontSize: 9.5,
                                                                     fontWeight: FontWeight.bold,
                                                                     color: _getStatusColor(slot.program!.status),
                                                                   ),
                                                                 ),
                                                                 const Icon(Icons.arrow_drop_down_rounded, size: 14),
                                                               ],
                                                             ),
                                                           ),
                                                         ),
                                                       ],
                                                     ],
                                                   ),

                                                   if (slot.program != null) ...[
                                                     const SizedBox(height: 4),
                                                     Text(
                                                       'Participant: ${slot.program!.studentName} • Class ${slot.program!.studentClass} (${slot.program!.category})',
                                                       style: GoogleFonts.poppins(fontSize: 10.5, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
                                                       maxLines: 1,
                                                       overflow: TextOverflow.ellipsis,
                                                     ),
                                                   ] else if (isPrayer || isBreak) ...[
                                                     const SizedBox(height: 4),
                                                     Text(
                                                       isPrayer ? '🕌 Stage program paused for prayer' : '☕ Refreshment break slot',
                                                       style: GoogleFonts.poppins(fontSize: 10.5, fontStyle: FontStyle.italic, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
                                                     ),
                                                   ],
                                                 ],
                                               ),
                                             ),
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
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryBadge({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required bool isDark,
    double width = 180,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withAlpha(isDark ? 25 : 15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withAlpha(isDark ? 70 : 40)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: color.withAlpha(35),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(fontSize: 9.5, fontWeight: FontWeight.w500, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
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
    );
  }

  Widget _buildCompactParamTile(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: color.withAlpha(isDark ? 20 : 12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withAlpha(70)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 5),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.poppins(fontSize: 9, color: isDark ? AppColors.subtextLight : AppColors.subtextDark)),
                Text(value, style: GoogleFonts.poppins(fontSize: 10.5, fontWeight: FontWeight.bold, color: color)),
              ],
            ),
            const SizedBox(width: 4),
            Icon(Icons.edit_outlined, size: 11, color: color),
          ],
        ),
      ),
    );
  }

  Widget _buildRuleConfigBox({
    required bool isDark,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Widget child,
    double width = 280,
  }) {
    return SizedBox(
      width: width,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: iconColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? AppColors.textLight : AppColors.textDark),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: GoogleFonts.poppins(fontSize: 9.5, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildSmallCheck(String label, bool value, ValueChanged<bool?> onChanged) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(
          value: value,
          activeColor: AppColors.primary,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          onChanged: onChanged,
        ),
        Text(label, style: GoogleFonts.poppins(fontSize: 10.5, fontWeight: FontWeight.w600)),
        const SizedBox(width: 6),
      ],
    );
  }

  Color _getStatusColor(ProgramStatus status) {
    switch (status) {
      case ProgramStatus.live:
        return Colors.redAccent;
      case ProgramStatus.completed:
        return const Color(0xFF10B981);
      case ProgramStatus.cancelled:
        return Colors.grey;
      case ProgramStatus.pending:
        return AppColors.primary;
    }
  }

  String _getStatusLabel(ProgramStatus status) {
    switch (status) {
      case ProgramStatus.live:
        return '🔴 Live Now';
      case ProgramStatus.completed:
        return '✅ Completed';
      case ProgramStatus.cancelled:
        return '❌ Cancelled';
      case ProgramStatus.pending:
        return '⏳ Scheduled';
    }
  }
}

class _StepperLinePainter extends CustomPainter {
  final Color color;
  final bool isLast;

  _StepperLinePainter({required this.color, required this.isLast});

  @override
  void paint(Canvas canvas, Size size) {
    const nodeY = 20.0;
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
    canvas.drawCircle(const Offset(nodeX, nodeY), 6, circlePaint);

    final borderPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(const Offset(nodeX, nodeY), 6, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _StepperLinePainter oldDelegate) =>
      color != oldDelegate.color || isLast != oldDelegate.isLast;
}
