import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/providers/app_state.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/glass_card.dart';

class ParticipantsScreen extends StatefulWidget {
  const ParticipantsScreen({super.key});

  @override
  State<ParticipantsScreen> createState() => _ParticipantsScreenState();
}

class _ParticipantsScreenState extends State<ParticipantsScreen> {
  bool _isGridView = true;

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDark = appState.isDarkMode;
    final participants = appState.participants;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Participant Directory',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.textLight : AppColors.textDark,
                      ),
                    ),
                    Text(
                      'List of registered students, items, and assigned madrasas.',
                      style: GoogleFonts.poppins(fontSize: 13, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
                    ),
                  ],
                ),

                // Grid / Table View Toggle
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.grid_view_rounded, color: _isGridView ? AppColors.primary : AppColors.subtextDark),
                        onPressed: () => setState(() => _isGridView = true),
                        tooltip: 'Grid Card View',
                      ),
                      IconButton(
                        icon: Icon(Icons.table_rows_rounded, color: !_isGridView ? AppColors.primary : AppColors.subtextDark),
                        onPressed: () => setState(() => _isGridView = false),
                        tooltip: 'Table List View',
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            if (_isGridView)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 320,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  childAspectRatio: 0.85,
                ),
                itemCount: participants.length,
                itemBuilder: (context, idx) {
                  final part = participants[idx];
                  return GlassCard(
                    borderRadius: 20,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundImage: NetworkImage(part.photoUrl),
                          backgroundColor: AppColors.primary.withAlpha(40),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          part.name,
                          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15, color: isDark ? AppColors.textLight : AppColors.textDark),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withAlpha(25),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(part.studentClass, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary)),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          part.item,
                          style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.secondary),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          part.madrasaName,
                          style: GoogleFonts.poppins(fontSize: 11, color: AppColors.subtextDark),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              )
            else
              GlassCard(
                padding: EdgeInsets.zero,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Student')),
                    DataColumn(label: Text('Class')),
                    DataColumn(label: Text('Category')),
                    DataColumn(label: Text('Item')),
                    DataColumn(label: Text('Madrasa')),
                  ],
                  rows: participants.map((p) {
                    return DataRow(cells: [
                      DataCell(Text(p.name)),
                      DataCell(Text(p.studentClass)),
                      DataCell(Text(p.category)),
                      DataCell(Text(p.item)),
                      DataCell(Text(p.madrasaName)),
                    ]);
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
