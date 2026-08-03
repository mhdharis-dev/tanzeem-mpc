import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/providers/app_state.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/glass_card.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

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
                      'Reports & Analytics Export',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.textLight : AppColors.textDark,
                      ),
                    ),
                    Text(
                      'Generate printable PDF schedules, Excel sheets, and category summaries.',
                      style: GoogleFonts.poppins(fontSize: 13, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
                    ),
                  ],
                ),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Exporting Excel spreadsheet...'), backgroundColor: AppColors.success),
                        );
                      },
                      icon: const Icon(Icons.table_chart_rounded, color: AppColors.success),
                      label: const Text('Export Excel'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Generating Printable PDF Report...'), backgroundColor: AppColors.primary),
                        );
                      },
                      icon: const Icon(Icons.picture_as_pdf_rounded),
                      label: const Text('Printable PDF'),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),

            GlassCard(
              borderRadius: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Festival Summary Report Preview', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? AppColors.textLight : AppColors.textDark)),
                  const SizedBox(height: 16),
                  _buildReportRow('Total Programs Scheduled', '${appState.programs.length}', isDark),
                  const Divider(),
                  _buildReportRow('Completed Performances', '${appState.programs.where((p) => p.status.name == 'completed').length}', isDark),
                  const Divider(),
                  _buildReportRow('Pending Items Remaining', '${appState.programs.where((p) => p.status.name == 'pending').length}', isDark),
                  const Divider(),
                  _buildReportRow('Participating Madrasas', '${appState.madrasas.length}', isDark),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 14, color: isDark ? AppColors.textLight : AppColors.textDark)),
          Text(value, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary)),
        ],
      ),
    );
  }
}
