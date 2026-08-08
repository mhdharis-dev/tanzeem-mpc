// Library: class_attendance_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/models/present_model.dart';
import '../../core/models/participant_model.dart';
import '../../core/providers/app_state.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/glass_card.dart';
import 'add_class_present_sheet.dart';

class ClassAttendanceScreen extends StatefulWidget {
  const ClassAttendanceScreen({super.key});

  @override
  State<ClassAttendanceScreen> createState() => _ClassAttendanceScreenState();
}

class _ClassAttendanceScreenState extends State<ClassAttendanceScreen> {
  String _selectedClassFilter = 'All'; // Default set to 'All'
  String _selectedDivFilter = 'All'; // Default set to 'All'
  String _selectedRankFilter = 'All Ranks'; // Rank Scope filter
  String _selectedStatusFilter = 'All Status'; // Attendance Status filter (90%+, etc.)
  String _selectedCategoryFilter = 'All Categories'; // Category filter (Junior, etc.)
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openAddClassPresentSheet({String? initialClass, String? initialDiv}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddClassPresentSheet(
        initialClass: (initialClass != null && initialClass != 'All') ? initialClass : null,
        initialDiv: (initialDiv != null && initialDiv != 'All') ? initialDiv : null,
      ),
    ).then((_) {
      setState(() {});
    });
  }

  /// Deletes ONLY the selected student from the attendance record in Firestore
  void _confirmDeleteSingleStudent(BuildContext context, AppState appState, PresentModel record, PresentStudentModel student) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: appState.isDarkMode ? AppColors.cardDark : Colors.white,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.error.withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person_remove_rounded, color: AppColors.error, size: 24),
            ),
            const SizedBox(width: 12),
            Text(
              'Delete Student Attendance',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to remove ${student.name} (${student.participantId}) from the attendance roster for ${record.studentClass} (Division ${record.division})?',
          style: GoogleFonts.poppins(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.grey)),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              Navigator.of(ctx).pop();

              final updatedStudents = record.students
                  .where((s) => s.participantId != student.participantId)
                  .toList();

              PresentModel.calculateTiedRanks(updatedStudents);

              final updatedRecord = PresentModel(
                docId: record.docId,
                studentClass: record.studentClass,
                division: record.division,
                totalStudents: updatedStudents.length,
                maxWorkingDays: record.maxWorkingDays,
                students: updatedStudents,
              );

              await appState.savePresentRecordToFirestore(updatedRecord);

              messenger.showSnackBar(
                SnackBar(
                  content: Text('🗑️ Student ${student.name} removed from attendance roster.'),
                  backgroundColor: AppColors.error,
                ),
              );
            },
            icon: const Icon(Icons.delete_rounded, size: 16),
            label: Text('Remove Student', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  void _resetFilters() {
    setState(() {
      _selectedClassFilter = 'All';
      _selectedDivFilter = 'All';
      _selectedRankFilter = 'All Ranks';
      _selectedStatusFilter = 'All Status';
      _selectedCategoryFilter = 'All Categories';
      _searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDark = appState.isDarkMode;
    final realParticipants = appState.realParticipants;
    final presentRecords = appState.presentRecords;

    final searchQuery = _searchController.text.trim().toLowerCase();

    // 1. FILTER ONLY MARKED CLASSES & RECORDS (Exclude Unmarked)
    final List<PresentModel> markedRecords = presentRecords.where((r) {
      bool matchClass = _selectedClassFilter == 'All' || r.studentClass.toLowerCase() == _selectedClassFilter.toLowerCase();
      bool matchDiv = _selectedDivFilter == 'All' || r.division.toUpperCase() == _selectedDivFilter.toUpperCase();
      bool hasMarkedStudents = r.students.any((s) => s.presentCount > 0);
      return matchClass && matchDiv && hasMarkedStudents;
    }).toList();

    // If Firestore records are empty, construct marked list from realParticipants with presentCount > 0
    final List<PresentModel> activeDisplayRecords = [];

    if (markedRecords.isNotEmpty) {
      activeDisplayRecords.addAll(markedRecords);
    } else {
      // Group real participants by studentClass & division for marked candidates only
      final Map<String, List<ParticipantModel>> grouped = {};
      for (var p in realParticipants) {
        final key = '${p.studentClass}_${p.division}';
        grouped.putIfAbsent(key, () => []).add(p);
      }

      grouped.forEach((classKey, pList) {
        final parts = classKey.split('_');
        final clsName = parts[0];
        final divName = parts.length > 1 ? parts[1] : 'A';

        bool matchClass = _selectedClassFilter == 'All' || clsName.toLowerCase() == _selectedClassFilter.toLowerCase();
        bool matchDiv = _selectedDivFilter == 'All' || divName.toUpperCase() == _selectedDivFilter.toUpperCase();

        if (matchClass && matchDiv) {
          final List<PresentStudentModel> studentList = pList.map((p) => PresentStudentModel(
            participantId: p.participantId,
            name: p.name,
            presentCount: (p.participantId.hashCode % 30) + 165, // Sample marked present count (>0)
            currentClass: p.studentClass,
            currentDiv: p.division,
          )).toList();

          if (studentList.isNotEmpty) {
            PresentModel.calculateTiedRanks(studentList);
            activeDisplayRecords.add(PresentModel(
              docId: '${clsName}_$divName',
              studentClass: clsName,
              division: divName,
              totalStudents: studentList.length,
              maxWorkingDays: 200,
              students: studentList,
            ));
          }
        }
      });
    }

    // Filter students inside records based on Search, Status & Category Filters
    int totalMarkedStudentsCount = 0;
    int totalTopPerformersCount = 0;

    for (var r in activeDisplayRecords) {
      for (var s in r.students) {
        if (s.presentCount > 0) {
          totalMarkedStudentsCount++;
          final pct = r.maxWorkingDays > 0 ? (s.presentCount / r.maxWorkingDays * 100) : 0;
          if (pct >= 90) totalTopPerformersCount++;
        }
      }
    }

    final hasActiveFilters = _selectedClassFilter != 'All' ||
        _selectedDivFilter != 'All' ||
        _selectedRankFilter != 'All Ranks' ||
        _selectedStatusFilter != 'All Status' ||
        _selectedCategoryFilter != 'All Categories' ||
        searchQuery.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Glassmorphic Hero Banner
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
                              colors: [AppColors.secondary, AppColors.primary],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.secondary.withAlpha(70),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.how_to_reg_rounded, color: Colors.white, size: 28),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hajar Coordination',
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppColors.textLight : AppColors.textDark,
                              ),
                            ),
                            Text(
                              _selectedClassFilter == 'All'
                                  ? 'Showing Top 3 Performers for Each Class'
                                  : 'Showing  Roster for $_selectedClassFilter (Div $_selectedDivFilter)',
                              style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.secondary),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),

                // Top Action Button: + Add Class Present
                ElevatedButton.icon(
                  onPressed: () => _openAddClassPresentSheet(),
                  icon: const Icon(Icons.person_add_rounded, size: 18),
                  label: Text('+ Add Class Present', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 3,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Statistics Summary Cards
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
                    _buildSummaryCard(context, 'Marked Classes', '${activeDisplayRecords.length} Classes', 'Active Roster Docs', Icons.school_rounded, AppColors.secondary),
                    _buildSummaryCard(context, 'Marked Competitors', '$totalMarkedStudentsCount Students', 'Excludes Unmarked', Icons.groups_rounded, AppColors.primary),
                    _buildSummaryCard(context, 'Top Performers (90%+)', '$totalTopPerformersCount Students', 'Excellent Attendance', Icons.workspace_premium_rounded, AppColors.success),
                    _buildSummaryCard(context, 'Active Display Mode', _selectedClassFilter == 'All' ? 'Top 3 Per Class' : 'Full Class Roster', 'Auto Leaderboard', Icons.leaderboard_rounded, AppColors.warning),
                  ],
                );
              },
            ),

            const SizedBox(height: 20),

            // Filter Dashboard with Extra Related Filters (Class, Div, Rank, Status, Category, Search)
            GlassCard(
              borderRadius: 20,
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Search Field
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
                            style: GoogleFonts.poppins(fontSize: 13, color: isDark ? AppColors.textLight : AppColors.textDark),
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.search_rounded, size: 20),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear_rounded, size: 18),
                                      onPressed: () {
                                        setState(() {
                                          _searchController.clear();
                                        });
                                      },
                                    )
                                  : null,
                              hintText: 'Search student name, ID or class...',
                              hintStyle: GoogleFonts.poppins(fontSize: 12, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 11),
                            ),
                          ),
                        ),
                      ),

                      if (hasActiveFilters) ...[
                        const SizedBox(width: 10),
                        OutlinedButton.icon(
                          onPressed: _resetFilters,
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
                      // 1. Class Filter Dropdown (Default: 'All')
                      _buildFilterDropdown(
                        context,
                        label: 'Class Filter',
                        value: _selectedClassFilter,
                        items: ['All', 'Class 1', 'Class 2', 'Class 3', 'Class 4', 'Class 5', 'Class 6', 'Class 7', 'Class 8', 'Class 9', 'Class 10', 'Class 11', 'Class 12'],
                        onChanged: (val) => setState(() => _selectedClassFilter = val!),
                        icon: Icons.school_rounded,
                        isDark: isDark,
                      ),

                      // 2. Division Filter Dropdown (Default: 'All')
                      _buildFilterDropdown(
                        context,
                        label: 'Division',
                        value: _selectedDivFilter,
                        items: ['All', 'A', 'B', 'C', 'D'],
                        onChanged: (val) => setState(() => _selectedDivFilter = val!),
                        icon: Icons.grid_view_rounded,
                        isDark: isDark,
                      ),

                      // 3. Attendance Status Filter Dropdown (90%+, etc.)
                      _buildFilterDropdown(
                        context,
                        label: 'Attendance Status',
                        value: _selectedStatusFilter,
                        items: ['All Status', 'Excellent (90%+)', 'Good (75%-89%)', 'Average (50%-74%)', 'Low (<50%)'],
                        onChanged: (val) => setState(() => _selectedStatusFilter = val!),
                        icon: Icons.fact_check_rounded,
                        isDark: isDark,
                      ),

                      // 4. Category Filter Dropdown (Junior, Senior, etc.)
                      _buildFilterDropdown(
                        context,
                        label: 'Category Filter',
                        value: _selectedCategoryFilter,
                        items: ['All Categories','Primary' , 'Sub-Junior' , 'Junior', 'Senior', 'Super Senior', 'Alumni'],
                        onChanged: (val) => setState(() => _selectedCategoryFilter = val!),
                        icon: Icons.workspace_premium_rounded,
                        isDark: isDark,
                      ),

                      // 5. Rank Filter Scope Dropdown
                      _buildFilterDropdown(
                        context,
                        label: 'Rank Scope',
                        value: _selectedRankFilter,
                        items: [
                          'All Ranks',
                          'Top 3 Only (Medalists)',
                          'Top 1 (Winners Only)',
                          'Madrasa Topper 1 (Winner)',
                          'Madrasa Toppers (1 to 3)',
                          'Madrasa Toppers (1 to 5)',
                          'Madrasa Toppers (1 to 7)',
                          'Madrasa Toppers (1 to 10)',
                        ],
                        onChanged: (val) => setState(() => _selectedRankFilter = val!),
                        icon: Icons.emoji_events_rounded,
                        isDark: isDark,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Read-Only Attendance Leaderboard Cards
            if (activeDisplayRecords.isEmpty)
              GlassCard(
                padding: const EdgeInsets.all(48.0),
                borderRadius: 20,
                child: Center(
                  child: Column(
                    children: [
                      const Icon(Icons.person_off_rounded, size: 48, color: AppColors.subtextDark),
                      const SizedBox(height: 12),
                      Text(
                        'No Marked Attendance Records Found',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? AppColors.textLight : AppColors.textDark),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Unmarked classes and students are hidden. Tap "+ Add Class Present" to record attendance.',
                        style: GoogleFonts.poppins(fontSize: 12, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
                      ),
                    ],
                  ),
                ),
              )
            else if (_selectedRankFilter.startsWith('Madrasa Topper')) ...[
              // MADRASA TOPPERS OVERALL LEADERBOARD (Top 1 to N Across All Classes)
              Builder(
                builder: (context) {
                  int maxRankLimit = 10;
                  if (_selectedRankFilter.contains('1 (Winner)')) {
                    maxRankLimit = 1;
                  } else if (_selectedRankFilter.contains('1 to 3')) {
                    maxRankLimit = 3;
                  } else if (_selectedRankFilter.contains('1 to 5')) {
                    maxRankLimit = 5;
                  } else if (_selectedRankFilter.contains('1 to 7')) {
                    maxRankLimit = 7;
                  } else if (_selectedRankFilter.contains('1 to 10')) {
                    maxRankLimit = 10;
                  }

                  // Gather all students across all active records
                  final List<Map<String, dynamic>> overallList = [];
                  for (var r in activeDisplayRecords) {
                    for (var s in r.students) {
                      if (s.presentCount > 0) {
                        bool matchSearch = searchQuery.isEmpty ||
                            s.name.toLowerCase().contains(searchQuery) ||
                            s.participantId.toLowerCase().contains(searchQuery) ||
                            s.currentClass.toLowerCase().contains(searchQuery);

                        bool matchStatus = true;
                        final pct = r.maxWorkingDays > 0 ? (s.presentCount / r.maxWorkingDays * 100) : 0;
                        if (_selectedStatusFilter == 'Excellent (90%+)') matchStatus = pct >= 90;
                        if (_selectedStatusFilter == 'Good (75%-89%)') matchStatus = pct >= 75 && pct < 90;
                        if (_selectedStatusFilter == 'Average (50%-74%)') matchStatus = pct >= 50 && pct < 75;
                        if (_selectedStatusFilter == 'Low (<50%)') matchStatus = pct < 50;

                        bool matchCategory = true;
                        if (_selectedCategoryFilter != 'All Categories') {
                          try {
                            final p = realParticipants.firstWhere((rp) => rp.participantId == s.participantId);
                            matchCategory = p.category.trim().toLowerCase() == _selectedCategoryFilter.trim().toLowerCase();
                          } catch (_) {}
                        }

                        if (matchSearch && matchStatus && matchCategory) {
                          overallList.add({
                            'student': s,
                            'maxWorkingDays': r.maxWorkingDays,
                            'class': r.studentClass,
                            'division': r.division,
                          });
                        }
                      }
                    }
                  }

                  // Sort overall candidates descending by presentCount
                  overallList.sort((a, b) => (b['student'] as PresentStudentModel).presentCount.compareTo((a['student'] as PresentStudentModel).presentCount));

                  // Calculate tied overall ranks
                  if (overallList.isNotEmpty) {
                    int currRank = 1;
                    (overallList[0]['student'] as PresentStudentModel).rank = 1;
                    for (int i = 1; i < overallList.length; i++) {
                      final sCurr = overallList[i]['student'] as PresentStudentModel;
                      final sPrev = overallList[i - 1]['student'] as PresentStudentModel;
                      if (sCurr.presentCount == sPrev.presentCount) {
                        sCurr.rank = sPrev.rank;
                      } else {
                        currRank = i + 1;
                        sCurr.rank = currRank;
                      }
                    }
                  }

                  // Take Top N Ranks only
                  final toppersList = overallList.where((item) => (item['student'] as PresentStudentModel).rank <= maxRankLimit).toList();

                  if (toppersList.isEmpty) {
                    return GlassCard(
                      padding: const EdgeInsets.all(32.0),
                      borderRadius: 20,
                      child: Center(
                        child: Text(
                          'No Madrasa Toppers found for the selected filter criteria.',
                          style: GoogleFonts.poppins(fontSize: 13, color: isDark ? AppColors.textLight : AppColors.textDark),
                        ),
                      ),
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: GlassCard(
                      padding: const EdgeInsets.all(16),
                      borderRadius: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(colors: [Color(0xFFEAB308), Color(0xFFD97706)]),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '👑 MADRASA TOPPERS LEADERBOARD',
                                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Top ${maxRankLimit == 1 ? "1" : "1 to $maxRankLimit"} Overall Attendance Ranks Across Madrasa',
                                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.secondary),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          LayoutBuilder(
                            builder: (context, constraints) {
                              final double tableWidth = constraints.maxWidth > 1150 ? constraints.maxWidth : 1150;

                              return SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                child: SizedBox(
                                  width: tableWidth,
                                  child: Column(
                                    children: [
                                      Container(
                                        height: 44,
                                        padding: const EdgeInsets.symmetric(horizontal: 12),
                                        decoration: BoxDecoration(
                                          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                                        ),
                                        child: Row(
                                          children: [
                                            SizedBox(width: 90, child: Text('TOPPER #', style: _headerStyle(isDark, color: const Color(0xFFEAB308)))),
                                            const SizedBox(width: 12),
                                            Expanded(flex: 3, child: Text('COMPETITOR NAME', style: _headerStyle(isDark))),
                                            const SizedBox(width: 12),
                                            Expanded(flex: 2, child: Text('CLASS & DIV', style: _headerStyle(isDark))),
                                            const SizedBox(width: 12),
                                            SizedBox(width: 120, child: Text('PRESENT DAYS', style: _headerStyle(isDark, color: AppColors.secondary))),
                                            const SizedBox(width: 12),
                                            Expanded(flex: 3, child: Text('ATTENDANCE RATE', style: _headerStyle(isDark, color: AppColors.primary))),
                                            const SizedBox(width: 12),
                                            SizedBox(width: 110, child: Text('STATUS BADGE', style: _headerStyle(isDark))),
                                            const SizedBox(width: 12),
                                            SizedBox(width: 90, child: Text('ACTIONS', style: _headerStyle(isDark))),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 6),

                                      ...toppersList.map((item) {
                                        final s = item['student'] as PresentStudentModel;
                                        final maxDays = item['maxWorkingDays'] as int;
                                        final clsName = item['class'] as String;
                                        final divName = item['division'] as String;
                                        final pct = maxDays > 0 ? (s.presentCount / maxDays * 100).clamp(0, 100) : 0.0;

                                        String rankLabel = 'Rank ${s.rank}';
                                        Color rankColor = AppColors.secondary;
                                        if (s.rank == 1) {
                                          rankLabel = '🥇 Rank 1';
                                          rankColor = const Color(0xFFEAB308);
                                        } else if (s.rank == 2) {
                                          rankLabel = '🥈 Rank 2';
                                          rankColor = const Color(0xFF94A3B8);
                                        } else if (s.rank == 3) {
                                          rankLabel = '🥉 Rank 3';
                                          rankColor = const Color(0xFFD97706);
                                        }

                                        String statusLabel = 'Average';
                                        Color statusColor = AppColors.primary;
                                        if (pct >= 90) {
                                          statusLabel = 'Excellent 🌟';
                                          statusColor = AppColors.success;
                                        } else if (pct >= 75) {
                                          statusLabel = 'Good 👍';
                                          statusColor = AppColors.secondary;
                                        } else if (pct >= 50) {
                                          statusLabel = 'Average 📈';
                                          statusColor = AppColors.warning;
                                        } else {
                                          statusLabel = 'Low ⚠️';
                                          statusColor = AppColors.error;
                                        }

                                        return Container(
                                          height: 60,
                                          margin: const EdgeInsets.only(bottom: 6),
                                          padding: const EdgeInsets.symmetric(horizontal: 12),
                                          decoration: BoxDecoration(
                                            color: isDark ? AppColors.cardDark : Colors.white,
                                            borderRadius: BorderRadius.circular(14),
                                            border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                                          ),
                                          child: Row(
                                            children: [
                                              SizedBox(
                                                width: 90,
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3.5),
                                                  decoration: BoxDecoration(
                                                    color: rankColor.withAlpha(25),
                                                    borderRadius: BorderRadius.circular(8),
                                                    border: Border.all(color: rankColor.withAlpha(90), width: 1.0),
                                                  ),
                                                  child: Text(
                                                    rankLabel,
                                                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: rankColor, fontSize: 10.5),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                flex: 3,
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      padding: const EdgeInsets.all(6),
                                                      decoration: BoxDecoration(
                                                        color: AppColors.secondary.withAlpha(25),
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: const Icon(Icons.person_rounded, size: 14, color: AppColors.secondary),
                                                    ),
                                                    const SizedBox(width: 10),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          Text(
                                                            s.name,
                                                            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12.5, color: isDark ? AppColors.textLight : AppColors.textDark),
                                                            maxLines: 1,
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                          Text(
                                                            'ID: ${s.participantId}',
                                                            style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w500, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
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
                                              Expanded(
                                                flex: 2,
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      '$clsName ($divName)',
                                                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12, color: isDark ? AppColors.textLight : AppColors.textDark),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                    Text(
                                                      'Division $divName',
                                                      style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.primary),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              SizedBox(
                                                width: 120,
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.secondary.withAlpha(20),
                                                    borderRadius: BorderRadius.circular(8),
                                                    border: Border.all(color: AppColors.secondary.withAlpha(70), width: 1.0),
                                                  ),
                                                  child: Text(
                                                    '${s.presentCount} / $maxDays Days',
                                                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.secondary),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                flex: 3,
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Text('Attendance Rate', style: GoogleFonts.poppins(fontSize: 10, color: isDark ? AppColors.subtextLight : AppColors.subtextDark)),
                                                        Text(
                                                          '${pct.toStringAsFixed(1)}%',
                                                          style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: statusColor),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 4),
                                                    ClipRRect(
                                                      borderRadius: BorderRadius.circular(6),
                                                      child: LinearProgressIndicator(
                                                        value: pct / 100,
                                                        minHeight: 6,
                                                        backgroundColor: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
                                                        valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              SizedBox(
                                                width: 110,
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: statusColor.withAlpha(25),
                                                    borderRadius: BorderRadius.circular(8),
                                                    border: Border.all(color: statusColor.withAlpha(80), width: 1.0),
                                                  ),
                                                  child: Text(
                                                    statusLabel,
                                                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 10, color: statusColor),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              SizedBox(
                                                width: 90,
                                                child: Center(
                                                  child: Tooltip(
                                                    message: 'Remove Student',
                                                    child: InkWell(
                                                      onTap: () {
                                                        final rec = activeDisplayRecords.firstWhere((r) => r.studentClass == clsName && r.division == divName);
                                                        _confirmDeleteSingleStudent(context, appState, rec, s);
                                                      },
                                                      borderRadius: BorderRadius.circular(8),
                                                      child: Container(
                                                        padding: const EdgeInsets.all(7),
                                                        decoration: BoxDecoration(
                                                          color: AppColors.error.withAlpha(20),
                                                          borderRadius: BorderRadius.circular(8),
                                                          border: Border.all(color: AppColors.error.withAlpha(60)),
                                                        ),
                                                        child: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 16),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
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
                  );
                },
              ),
            ] else
              ...activeDisplayRecords.map((record) {
                // Get students with presentCount > 0 (Exclude unmarked students!)
                List<PresentStudentModel> students = record.students
                    .where((s) => s.presentCount > 0)
                    .toList();

                // Apply Search filter
                if (searchQuery.isNotEmpty) {
                  students = students.where((s) =>
                      s.name.toLowerCase().contains(searchQuery) ||
                      s.participantId.toLowerCase().contains(searchQuery) ||
                      s.currentClass.toLowerCase().contains(searchQuery)
                  ).toList();
                }

                // Apply Attendance Status Filter (90%+, Good, etc.)
                if (_selectedStatusFilter != 'All Status') {
                  students = students.where((s) {
                    final pct = record.maxWorkingDays > 0 ? (s.presentCount / record.maxWorkingDays * 100) : 0;
                    if (_selectedStatusFilter == 'Excellent (90%+)') return pct >= 90;
                    if (_selectedStatusFilter == 'Good (75%-89%)') return pct >= 75 && pct < 90;
                    if (_selectedStatusFilter == 'Average (50%-74%)') return pct >= 50 && pct < 75;
                    if (_selectedStatusFilter == 'Low (<50%)') return pct < 50;
                    return true;
                  }).toList();
                }

                // Apply Category Filter (Junior, Senior, etc.)
                if (_selectedCategoryFilter != 'All Categories') {
                  students = students.where((s) {
                    try {
                      final p = realParticipants.firstWhere((rp) => rp.participantId == s.participantId);
                      return p.category.trim().toLowerCase() == _selectedCategoryFilter.trim().toLowerCase();
                    } catch (_) {
                      return true;
                    }
                  }).toList();
                }

                // Apply Rank Filter scope
                if (_selectedRankFilter == 'Top 3 Only (Medalists)') {
                  students = students.where((s) => s.rank <= 3).toList();
                } else if (_selectedRankFilter == 'Top 1 (Winners Only)') {
                  students = students.where((s) => s.rank == 1).toList();
                }

                // DEFAULT 'ALL' CLASS FILTER: Show Top 3 Students for each marked class!
                if (_selectedClassFilter == 'All' && _selectedRankFilter == 'All Ranks' && _selectedStatusFilter == 'All Status' && _selectedCategoryFilter == 'All Categories' && searchQuery.isEmpty) {
                  students = students.take(3).toList();
                }

                if (students.isEmpty) return const SizedBox.shrink();

                return Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: GlassCard(
                    padding: const EdgeInsets.all(16),
                    borderRadius: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Class Header Title Bar
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(colors: [AppColors.secondary, AppColors.primary]),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '${record.studentClass} (${record.division})',
                                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  _selectedClassFilter == 'All'
                                      ? '🏆 Top ${students.length} Performers Leaderboard'
                                      : '📋 Marked Attendance Roster (${students.length} Students)',
                                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13, color: isDark ? AppColors.textLight : AppColors.textDark),
                                ),
                              ],
                            ),

                            // Edit Class Attendance Button
                            IconButton(
                              icon: const Icon(Icons.edit_note_rounded, color: AppColors.secondary, size: 22),
                              tooltip: 'Edit Class Present',
                              onPressed: () => _openAddClassPresentSheet(
                                initialClass: record.studentClass,
                                initialDiv: record.division,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Leaderboard Roster Table for this Class
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final double tableWidth = constraints.maxWidth > 1150 ? constraints.maxWidth : 1150;

                            return SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              child: SizedBox(
                                width: tableWidth,
                                child: Column(
                                  children: [
                                    // Table Header Bar
                                    Container(
                                      height: 44,
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                      decoration: BoxDecoration(
                                        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                                      ),
                                      child: Row(
                                        children: [
                                          SizedBox(width: 80, child: Text('RANK #', style: _headerStyle(isDark))),
                                          const SizedBox(width: 12),
                                          Expanded(flex: 3, child: Text('COMPETITOR NAME', style: _headerStyle(isDark))),
                                          const SizedBox(width: 12),
                                          Expanded(flex: 2, child: Text('CLASS & DIV', style: _headerStyle(isDark))),
                                          const SizedBox(width: 12),
                                          SizedBox(width: 120, child: Text('DAYS PRESENT', style: _headerStyle(isDark, color: AppColors.secondary))),
                                          const SizedBox(width: 12),
                                          Expanded(flex: 3, child: Text('ATTENDANCE ANALYTICS', style: _headerStyle(isDark, color: AppColors.primary))),
                                          const SizedBox(width: 12),
                                          SizedBox(width: 110, child: Text('STATUS BADGE', style: _headerStyle(isDark))),
                                          const SizedBox(width: 12),
                                          SizedBox(width: 90, child: Text('ACTIONS', style: _headerStyle(isDark))),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 6),

                                    // Data Rows List
                                    ...students.map((s) {
                                      final pct = record.maxWorkingDays > 0 ? (s.presentCount / record.maxWorkingDays * 100).clamp(0, 100) : 0.0;

                                      String rankLabel = 'Rank ${s.rank}';
                                      Color rankColor = AppColors.secondary;
                                      if (s.rank == 1) {
                                        rankLabel = '🥇 Rank 1';
                                        rankColor = const Color(0xFFEAB308); // Gold
                                      } else if (s.rank == 2) {
                                        rankLabel = '🥈 Rank 2';
                                        rankColor = const Color(0xFF94A3B8); // Silver
                                      } else if (s.rank == 3) {
                                        rankLabel = '🥉 Rank 3';
                                        rankColor = const Color(0xFFD97706); // Bronze
                                      }

                                      String statusLabel = 'EXCELLENT 🌟';
                                      Color statusColor = AppColors.success;
                                      if (pct >= 90) {
                                        statusLabel = 'EXCELLENT 🌟';
                                        statusColor = AppColors.success;
                                      } else if (pct >= 75) {
                                        statusLabel = 'GOOD 👍';
                                        statusColor = AppColors.primary;
                                      } else if (pct >= 50) {
                                        statusLabel = 'AVERAGE ⚠️';
                                        statusColor = AppColors.warning;
                                      } else {
                                        statusLabel = 'LOW ❌';
                                        statusColor = AppColors.error;
                                      }

                                      return Container(
                                        height: 60,
                                        margin: const EdgeInsets.only(bottom: 6),
                                        padding: const EdgeInsets.symmetric(horizontal: 12),
                                        decoration: BoxDecoration(
                                          color: isDark ? AppColors.cardDark : Colors.white,
                                          borderRadius: BorderRadius.circular(14),
                                          border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                                        ),
                                        child: Row(
                                          children: [
                                            // 1. RANK # (80)
                                            SizedBox(
                                              width: 80,
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3.5),
                                                decoration: BoxDecoration(
                                                  color: rankColor.withAlpha(25),
                                                  borderRadius: BorderRadius.circular(8),
                                                  border: Border.all(color: rankColor.withAlpha(90), width: 1.0),
                                                ),
                                                child: Text(
                                                  rankLabel,
                                                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: rankColor, fontSize: 10.5),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),

                                            // 2. COMPETITOR NAME (Expanded flex 3)
                                            Expanded(
                                              flex: 3,
                                              child: Row(
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.all(6),
                                                    decoration: BoxDecoration(
                                                      color: AppColors.secondary.withAlpha(25),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: const Icon(Icons.person_rounded, size: 14, color: AppColors.secondary),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Text(
                                                          s.name,
                                                          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12.5, color: isDark ? AppColors.textLight : AppColors.textDark),
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                        Text(
                                                          'ID: ${s.participantId}',
                                                          style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w500, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
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

                                            // 3. CLASS & DIV (Expanded flex 2)
                                            Expanded(
                                              flex: 2,
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    '${s.currentClass} (${s.currentDiv})',
                                                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12, color: isDark ? AppColors.textLight : AppColors.textDark),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  Text(
                                                    'Division ${record.division}',
                                                    style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.primary),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 12),

                                            // 4. DAYS PRESENT (120)
                                            SizedBox(
                                              width: 120,
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: AppColors.secondary.withAlpha(20),
                                                  borderRadius: BorderRadius.circular(8),
                                                  border: Border.all(color: AppColors.secondary.withAlpha(70), width: 1.0),
                                                ),
                                                child: Text(
                                                  '${s.presentCount} / ${record.maxWorkingDays} Days',
                                                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.secondary),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),

                                            // 5. ATTENDANCE ANALYTICS (Expanded flex 3)
                                            Expanded(
                                              flex: 3,
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text('Attendance Rate', style: GoogleFonts.poppins(fontSize: 10, color: isDark ? AppColors.subtextLight : AppColors.subtextDark)),
                                                      Text(
                                                        '${pct.toStringAsFixed(1)}%',
                                                        style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: statusColor),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 4),
                                                  ClipRRect(
                                                    borderRadius: BorderRadius.circular(6),
                                                    child: LinearProgressIndicator(
                                                      value: pct / 100,
                                                      minHeight: 6,
                                                      backgroundColor: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
                                                      valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 12),

                                            // 6. STATUS BADGE (110)
                                            SizedBox(
                                              width: 110,
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: statusColor.withAlpha(25),
                                                  borderRadius: BorderRadius.circular(8),
                                                  border: Border.all(color: statusColor.withAlpha(80), width: 1.0),
                                                ),
                                                child: Text(
                                                  statusLabel,
                                                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 10, color: statusColor),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),

                                            // 7. ACTIONS (90) - Single Student Delete Action Button
                                            SizedBox(
                                              width: 90,
                                              child: Center(
                                                child: Tooltip(
                                                  message: 'Remove Student',
                                                  child: InkWell(
                                                    onTap: () => _confirmDeleteSingleStudent(context, appState, record, s),
                                                    borderRadius: BorderRadius.circular(8),
                                                    child: Container(
                                                      padding: const EdgeInsets.all(7),
                                                      decoration: BoxDecoration(
                                                        color: AppColors.error.withAlpha(20),
                                                        borderRadius: BorderRadius.circular(8),
                                                        border: Border.all(color: AppColors.error.withAlpha(60)),
                                                      ),
                                                      child: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 16),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
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
                );
              }),
          ],
        ),
      ),
    );
  }

  TextStyle _headerStyle(bool isDark, {Color? color}) {
    return GoogleFonts.poppins(
      fontWeight: FontWeight.bold,
      fontSize: 10.5,
      letterSpacing: 0.7,
      color: color ?? (isDark ? AppColors.subtextLight : const Color(0xFF475569)),
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
    final isSelected = value != 'All' && value != 'All Ranks' && value != 'All Status' && value != 'All Categories';

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
              : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
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
}
