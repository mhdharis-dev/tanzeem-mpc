import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/models/models.dart';
import '../../core/providers/app_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/dummy_data.dart';
import '../widgets/glass_card.dart';
import 'add_program_dialog.dart';

class ProgramsListScreen extends StatelessWidget {
  const ProgramsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDark = appState.isDarkMode;
    final filtered = appState.filteredPrograms;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const AddProgramDialog(),
          );
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text('Add New Program', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page Header Title & Subtitle
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
                      'Program Directory & Management',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.textLight : AppColors.textDark,
                      ),
                    ),
                    Text(
                      'Manage competition entries, stage assignments, and program statuses.',
                      style: GoogleFonts.poppins(fontSize: 13, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(25),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.primary.withAlpha(80)),
                  ),
                  child: Text(
                    '${filtered.length} Programs Registered',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 13),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Search & Sticky Filter Bar
            GlassCard(
              borderRadius: 20,
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Search Input
                      Expanded(
                        child: TextField(
                          onChanged: (val) => appState.setSearchQuery(val),
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.search_rounded, size: 20),
                            hintText: 'Search by student name, program number, or item title...',
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Class Filter Dropdown
                      Container(
                        width: 180,
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
                            style: GoogleFonts.poppins(fontSize: 13, color: isDark ? AppColors.textLight : AppColors.textDark),
                            items: ['All', ...DummyData.classes]
                                .map((c) => DropdownMenuItem(value: c, child: Text('Class: $c')))
                                .toList(),
                            onChanged: (val) => appState.setClassFilter(val!),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Filter Chips Row
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
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Professional SaaS Data Table
            GlassCard(
              padding: EdgeInsets.zero,
              borderRadius: 20,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowHeight: 56,
                  dataRowMaxHeight: 72,
                  horizontalMargin: 24,
                  columnSpacing: 20,
                  headingRowColor: WidgetStateProperty.all(
                    isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                  ),
                  columns: [
                    _buildTableColumn('PRG #', isDark),
                    _buildTableColumn('Student', isDark),
                    _buildTableColumn('Class', isDark),
                    _buildTableColumn('Category', isDark),
                    _buildTableColumn('Item Name', isDark),
                    _buildTableColumn('Duration', isDark),
                    _buildTableColumn('Stage', isDark),
                    _buildTableColumn('Start Time', isDark),
                    _buildTableColumn('Status', isDark),
                    _buildTableColumn('Actions', isDark),
                  ],
                  rows: filtered.map((prog) {
                    return DataRow(
                      cells: [
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withAlpha(20),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              prog.number,
                              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 12),
                            ),
                          ),
                        ),
                        DataCell(
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundImage: NetworkImage(prog.studentPhoto),
                                backgroundColor: AppColors.primary.withAlpha(40),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(prog.studentName, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13, color: isDark ? AppColors.textLight : AppColors.textDark)),
                                  Text(prog.teacher, style: GoogleFonts.poppins(fontSize: 11, color: AppColors.subtextDark)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        DataCell(Text(prog.studentClass, style: GoogleFonts.poppins(fontSize: 13, color: isDark ? AppColors.textLight : AppColors.textDark))),
                        DataCell(
                          Container(
                            constraints: const BoxConstraints(maxWidth: 160),
                            child: Text(prog.category, style: GoogleFonts.poppins(fontSize: 12, color: isDark ? AppColors.subtextLight : AppColors.subtextDark), overflow: TextOverflow.ellipsis),
                          ),
                        ),
                        DataCell(
                          Text(prog.item, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13, color: isDark ? AppColors.textLight : AppColors.textDark)),
                        ),
                        DataCell(Text('${prog.durationMinutes} mins', style: GoogleFonts.poppins(fontSize: 13, color: isDark ? AppColors.textLight : AppColors.textDark))),
                        DataCell(Text(prog.stage, style: GoogleFonts.poppins(fontSize: 13, color: isDark ? AppColors.textLight : AppColors.textDark))),
                        DataCell(Text(prog.startTime, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.primary))),
                        DataCell(_buildStatusBadge(prog.status)),
                        DataCell(
                          Row(
                            children: [
                              if (prog.status != ProgramStatus.live)
                                IconButton(
                                  icon: const Icon(Icons.play_circle_fill_rounded, color: AppColors.success, size: 22),
                                  tooltip: 'Start Live on Stage',
                                  onPressed: () => appState.updateProgramStatus(prog.id, ProgramStatus.live),
                                ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
                                tooltip: 'Delete Program',
                                onPressed: () => appState.deleteProgram(prog.id),
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

  Widget _buildStatusBadge(ProgramStatus status) {
    Color bg;
    Color fg;
    String label;

    switch (status) {
      case ProgramStatus.live:
        bg = AppColors.error.withAlpha(30);
        fg = AppColors.error;
        label = '• LIVE';
        break;
      case ProgramStatus.completed:
        bg = AppColors.success.withAlpha(30);
        fg = AppColors.success;
        label = 'Completed';
        break;
      case ProgramStatus.pending:
      default:
        bg = AppColors.warning.withAlpha(30);
        fg = AppColors.warning;
        label = 'Pending';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: fg.withAlpha(100)),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 11, color: fg),
      ),
    );
  }
}
