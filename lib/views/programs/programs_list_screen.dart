import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/models/participant_model.dart';
import '../../core/models/program_model.dart';
import '../../core/providers/app_state.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/glass_card.dart';
import 'add_program_sheet.dart';

class ProgramsListScreen extends StatefulWidget {
  const ProgramsListScreen({super.key});

  @override
  State<ProgramsListScreen> createState() => _ProgramsListScreenState();
}

class _ProgramsListScreenState extends State<ProgramsListScreen> {
  final Set<String> _expandedProgramIds = {};
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final appState = Provider.of<AppState>(context, listen: false);
    _searchController.text = appState.searchQuery;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleExpand(String progId) {
    setState(() {
      if (_expandedProgramIds.contains(progId)) {
        _expandedProgramIds.remove(progId);
      } else {
        _expandedProgramIds.add(progId);
      }
    });
  }

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

  void _confirmUncancelProgram(BuildContext context, AppState appState, ProgramModel prog) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.undo_rounded, color: AppColors.primary, size: 24),
            const SizedBox(width: 10),
            Text(
              'Uncancel Program Entry?',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        content: Text(
          'Restore "${prog.programId} - ${prog.programName}" (${prog.participantName}) status back to PENDING?',
          style: GoogleFonts.poppins(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('No', style: GoogleFonts.poppins(color: AppColors.subtextDark)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              appState.uncancelProgramInFirestore(prog.programId, prog.madrasaId);
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Program ${prog.programId} restored to PENDING status.'),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
            child: Text('Yes, Restore to Pending', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
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

    final filteredRealPrograms = realPrograms.where((p) {
      final q = appState.searchQuery.trim().toLowerCase();
      bool matchSearch = true;
      if (q.isNotEmpty) {
        matchSearch = p.programId.toLowerCase().contains(q) ||
            p.participantName.toLowerCase().contains(q) ||
            p.participantId.toLowerCase().contains(q) ||
            p.programName.toLowerCase().contains(q) ||
            p.category.toLowerCase().contains(q) ||
            p.studentClass.toLowerCase().contains(q);
      }

      bool matchClass = true;
      if (appState.selectedClassFilter != 'All') {
        final targetNum = appState.selectedClassFilter.replaceAll(RegExp(r'[^0-9]'), '');
        final progNum = p.studentClass.replaceAll(RegExp(r'[^0-9]'), '');
        matchClass = (targetNum.isNotEmpty && progNum == targetNum) ||
            p.studentClass.toLowerCase() == appState.selectedClassFilter.toLowerCase();
      }

      bool matchCategory = true;
      if (appState.selectedCategoryFilter != 'All') {
        matchCategory = p.category.trim().toLowerCase() == appState.selectedCategoryFilter.trim().toLowerCase();
      }

      bool matchType = true;
      if (appState.selectedTypeFilter != 'All') {
        final targetType = appState.selectedTypeFilter.trim().toLowerCase();
        final isGroup = p.programType.trim().toLowerCase() == 'group' || p.participantName.contains(',');
        if (targetType == 'group') {
          matchType = isGroup;
        } else if (targetType == 'single') {
          matchType = !isGroup;
        }
      }

      bool matchStatus = true;
      if (appState.selectedStatusFilter != 'All') {
        final targetStatus = appState.selectedStatusFilter.trim().toLowerCase();
        final pStatus = p.status.trim().toLowerCase();
        if (targetStatus == 'pending') {
          matchStatus = pStatus == 'pending';
        } else if (targetStatus == 'live') {
          matchStatus = pStatus == 'live';
        } else if (targetStatus == 'completed') {
          matchStatus = pStatus == 'completed';
        } else if (targetStatus == 'cancelled' || targetStatus == 'canceled') {
          matchStatus = pStatus == 'cancelled' || pStatus == 'canceled';
        }
      }

      return matchSearch && matchClass && matchCategory && matchType && matchStatus;
    }).toList();

    final totalCount = realPrograms.length;
    final liveCount = realPrograms.where((p) => p.status.toLowerCase() == 'live').length;
    final completedCount = realPrograms.where((p) => p.status.toLowerCase() == 'completed').length;
    final pendingCount = realPrograms.where((p) => p.status.toLowerCase() == 'pending').length;

    final hasActiveFilters = appState.searchQuery.isNotEmpty ||
        appState.selectedClassFilter != 'All' ||
        appState.selectedCategoryFilter != 'All' ||
        appState.selectedTypeFilter != 'All' ||
        appState.selectedStatusFilter != 'All';

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Glassmorphic Hero Banner Section
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
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.primary, AppColors.secondary],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withAlpha(70),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.assignment_rounded, color: Colors.white, size: 28),
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

                Wrap(
                  spacing: 12,
                  runSpacing: 10,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _openAddProgramSheet(context, 'single'),
                      icon: const Icon(Icons.person_add_rounded, size: 18),
                      label: const Text('+ Single Item'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 3,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _openAddProgramSheet(context, 'group'),
                      icon: const Icon(Icons.group_add_rounded, size: 18),
                      label: const Text('+ Group Item'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 3,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Metrics Summary Cards
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

            const SizedBox(height: 20),

            // Search & Filter Panel
            GlassCard(
              borderRadius: 20,
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                          ),
                          child: TextField(
                            controller: _searchController,
                            onChanged: (_) => setState(() {}),
                            onSubmitted: (val) {
                              appState.setSearchQuery(val.trim());
                            },
                            style: GoogleFonts.poppins(fontSize: 13, color: isDark ? AppColors.textLight : AppColors.textDark),
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.search_rounded, size: 20),
                              suffixIcon: _searchController.text.isNotEmpty || appState.searchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear_rounded, size: 18),
                                      onPressed: () {
                                        setState(() {
                                          _searchController.clear();
                                        });
                                        appState.setSearchQuery('');
                                      },
                                    )
                                  : null,
                              hintText: 'Type student name, ID (PATC-001), program ID (PRG-001), item title...',
                              hintStyle: GoogleFonts.poppins(fontSize: 12, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 11),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      ElevatedButton.icon(
                        onPressed: () {
                          appState.setSearchQuery(_searchController.text.trim());
                        },
                        icon: const Icon(Icons.search_rounded, size: 18),
                        label: Text(
                          'Search',
                          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 2,
                        ),
                      ),

                      if (hasActiveFilters) ...[
                        const SizedBox(width: 10),
                        OutlinedButton.icon(
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                            });
                            appState.resetAllFilters();
                          },
                          icon: const Icon(Icons.filter_alt_off_rounded, size: 16, color: AppColors.error),
                          label: Text('Reset Filters', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.error, fontWeight: FontWeight.bold)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.error),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 14),

                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _buildFilterDropdown(
                        context,
                        label: 'Class Filter',
                        value: appState.selectedClassFilter,
                        items: ['All', 'Class 1', 'Class 2', 'Class 3', 'Class 4', 'Class 5', 'Class 6', 'Class 7', 'Class 8', 'Class 9', 'Class 10', 'Class 11', 'Class 12'],
                        onChanged: (val) => appState.setClassFilter(val!),
                        icon: Icons.school_rounded,
                        isDark: isDark,
                      ),
                      _buildFilterDropdown(
                        context,
                        label: 'Category',
                        value: appState.selectedCategoryFilter,
                        items: ['All', 'Sub-Junior' , 'Junior', 'Senior', 'Super Senior'],
                        onChanged: (val) => appState.setCategoryFilter(val!),
                        icon: Icons.workspace_premium_rounded,
                        isDark: isDark,
                      ),
                      _buildFilterDropdown(
                        context,
                        label: 'Program Type',
                        value: appState.selectedTypeFilter,
                        items: ['All', 'Single', 'Group'],
                        onChanged: (val) => appState.setTypeFilter(val!),
                        icon: Icons.groups_rounded,
                        isDark: isDark,
                      ),
                      _buildFilterDropdown(
                        context,
                        label: 'Status',
                        value: appState.selectedStatusFilter,
                        items: ['All', 'Pending', 'Live', 'Completed', 'Cancelled'],
                        onChanged: (val) => appState.setStatusFilter(val!),
                        icon: Icons.flaky_rounded,
                        isDark: isDark,
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  Text(
                    'Showing ${filteredRealPrograms.length} of $totalCount Entries',
                    style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Redesigned Responsive Schedule Table Card
            GlassCard(
              padding: const EdgeInsets.all(14),
              borderRadius: 20,
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
                              'Try adjusting your search query or dropdown filters above.',
                              style: GoogleFonts.poppins(fontSize: 12, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
                            ),
                          ],
                        ),
                      ),
                    )
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        final double tableWidth = constraints.maxWidth > 1180 ? constraints.maxWidth : 1180;

                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: SizedBox(
                            width: tableWidth,
                            child: Column(
                              children: [
                                // Table Header Bar (Aligned with Data Rows)
                                Container(
                                  height: 48,
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: isDark
                                          ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                                          : [const Color(0xFFF1F5F9), const Color(0xFFE2E8F0)],
                                    ),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                                      width: 1.2,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      SizedBox(width: 60, child: Text('ORDER #', style: _headerStyle(isDark))),
                                      const SizedBox(width: 12),
                                      SizedBox(width: 70, child: Text('PRG #', style: _headerStyle(isDark))),
                                      const SizedBox(width: 12),
                                      Expanded(flex: 4, child: Text('PARTICIPANT', style: _headerStyle(isDark))),
                                      const SizedBox(width: 12),
                                      SizedBox(width: 80, child: Text('CLASS & DIV', style: _headerStyle(isDark))),
                                      const SizedBox(width: 12),
                                      SizedBox(width: 80, child: Text('CATEGORY', style: _headerStyle(isDark))),
                                      const SizedBox(width: 12),
                                      Expanded(flex: 3, child: Text('PROGRAM NAME', style: _headerStyle(isDark))),
                                      const SizedBox(width: 12),
                                      SizedBox(width: 70, child: Text('START TIME', style: _headerStyle(isDark))),
                                      const SizedBox(width: 12),
                                      SizedBox(width: 65, child: Text('END TIME', style: _headerStyle(isDark))),
                                      const SizedBox(width: 12),
                                      SizedBox(width: 65, child: Text('DURATION', style: _headerStyle(isDark))),
                                      const SizedBox(width: 12),
                                      SizedBox(width: 90, child: Text('STATUS', style: _headerStyle(isDark))),
                                      const SizedBox(width: 12),
                                      SizedBox(width: 130, child: Text('ACTIONS', style: _headerStyle(isDark))),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),

                                // Data Rows List (Perfect Alignment)
                                ...filteredRealPrograms.asMap().entries.map((entry) {
                                  final idx = entry.key;
                                  final prog = entry.value;
                                  final calcOrder = idx + 1;
                                  final isLive = prog.status.toLowerCase() == 'live';
                                  final isExpanded = _expandedProgramIds.contains(prog.programId);

                                  final names = prog.participantName.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
                                  final ids = prog.participantId.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

                                  final studentList = <Map<String, String>>[];
                                  for (int i = 0; i < names.length; i++) {
                                    final sName = names[i];
                                    final sId = i < ids.length ? ids[i] : 'PATC-00${i + 1}';

                                    ParticipantModel? match;
                                    try {
                                      match = appState.realParticipants.firstWhere(
                                        (p) => p.participantId.toLowerCase() == sId.toLowerCase() || p.name.toLowerCase() == sName.toLowerCase(),
                                      );
                                    } catch (_) {
                                      match = null;
                                    }

                                    final sClass = match != null ? 'Class ${match.studentClass} (${match.division})' : '${prog.studentClass} (${prog.division})';
                                    final sCat = match != null ? match.category : prog.category;

                                    studentList.add({
                                      'name': sName,
                                      'id': sId,
                                      'classDiv': sClass,
                                      'category': sCat,
                                    });
                                  }

                                  final isMultiParticipantGroup = studentList.length >= 2;

                                  return Column(
                                    children: [
                                      Container(
                                        height: 64,
                                        margin: const EdgeInsets.only(bottom: 6),
                                        padding: const EdgeInsets.symmetric(horizontal: 12),
                                        decoration: BoxDecoration(
                                          color: isLive
                                              ? AppColors.error.withAlpha(16)
                                              : (isExpanded && isMultiParticipantGroup)
                                                  ? (isDark ? AppColors.surfaceDark.withAlpha(150) : const Color(0xFFF1F5F9))
                                                  : (isDark ? AppColors.cardDark : Colors.white),
                                          borderRadius: BorderRadius.circular(14),
                                          border: Border.all(
                                            color: isLive
                                                ? AppColors.error.withAlpha(120)
                                                : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                                            width: isLive ? 1.5 : 1.0,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withAlpha(isDark ? 20 : 6),
                                              blurRadius: 6,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          children: [
                                            // 1. ORDER # (60)
                                            SizedBox(
                                              width: 60,
                                              child: Row(
                                                children: [
                                                  if (isMultiParticipantGroup)
                                                    IconButton(
                                                      padding: EdgeInsets.zero,
                                                      constraints: const BoxConstraints(),
                                                      icon: Icon(
                                                        isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                                                        color: AppColors.secondary,
                                                        size: 18,
                                                      ),
                                                      tooltip: isExpanded ? 'Collapse Student Tiles' : 'Expand Student Tiles',
                                                      onPressed: () => _toggleExpand(prog.programId),
                                                    )
                                                  else
                                                    const SizedBox(width: 16),
                                                  const SizedBox(width: 2),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        colors: [AppColors.secondary.withAlpha(35), AppColors.secondary.withAlpha(15)],
                                                      ),
                                                      borderRadius: BorderRadius.circular(6),
                                                      border: Border.all(color: AppColors.secondary.withAlpha(80), width: 1.0),
                                                    ),
                                                    child: Text(
                                                      '#$calcOrder',
                                                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: AppColors.secondary, fontSize: 10.5),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 12),

                                            // 2. PRG # (70)
                                            SizedBox(
                                              width: 70,
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                                                decoration: BoxDecoration(
                                                  color: AppColors.primary.withAlpha(20),
                                                  borderRadius: BorderRadius.circular(6),
                                                  border: Border.all(color: AppColors.primary.withAlpha(60), width: 1.0),
                                                ),
                                                child: Text(
                                                  prog.programId,
                                                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 10.5),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),

                                            // 3. PARTICIPANT (Expanded flex: 4)
                                            Expanded(
                                              flex: 4,
                                              child: Row(
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.all(5),
                                                    decoration: BoxDecoration(
                                                      color: isMultiParticipantGroup
                                                          ? AppColors.secondary.withAlpha(25)
                                                          : AppColors.primary.withAlpha(25),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: Icon(
                                                      isMultiParticipantGroup ? Icons.groups_rounded : Icons.person_rounded,
                                                      size: 14,
                                                      color: isMultiParticipantGroup ? AppColors.secondary : AppColors.primary,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Text(
                                                          isMultiParticipantGroup ? 'General' : prog.participantName,
                                                          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12, color: isDark ? AppColors.textLight : AppColors.textDark),
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                        Text(
                                                          isMultiParticipantGroup
                                                              ? 'Group (${studentList.length} Students)'
                                                              : 'ID: ${prog.participantId}',
                                                          style: GoogleFonts.poppins(fontSize: 9.5, fontWeight: FontWeight.w500, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 12),

                                            // 4. CLASS & DIV (80)
                                            SizedBox(
                                              width: 80,
                                              child: Text(
                                                isMultiParticipantGroup ? '-' : '${prog.studentClass} (${prog.division})',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 11.5,
                                                  fontWeight: isMultiParticipantGroup ? FontWeight.bold : FontWeight.w600,
                                                  color: isDark ? AppColors.textLight : AppColors.textDark,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(width: 12),

                                            // 5. CATEGORY (80)
                                            SizedBox(
                                              width: 80,
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                                                decoration: BoxDecoration(
                                                  color: isMultiParticipantGroup
                                                      ? (isDark ? Colors.white10 : const Color(0xFFF1F5F9))
                                                      : AppColors.primary.withAlpha(20),
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  isMultiParticipantGroup ? 'general' : prog.category,
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 10,
                                                    color: isMultiParticipantGroup ? (isDark ? AppColors.subtextLight : AppColors.subtextDark) : AppColors.primary,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),

                                            // 6. PROGRAM NAME (Expanded flex: 3)
                                            Expanded(
                                              flex: 3,
                                              child: Text(
                                                prog.programName,
                                                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12, color: isDark ? AppColors.textLight : AppColors.textDark),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(width: 12),

                                            // 7. START TIME (70)
                                            SizedBox(
                                              width: 70,
                                              child: Text(
                                                prog.startTime,
                                                style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: isLive ? AppColors.error : AppColors.primary),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(width: 12),

                                            // 8. END TIME (65)
                                            SizedBox(
                                              width: 65,
                                              child: Text(
                                                prog.endTime,
                                                style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500, color: isDark ? AppColors.textLight : AppColors.textDark),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(width: 12),

                                            // 9. DURATION (65)
                                            SizedBox(
                                              width: 65,
                                              child: Text(
                                                prog.duration,
                                                style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: isDark ? AppColors.textLight : AppColors.textDark),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(width: 12),

                                            // 10. STATUS (90)
                                            SizedBox(
                                              width: 90,
                                              child: _buildStatusTextBadge(prog.status),
                                            ),
                                            const SizedBox(width: 12),

                                            // 11. ACTIONS (130)
                                            SizedBox(
                                              width: 130,
                                              child: Row(
                                                children: [
                                                  if (prog.status.toLowerCase() == 'pending') ...[
                                                    Tooltip(
                                                      message: 'Go Live Now',
                                                      child: InkWell(
                                                        onTap: () async {
                                                          await appState.startProgramLiveInFirestore(prog.programId, prog.madrasaId);
                                                          if (!context.mounted) return;
                                                          ScaffoldMessenger.of(context).showSnackBar(
                                                            SnackBar(
                                                              content: Text('${prog.programId} is now LIVE on Stage!'),
                                                              backgroundColor: AppColors.success,
                                                            ),
                                                          );
                                                        },
                                                        borderRadius: BorderRadius.circular(6),
                                                        child: Container(
                                                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
                                                          decoration: BoxDecoration(
                                                            color: AppColors.success,
                                                            borderRadius: BorderRadius.circular(6),
                                                          ),
                                                          child: Row(
                                                            children: [
                                                              const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 13),
                                                              const SizedBox(width: 2),
                                                              Text('Live', style: GoogleFonts.poppins(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.bold)),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 3),
                                                    _buildActionButton(
                                                      icon: Icons.block_rounded,
                                                      color: Colors.orange,
                                                      tooltip: 'Cancel Program',
                                                      onPressed: () => _confirmCancelProgram(context, appState, prog),
                                                      isDark: isDark,
                                                    ),
                                                    const SizedBox(width: 3),
                                                    _buildActionButton(
                                                      icon: Icons.edit_rounded,
                                                      color: AppColors.primary,
                                                      tooltip: 'Edit Program',
                                                      onPressed: () => _openAddProgramSheet(context, prog.programType, programToEdit: prog),
                                                      isDark: isDark,
                                                    ),
                                                    const SizedBox(width: 3),
                                                    _buildActionButton(
                                                      icon: Icons.delete_outline_rounded,
                                                      color: AppColors.error,
                                                      tooltip: 'Delete Program',
                                                      onPressed: () => _confirmDeleteProgram(context, appState, prog),
                                                      isDark: isDark,
                                                    ),
                                                  ] else if (prog.status.toLowerCase() == 'live') ...[
                                                    Tooltip(
                                                      message: 'Stop Live Performance',
                                                      child: InkWell(
                                                        onTap: () async {
                                                          await appState.stopProgramLiveInFirestore(prog.programId, prog.madrasaId);
                                                          if (!context.mounted) return;
                                                          ScaffoldMessenger.of(context).showSnackBar(
                                                            SnackBar(
                                                              content: Text('${prog.programId} performance completed!'),
                                                              backgroundColor: AppColors.success,
                                                            ),
                                                          );
                                                        },
                                                        borderRadius: BorderRadius.circular(6),
                                                        child: Container(
                                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                          decoration: BoxDecoration(
                                                            color: AppColors.error,
                                                            borderRadius: BorderRadius.circular(6),
                                                          ),
                                                          child: Row(
                                                            children: [
                                                              const Icon(Icons.stop_circle_rounded, color: Colors.white, size: 13),
                                                              const SizedBox(width: 2),
                                                              Text('Stop', style: GoogleFonts.poppins(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.bold)),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ] else if (prog.status.toLowerCase() == 'completed') ...[
                                                    _buildActionButton(
                                                      icon: Icons.edit_rounded,
                                                      color: AppColors.primary,
                                                      tooltip: 'Edit Program',
                                                      onPressed: () => _openAddProgramSheet(context, prog.programType, programToEdit: prog),
                                                      isDark: isDark,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    _buildActionButton(
                                                      icon: Icons.delete_outline_rounded,
                                                      color: AppColors.error,
                                                      tooltip: 'Delete Program',
                                                      onPressed: () => _confirmDeleteProgram(context, appState, prog),
                                                      isDark: isDark,
                                                    ),
                                                  ] else if (prog.status.toLowerCase() == 'cancelled' || prog.status.toLowerCase() == 'canceled') ...[
                                                    Tooltip(
                                                      message: 'Restore to Pending',
                                                      child: InkWell(
                                                        onTap: () => _confirmUncancelProgram(context, appState, prog),
                                                        borderRadius: BorderRadius.circular(6),
                                                        child: Container(
                                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                          decoration: BoxDecoration(
                                                            color: AppColors.secondary,
                                                            borderRadius: BorderRadius.circular(6),
                                                          ),
                                                          child: Row(
                                                            children: [
                                                              const Icon(Icons.undo_rounded, color: Colors.white, size: 13),
                                                              const SizedBox(width: 2),
                                                              Text('Uncancel', style: GoogleFonts.poppins(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.bold)),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      if (isExpanded && isMultiParticipantGroup) ...[
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(18),
                                          margin: const EdgeInsets.only(bottom: 10),
                                          decoration: BoxDecoration(
                                            color: isDark ? AppColors.surfaceDark.withAlpha(180) : const Color(0xFFF8FAFC),
                                            borderRadius: BorderRadius.circular(18),
                                            border: Border.all(color: AppColors.secondary.withAlpha(70), width: 1.5),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.all(6),
                                                    decoration: BoxDecoration(
                                                      color: AppColors.secondary.withAlpha(25),
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: const Icon(Icons.groups_rounded, color: AppColors.secondary, size: 20),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Text(
                                                    'Group Member Students (${studentList.length} Participants):',
                                                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13.5, color: AppColors.secondary),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 14),
                                              Wrap(
                                                spacing: 14,
                                                runSpacing: 14,
                                                children: studentList.map((st) {
                                                  return _buildStudentTile(
                                                    context,
                                                    st['name']!,
                                                    st['id']!,
                                                    st['classDiv']!,
                                                    st['category']!,
                                                    isDark,
                                                  );
                                                }).toList(),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ],
                                  );
                                }),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  TextStyle _headerStyle(bool isDark) {
    return GoogleFonts.poppins(
      fontWeight: FontWeight.bold,
      fontSize: 11,
      letterSpacing: 0.8,
      color: isDark ? AppColors.subtextLight : const Color(0xFF475569),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onPressed,
    required bool isDark,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.all(4.5),
          decoration: BoxDecoration(
            color: color.withAlpha(18),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: color.withAlpha(60), width: 1.0),
          ),
          child: Icon(icon, color: color, size: 14),
        ),
      ),
    );
  }

  Widget _buildFilterDropdown(
    BuildContext context, {
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required IconData icon,
    required bool isDark,
  }) {
    final isSelected = value != 'All';

    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primary.withAlpha(20)
            : (isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected
              ? AppColors.primary
              : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
          width: isSelected ? 1.5 : 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: isSelected ? AppColors.primary : (isDark ? AppColors.subtextLight : AppColors.subtextDark)),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected ? AppColors.primary : (isDark ? AppColors.textLight : AppColors.textDark),
              ),
              dropdownColor: isDark ? AppColors.cardDark : Colors.white,
              items: items
                  .map((item) => DropdownMenuItem(
                        value: item,
                        child: Text(item),
                      ))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentTile(
    BuildContext context,
    String name,
    String id,
    String classDiv,
    String category,
    bool isDark,
  ) {
    return Container(
      width: 275,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.secondary.withAlpha(80),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.secondary.withAlpha(25),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person_rounded, color: AppColors.secondary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: isDark ? AppColors.textLight : AppColors.textDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'ID: $id',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white10 : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: isDark ? Colors.white24 : const Color(0xFFCBD5E1), width: 0.8),
                      ),
                      child: Text(
                        classDiv,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.textLight : AppColors.textDark,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(20),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.primary.withAlpha(60), width: 0.8),
                      ),
                      child: Text(
                        category,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
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

  Widget _buildStatusTextBadge(String statusStr) {
    final s = statusStr.toLowerCase();
    Color bg = AppColors.warning.withAlpha(25);
    Color fg = AppColors.warning;
    IconData icon = Icons.hourglass_top_rounded;

    if (s == 'live') {
      bg = AppColors.error.withAlpha(30);
      fg = AppColors.error;
      icon = Icons.podcasts_rounded;
    } else if (s == 'completed') {
      bg = AppColors.success.withAlpha(25);
      fg = AppColors.success;
      icon = Icons.check_circle_rounded;
    } else if (s == 'cancelled' || s == 'canceled') {
      bg = Colors.orange.withAlpha(25);
      fg = Colors.orange.shade700;
      icon = Icons.block_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3.5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: fg.withAlpha(90), width: 1.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: fg),
          const SizedBox(width: 3),
          Flexible(
            child: Text(
              statusStr.toUpperCase(),
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 9, color: fg),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
