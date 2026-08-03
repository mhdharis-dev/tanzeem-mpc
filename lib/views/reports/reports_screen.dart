import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/models/models.dart';
import '../../core/providers/app_state.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/glass_card.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _selectedReportType = 'Overall System Summary';

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDark = appState.isDarkMode;
    final isSuperAdmin = appState.userRole == 'Super Admin';

    // Metrics calculations
    final totalMadrasas = appState.madrasas.length;
    final onlineCoordinators = appState.madrasas.where((m) => m.isOnline).length;
    final totalPrograms = appState.programs.length;
    final completedPrograms = appState.programs.where((p) => p.status == ProgramStatus.completed).length;
    final livePrograms = appState.programs.where((p) => p.status == ProgramStatus.live).length;
    final pendingPrograms = appState.programs.where((p) => p.status == ProgramStatus.pending).length;
    final totalParticipants = appState.participants.length;

    final finishRate = totalPrograms > 0 ? ((completedPrograms / totalPrograms) * 100).toStringAsFixed(1) : '0.0';

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(28.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header Banner & Actions Shell
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 20,
              runSpacing: 14,
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
                          child: const Icon(Icons.analytics_rounded, color: AppColors.primary, size: 28),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isSuperAdmin ? 'Super Admin System Audit Reports' : 'Meelad Festival Reports & Analytics',
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppColors.textLight : AppColors.textDark,
                              ),
                            ),
                            Text(
                              'Comprehensive real-time analytics, Madrasa participation metrics, and printable PDF exports.',
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
                    OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('📊 Exporting Madrasa Cluster Excel Spreadsheet...'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      },
                      icon: const Icon(Icons.table_chart_rounded, color: AppColors.success, size: 18),
                      label: const Text('Export Excel'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        side: const BorderSide(color: AppColors.success),
                        foregroundColor: AppColors.success,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('📄 Generating Printable Executive Audit PDF Report...'),
                            backgroundColor: AppColors.primary,
                          ),
                        );
                      },
                      icon: const Icon(Icons.picture_as_pdf_rounded, size: 18),
                      label: const Text('Generate Printable PDF'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 28),

            // Top Executive KPI Metric Cards Grid
            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth > 1100
                    ? 4
                    : constraints.maxWidth > 700
                        ? 2
                        : 1;

                return GridView.count(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 18,
                  mainAxisSpacing: 18,
                  mainAxisExtent: 105,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildExecutiveKpiCard(
                      title: 'Registered Madrasas',
                      value: '$totalMadrasas',
                      subtitle: '🟢 $onlineCoordinators Active Online',
                      icon: Icons.domain_rounded,
                      color: AppColors.primary,
                      isDark: isDark,
                    ),
                    _buildExecutiveKpiCard(
                      title: 'Total Meelad Programs',
                      value: '$totalPrograms',
                      subtitle: '$completedPrograms Finish ($finishRate%)',
                      icon: Icons.assignment_rounded,
                      color: AppColors.secondary,
                      isDark: isDark,
                    ),
                    _buildExecutiveKpiCard(
                      title: 'Student Competitors',
                      value: '$totalParticipants',
                      subtitle: 'Sub-Junior to Senior',
                      icon: Icons.groups_rounded,
                      color: AppColors.accent,
                      isDark: isDark,
                    ),
                    _buildExecutiveKpiCard(
                      title: 'System Sync Health',
                      value: '100%',
                      subtitle: 'Cloud Firestore Live',
                      icon: Icons.verified_user_rounded,
                      color: AppColors.success,
                      isDark: isDark,
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 28),

            // Section 2: Real Madrasa Network Performance & Audit Table
            GlassCard(
              borderRadius: 24,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withAlpha(25),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.leaderboard_rounded, color: AppColors.primary, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Madrasa Network Performance & Active Audit',
                                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? AppColors.textLight : AppColors.textDark),
                              ),
                              Text(
                                'Real-time synchronization status and coordinator details per registered institute.',
                                style: GoogleFonts.poppins(fontSize: 12, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
                              ),
                            ],
                          ),
                        ],
                      ),

                      // Filter Dropdown
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedReportType,
                            dropdownColor: isDark ? AppColors.cardDark : Colors.white,
                            style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? AppColors.textLight : AppColors.textDark),
                            items: const [
                              DropdownMenuItem(value: 'Overall System Summary', child: Text('Overall System Summary')),
                              DropdownMenuItem(value: 'Online Coordinators Only', child: Text('Online Coordinators Only')),
                              DropdownMenuItem(value: 'Full Madrasa Audit List', child: Text('Full Madrasa Audit List')),
                            ],
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedReportType = val);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Madrasa Table View
                  if (appState.madrasas.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Text(
                          'No registered Madrasas found in Firestore cluster.',
                          style: GoogleFonts.poppins(fontSize: 13, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
                        ),
                      ),
                    )
                  else
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
                        dataRowMinHeight: 52,
                        dataRowMaxHeight: 56,
                        columnSpacing: 28,
                        columns: [
                          DataColumn(label: Text('Reg No', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primary))),
                          DataColumn(label: Text('Madrasa Institute', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12, color: isDark ? AppColors.textLight : AppColors.textDark))),
                          DataColumn(label: Text('Coordinator Name', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12, color: isDark ? AppColors.textLight : AppColors.textDark))),
                          DataColumn(label: Text('Portal Email', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12, color: isDark ? AppColors.textLight : AppColors.textDark))),
                          DataColumn(label: Text('Active Connection', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12, color: isDark ? AppColors.textLight : AppColors.textDark))),
                          DataColumn(label: Text('Registration Date', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12, color: isDark ? AppColors.textLight : AppColors.textDark))),
                        ],
                        rows: appState.madrasas.where((m) {
                          if (_selectedReportType == 'Online Coordinators Only') return m.isOnline;
                          return true;
                        }).map((m) {
                          return DataRow(
                            cells: [
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withAlpha(20),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(m.madrasaRegNo, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.primary)),
                                ),
                              ),
                              DataCell(
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(m.madrasaName, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13, color: isDark ? AppColors.textLight : AppColors.textDark)),
                                    Text(m.address, style: GoogleFonts.poppins(fontSize: 10, color: isDark ? AppColors.subtextLight : AppColors.subtextDark)),
                                  ],
                                ),
                              ),
                              DataCell(Text(m.coordinatorName, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? AppColors.textLight : AppColors.textDark))),
                              DataCell(Text(m.email, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.accent, fontWeight: FontWeight.w500))),
                              DataCell(
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: m.isOnline ? AppColors.success : Colors.grey,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      m.isOnline ? 'Online now' : m.lastActive,
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        fontWeight: m.isOnline ? FontWeight.bold : FontWeight.normal,
                                        color: m.isOnline ? AppColors.success : (isDark ? AppColors.subtextLight : AppColors.subtextDark),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              DataCell(Text(m.createdAt, style: GoogleFonts.poppins(fontSize: 11, color: isDark ? AppColors.subtextLight : AppColors.subtextDark))),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Section 3: Program Execution Status & Category Analytics
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 900;
                return Column(
                  children: [
                    if (isWide)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 5,
                            child: _buildProgramStatusCard(totalPrograms, completedPrograms, livePrograms, pendingPrograms, isDark),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            flex: 5,
                            child: _buildPrintableSummaryPreviewCard(appState, isDark),
                          ),
                        ],
                      )
                    else
                      Column(
                        children: [
                          _buildProgramStatusCard(totalPrograms, completedPrograms, livePrograms, pendingPrograms, isDark),
                          const SizedBox(height: 24),
                          _buildPrintableSummaryPreviewCard(appState, isDark),
                        ],
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExecutiveKpiCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return GlassCard(
      borderRadius: 18,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: GoogleFonts.poppins(fontSize: 11, color: isDark ? AppColors.subtextLight : AppColors.subtextDark)),
                Text(value, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? AppColors.textLight : AppColors.textDark)),
                Text(subtitle, style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgramStatusCard(int total, int completed, int live, int pending, bool isDark) {
    return GlassCard(
      borderRadius: 24,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.pie_chart_rounded, color: AppColors.secondary, size: 22),
              ),
              const SizedBox(width: 12),
              Text(
                'Program Execution Status',
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? AppColors.textLight : AppColors.textDark),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildStatusProgressRow('Completed Items', completed, total, AppColors.success, isDark),
          const SizedBox(height: 14),
          _buildStatusProgressRow('Live Stage On-Going', live, total, AppColors.secondary, isDark),
          const SizedBox(height: 14),
          _buildStatusProgressRow('Pending Stage Queue', pending, total, AppColors.warning, isDark),
        ],
      ),
    );
  }

  Widget _buildStatusProgressRow(String label, int count, int total, Color color, bool isDark) {
    final double pct = total > 0 ? (count / total) : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? AppColors.textLight : AppColors.textDark)),
            Text('$count / $total (${(pct * 100).toStringAsFixed(0)}%)', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 8,
            backgroundColor: color.withAlpha(30),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildPrintableSummaryPreviewCard(AppState appState, bool isDark) {
    return GlassCard(
      borderRadius: 24,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.accent.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.print_rounded, color: AppColors.accent, size: 22),
              ),
              const SizedBox(width: 12),
              Text(
                'Executive Audit Preview',
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? AppColors.textLight : AppColors.textDark),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSummaryPreviewRow('Event Title', appState.festivalName, isDark),
          const Divider(height: 16),
          _buildSummaryPreviewRow('Host Campus', appState.madrasaName, isDark),
          const Divider(height: 16),
          _buildSummaryPreviewRow('Madrasas Network', '${appState.madrasas.length} Registered Institutes', isDark),
          const Divider(height: 16),
          _buildSummaryPreviewRow('Active Coordinators', '${appState.madrasas.where((m) => m.isOnline).length} Online', isDark),
        ],
      ),
    );
  }

  Widget _buildSummaryPreviewRow(String label, String value, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 12, color: isDark ? AppColors.subtextLight : AppColors.subtextDark)),
        Text(value, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? AppColors.textLight : AppColors.textDark)),
      ],
    );
  }
}
