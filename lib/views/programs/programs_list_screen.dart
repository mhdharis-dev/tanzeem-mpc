import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/models/models.dart';
import '../../core/models/program_model.dart';
import '../../core/providers/app_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/dummy_data.dart';
import '../widgets/glass_card.dart';
import 'add_program_sheet.dart';

class ProgramsListScreen extends StatelessWidget {
  const ProgramsListScreen({super.key});

  void _openAddProgramSheet(BuildContext context, String type, {ProgramModel? programToEdit}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddProgramSheet(
        initialType: type,
        programToEdit: programToEdit,
      ),
    );
  }

  void _confirmDeleteProgram(BuildContext context, AppState appState, ProgramModel prog) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 24),
            const SizedBox(width: 10),
            Text(
              'Delete Program Entry?',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "${prog.programId} - ${prog.programName}" (${prog.participantName})? This action cannot be undone.',
          style: GoogleFonts.poppins(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel', style: GoogleFonts.poppins(color: AppColors.subtextDark)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              appState.deleteProgramFromFirestore(prog.programId, prog.madrasaId);
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Program ${prog.programId} deleted.'),
                  backgroundColor: AppColors.error,
                ),
              );
            },
            child: Text('Delete', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _confirmCancelProgram(BuildContext context, AppState appState, ProgramModel prog) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.block_rounded, color: Colors.orange, size: 24),
            const SizedBox(width: 10),
            Text(
              'Cancel Program Entry?',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to mark "${prog.programId} - ${prog.programName}" (${prog.participantName}) as CANCELLED?',
          style: GoogleFonts.poppins(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('No', style: GoogleFonts.poppins(color: AppColors.subtextDark)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              appState.cancelProgramInFirestore(prog.programId, prog.madrasaId);
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Program ${prog.programId} marked as CANCELLED.'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            child: Text('Yes, Cancel', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDark = appState.isDarkMode;
    final realPrograms = appState.realPrograms;

    // Filter real Firestore programs dynamically
    final filteredRealPrograms = realPrograms.where((p) {
      final q = appState.searchQuery.trim().toLowerCase();
      final matchSearch = q.isEmpty ||
          p.programId.toLowerCase().contains(q) ||
          p.participantName.toLowerCase().contains(q) ||
          p.programName.toLowerCase().contains(q) ||
          p.category.toLowerCase().contains(q);

      final matchClass = appState.selectedClassFilter == 'All' || p.studentClass == appState.selectedClassFilter;

      final matchStatus = appState.selectedStatusFilter == 'All' ||
          (appState.selectedStatusFilter == 'Pending' && p.status.toLowerCase() == 'pending') ||
          (appState.selectedStatusFilter == 'Live' && p.status.toLowerCase() == 'live') ||
          (appState.selectedStatusFilter == 'Completed' && p.status.toLowerCase() == 'completed');

      return matchSearch && matchClass && matchStatus;
    }).toList();

    final totalCount = realPrograms.length;
    final liveCount = realPrograms.where((p) => p.status.toLowerCase() == 'live').length;
    final completedCount = realPrograms.where((p) => p.status.toLowerCase() == 'completed').length;
    final pendingCount = realPrograms.where((p) => p.status.toLowerCase() == 'pending').length;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(28.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page Header Title & Subtitle with 3 Program Adding Buttons
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 20,
              runSpacing: 16,
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
                          child: const Icon(Icons.assignment_rounded, color: AppColors.primary, size: 28),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Program Directory & Schedule',
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppColors.textLight : AppColors.textDark,
                              ),
                            ),
                            Text(
                              'Manage competition entries, stage allocations, and live program schedule.',
                              style: GoogleFonts.poppins(fontSize: 13, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),

                // 3 Program Addition Buttons: 1 'Single', 2 'Group', 3 'Other'
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    // Button 1: Single Item
                    ElevatedButton.icon(
                      onPressed: () => _openAddProgramSheet(context, 'single'),
                      icon: const Icon(Icons.person_add_rounded, size: 18),
                      label: const Text('Single Item'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                      ),
                    ),

                    // Button 2: Group Item
                    ElevatedButton.icon(
                      onPressed: () => _openAddProgramSheet(context, 'group'),
                      icon: const Icon(Icons.group_add_rounded, size: 18),
                      label: const Text('Group Item'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                      ),
                    ),

                    // Button 3: Other Item
                    ElevatedButton.icon(
                      onPressed: () => _openAddProgramSheet(context, 'other'),
                      icon: const Icon(Icons.extension_rounded, size: 18),
                      label: const Text('Other Item'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Real Program Statistics Mini Summary Grid
            LayoutBuilder(
              builder: (context, constraints) {
                int count = constraints.maxWidth > 900 ? 4 : (constraints.maxWidth > 550 ? 2 : 1);
                return GridView.count(
                  crossAxisCount: count,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 2.3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildSummaryCard(context, 'Total Events', '$totalCount', 'Scheduled Programs', Icons.analytics_rounded, AppColors.primary),
                    _buildSummaryCard(context, 'Live Now', '$liveCount', 'Active Stage Performance', Icons.podcasts_rounded, AppColors.error),
                    _buildSummaryCard(context, 'Completed', '$completedCount', 'Finished Performances', Icons.check_circle_rounded, AppColors.success),
                    _buildSummaryCard(context, 'Pending', '$pendingCount', 'Awaiting Stage Call', Icons.hourglass_top_rounded, AppColors.warning),
                  ],
                );
              },
            ),

            const SizedBox(height: 24),

            // Search & Sticky Filter Bar
            GlassCard(
              borderRadius: 22,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Search Input
                      Expanded(
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                          ),
                          child: TextField(
                            onChanged: (val) => appState.setSearchQuery(val),
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.search_rounded, size: 20),
                              hintText: 'Search by student, program ID (PRG-001), or item title...',
                              hintStyle: GoogleFonts.poppins(fontSize: 12, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Class Filter Dropdown
                      Container(
                        width: 180,
                        height: 44,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: appState.selectedClassFilter,
                            isExpanded: true,
                            style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                            dropdownColor: isDark ? AppColors.cardDark : Colors.white,
                            items: ['All', ...DummyData.classes]
                                .map((c) => DropdownMenuItem(value: c, child: Text(c == 'All' ? 'All Classes' : 'Class: $c')))
                                .toList(),
                            onChanged: (val) => appState.setClassFilter(val!),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Filter Chips Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          Text('Status Filter: ', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? AppColors.subtextLight : AppColors.subtextDark)),
                          _buildFilterChip(context, 'All', appState),
                          _buildFilterChip(context, 'Pending', appState),
                          _buildFilterChip(context, 'Live', appState),
                          _buildFilterChip(context, 'Completed', appState),
                        ],
                      ),
                      Text(
                        'Showing ${filteredRealPrograms.length} of $totalCount Entries',
                        style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 100% Real Programs Roster Table with Live/Stop Live & Delete Confirmation Alert
            GlassCard(
              padding: EdgeInsets.zero,
              borderRadius: 24,
              child: filteredRealPrograms.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(48.0),
                      child: Center(
                        child: Column(
                          children: [
                            const Icon(Icons.assignment_late_rounded, size: 48, color: AppColors.subtextDark),
                            const SizedBox(height: 12),
                            Text(
                              'No Programs Found',
                              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? AppColors.textLight : AppColors.textDark),
                            ),
                            Text(
                              'Click "+ Single Item" above to add new program entries to the schedule.',
                              style: GoogleFonts.poppins(fontSize: 12, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
                            ),
                          ],
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: DataTable(
                        headingRowHeight: 56,
                        dataRowMinHeight: 64,
                        dataRowMaxHeight: 72,
                        horizontalMargin: 24,
                        columnSpacing: 20,
                        headingRowColor: WidgetStateProperty.all(
                          isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                        ),
                        columns: [
                          _buildTableColumn('Order #', isDark),
                          _buildTableColumn('PRG #', isDark),
                          _buildTableColumn('Participant Name', isDark),
                          _buildTableColumn('Class & Div', isDark),
                          _buildTableColumn('Category', isDark),
                          _buildTableColumn('Program Name', isDark),
                          _buildTableColumn('Start Time', isDark),
                          _buildTableColumn('End Time', isDark),
                          _buildTableColumn('Duration', isDark),
                          _buildTableColumn('Status', isDark),
                          _buildTableColumn('Actions', isDark),
                        ],
                        rows: filteredRealPrograms.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final prog = entry.value;
                          final calcOrder = idx + 1;
                          final isLive = prog.status.toLowerCase() == 'live';

                          return DataRow(
                            cells: [
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.secondary.withAlpha(20),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '#$calcOrder',
                                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: AppColors.secondary, fontSize: 12),
                                  ),
                                ),
                              ),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withAlpha(20),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    prog.programId,
                                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 12),
                                  ),
                                ),
                              ),
                              // Participant Name (No Image Portion)
                              DataCell(
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      prog.participantName,
                                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13, color: isDark ? AppColors.textLight : AppColors.textDark),
                                    ),
                                    Text(
                                      'ID: ${prog.participantId}',
                                      style: GoogleFonts.poppins(fontSize: 10, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
                                    ),
                                  ],
                                ),
                              ),
                              DataCell(Text('${prog.studentClass} (${prog.division})', style: GoogleFonts.poppins(fontSize: 13, color: isDark ? AppColors.textLight : AppColors.textDark))),
                              DataCell(
                                Text(prog.category, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
                              ),
                              DataCell(
                                Text(prog.programName, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13, color: isDark ? AppColors.textLight : AppColors.textDark)),
                              ),
                              DataCell(
                                Text(
                                  prog.startTime,
                                  style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: isLive ? AppColors.error : AppColors.primary),
                                ),
                              ),
                              DataCell(
                                Text(
                                  prog.endTime,
                                  style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: isDark ? AppColors.textLight : AppColors.textDark),
                                ),
                              ),
                              DataCell(Text(prog.duration, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? AppColors.textLight : AppColors.textDark))),
                              DataCell(_buildStatusTextBadge(prog.status)),
                              DataCell(
                                Row(
                                  children: [
                                    // Start Live / Stop Live Button
                                    if (isLive)
                                      ElevatedButton.icon(
                                        onPressed: () async {
                                          await appState.stopProgramLiveInFirestore(prog.programId, prog.madrasaId);
                                          if (!context.mounted) return;
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('${prog.programId} (${prog.programName}) performance completed! Start & End time recorded.'),
                                              backgroundColor: AppColors.success,
                                            ),
                                          );
                                        },
                                        icon: const Icon(Icons.stop_circle_rounded, size: 14),
                                        label: const Text('Stop Live'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.error,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                          minimumSize: Size.zero,
                                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        ),
                                      )
                                    else
                                      ElevatedButton.icon(
                                        onPressed: () async {
                                          await appState.startProgramLiveInFirestore(prog.programId, prog.madrasaId);
                                          if (!context.mounted) return;
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('${prog.programId} (${prog.programName}) is now LIVE on Stage! Start time recorded.'),
                                              backgroundColor: AppColors.success,
                                            ),
                                          );
                                        },
                                        icon: const Icon(Icons.play_arrow_rounded, size: 14),
                                        label: const Text('Go Live'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.success,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                          minimumSize: Size.zero,
                                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        ),
                                      ),
                                    const SizedBox(width: 8),

                                     // On Tap Edit Button: Open Single Program Dialog Box with Filled Values
                                     IconButton(
                                       icon: const Icon(Icons.edit_rounded, color: AppColors.primary, size: 18),
                                       tooltip: 'Edit Program',
                                       onPressed: () => _openAddProgramSheet(context, prog.programType, programToEdit: prog),
                                     ),

                                     // Cancel Action Button
                                     IconButton(
                                       icon: const Icon(Icons.block_rounded, color: Colors.orange, size: 18),
                                       tooltip: 'Cancel Program',
                                       onPressed: () => _confirmCancelProgram(context, appState, prog),
                                     ),

                                     // Delete Action Button with Confirmation Alert Box
                                     IconButton(
                                       icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 18),
                                       tooltip: 'Delete Program',
                                       onPressed: () => _confirmDeleteProgram(context, appState, prog),
                                     ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, String title, String value, String subtitle, IconData icon, Color color) {
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
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: GoogleFonts.poppins(fontSize: 11, color: isDark ? AppColors.subtextLight : AppColors.subtextDark)),
                Text(value, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? AppColors.textLight : AppColors.textDark)),
                Text(subtitle, style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  DataColumn _buildTableColumn(String label, bool isDark) {
    return DataColumn(
      label: Text(
        label,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.bold,
          fontSize: 13,
          color: isDark ? AppColors.textLight : AppColors.textDark,
        ),
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, AppState appState) {
    final isSelected = appState.selectedStatusFilter == label;
    final isDark = appState.isDarkMode;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.primary,
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      labelStyle: GoogleFonts.poppins(
        color: isSelected ? Colors.white : (isDark ? AppColors.textLight : AppColors.textDark),
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
      ),
      onSelected: (sel) => appState.setStatusFilter(label),
    );
  }

  Widget _buildStatusTextBadge(String statusStr) {
    Color bg = AppColors.warning.withAlpha(30);
    Color fg = AppColors.warning;

    if (statusStr.toLowerCase() == 'live') {
      bg = AppColors.error.withAlpha(30);
      fg = AppColors.error;
    } else if (statusStr.toLowerCase() == 'completed') {
      bg = AppColors.success.withAlpha(30);
      fg = AppColors.success;
    } else if (statusStr.toLowerCase() == 'cancelled' || statusStr.toLowerCase() == 'canceled') {
      bg = Colors.orange.withAlpha(30);
      fg = Colors.orange.shade700;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: fg.withAlpha(100)),
      ),
      child: Text(
        statusStr.toUpperCase(),
        style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 11, color: fg),
      ),
    );
  }
}
