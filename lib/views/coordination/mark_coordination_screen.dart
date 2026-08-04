import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/providers/app_state.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/glass_card.dart';

class MarkCoordinationScreen extends StatefulWidget {
  const MarkCoordinationScreen({super.key});

  @override
  State<MarkCoordinationScreen> createState() => _MarkCoordinationScreenState();
}

class _MarkCoordinationScreenState extends State<MarkCoordinationScreen> {
  String _selectedYear = '2026 - 2027';
  String _selectedCategory = 'All';
  String _searchQuery = '';

  // Local state for candidate evaluation marks
  final Map<String, TextEditingController> _performanceControllers = {};
  final Map<String, TextEditingController> _tajweedControllers = {};
  final Map<String, TextEditingController> _disciplineControllers = {};

  @override
  void dispose() {
    for (var c in _performanceControllers.values) {
      c.dispose();
    }
    for (var c in _tajweedControllers.values) {
      c.dispose();
    }
    for (var c in _disciplineControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _getController(Map<String, TextEditingController> map, String key, String initialVal) {
    if (!map.containsKey(key)) {
      map[key] = TextEditingController(text: initialVal);
    }
    return map[key]!;
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDark = appState.isDarkMode;

    final participants = appState.participants.where((p) {
      final q = _searchQuery.toLowerCase();
      final matchesSearch = p.name.toLowerCase().contains(q) ||
          p.item.toLowerCase().contains(q) ||
          p.madrasaName.toLowerCase().contains(q) ||
          p.category.toLowerCase().contains(q);

      if (!matchesSearch) return false;
      if (_selectedCategory != 'All' && p.studentClass.toLowerCase() != _selectedCategory.toLowerCase()) {
        return false;
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(28.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header Banner
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
                          child: const Icon(Icons.grade_rounded, color: AppColors.primary, size: 28),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Mark & Present Coordination',
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppColors.textLight : AppColors.textDark,
                              ),
                            ),
                            Text(
                              'Evaluate yearly performance, enter marks, and generate competition grades.',
                              style: GoogleFonts.poppins(fontSize: 13, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),

                // Save All & Academic Year Selectors
                Wrap(
                  spacing: 12,
                  runSpacing: 10,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedYear,
                          dropdownColor: isDark ? AppColors.cardDark : Colors.white,
                          style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                          items: const [
                            DropdownMenuItem(value: '2026 - 2027', child: Text('Academic Year 2026 - 2027')),
                            DropdownMenuItem(value: '2025 - 2026', child: Text('Academic Year 2025 - 2026')),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedYear = val);
                          },
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('✅ Yearly Coordination Marks saved successfully!'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      },
                      icon: const Icon(Icons.save_rounded, size: 18),
                      label: const Text('Save All Marks'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Search Bar & Class Filter Chips
            GlassCard(
              borderRadius: 22,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 16,
                    runSpacing: 14,
                    children: [
                      // Search Input
                      Container(
                        width: 340,
                        height: 44,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                        ),
                        child: TextField(
                          onChanged: (val) => setState(() => _searchQuery = val),
                          decoration: InputDecoration(
                            hintText: 'Search participant, item, or madrasa...',
                            hintStyle: GoogleFonts.poppins(fontSize: 12, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
                            prefixIcon: const Icon(Icons.search_rounded, size: 20),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear_rounded, size: 18),
                                    onPressed: () => setState(() => _searchQuery = ''),
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),

                      // Category Filter Chips
                      Wrap(
                        spacing: 8,
                        children: [
                          _buildFilterChip('All', 'All Classes', isDark),
                          _buildFilterChip('Sub-Junior', 'Sub-Junior', isDark),
                          _buildFilterChip('Junior', 'Junior', isDark),
                          _buildFilterChip('Senior', 'Senior', isDark),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Yearly Mark Evaluation Table Card
            GlassCard(
              borderRadius: 24,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withAlpha(25),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.fact_check_rounded, color: AppColors.accent, size: 20),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Yearly Mark Entry Roster (${participants.length} Competitors)',
                            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? AppColors.textLight : AppColors.textDark),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(20),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Max Total: 100 Marks',
                          style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  if (participants.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Center(
                        child: Text(
                          'No participants found for the selected category filter.',
                          style: GoogleFonts.poppins(fontSize: 13, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
                        ),
                      ),
                    )
                  else
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: DataTable(
                        headingRowHeight: 46,
                        dataRowMinHeight: 64,
                        dataRowMaxHeight: 70,
                        headingRowColor: WidgetStateProperty.all(isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
                        columnSpacing: 24,
                        columns: [
                          DataColumn(label: Text('Competitor Name', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12, color: isDark ? AppColors.textLight : AppColors.textDark))),
                          DataColumn(label: Text('Class & Event', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12, color: isDark ? AppColors.textLight : AppColors.textDark))),
                          DataColumn(label: Text('Performance (50)', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primary))),
                          DataColumn(label: Text('Tajweed (30)', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.secondary))),
                          DataColumn(label: Text('Discipline (20)', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.accent))),
                          DataColumn(label: Text('Total Score', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.success))),
                          DataColumn(label: Text('Grade', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12, color: isDark ? AppColors.textLight : AppColors.textDark))),
                        ],
                        rows: participants.map((p) {
                          final perfCtrl = _getController(_performanceControllers, '${p.id}_perf', '42');
                          final tajCtrl = _getController(_tajweedControllers, '${p.id}_taj', '26');
                          final discCtrl = _getController(_disciplineControllers, '${p.id}_disc', '18');

                          final perfVal = double.tryParse(perfCtrl.text) ?? 0;
                          final tajVal = double.tryParse(tajCtrl.text) ?? 0;
                          final discVal = double.tryParse(discCtrl.text) ?? 0;

                          final total = (perfVal + tajVal + discVal).clamp(0, 100).toInt();

                          String grade = 'A+';
                          Color gradeColor = AppColors.success;
                          if (total >= 90) {
                            grade = 'A+ 🥇';
                            gradeColor = AppColors.success;
                          } else if (total >= 80) {
                            grade = 'A 🥈';
                            gradeColor = AppColors.primary;
                          } else if (total >= 70) {
                            grade = 'B+ 🥉';
                            gradeColor = AppColors.accent;
                          } else if (total >= 60) {
                            grade = 'B';
                            gradeColor = AppColors.warning;
                          } else {
                            grade = 'C';
                            gradeColor = Colors.grey;
                          }

                          return DataRow(
                            cells: [
                              DataCell(
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(p.name, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13, color: isDark ? AppColors.textLight : AppColors.textDark)),
                                    Text(p.madrasaName, style: GoogleFonts.poppins(fontSize: 10, color: isDark ? AppColors.subtextLight : AppColors.subtextDark)),
                                  ],
                                ),
                              ),
                              DataCell(
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(p.item, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 12, color: AppColors.primary)),
                                    Text('${p.studentClass} • ${p.category}', style: GoogleFonts.poppins(fontSize: 10, color: isDark ? AppColors.subtextLight : AppColors.subtextDark)),
                                  ],
                                ),
                              ),
                              DataCell(_buildNumberInputField(perfCtrl)),
                              DataCell(_buildNumberInputField(tajCtrl)),
                              DataCell(_buildNumberInputField(discCtrl)),
                              DataCell(
                                Text(
                                  '$total / 100',
                                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.success),
                                ),
                              ),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: gradeColor.withAlpha(25),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: gradeColor.withAlpha(80)),
                                  ),
                                  child: Text(
                                    grade,
                                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 11, color: gradeColor),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String filterKey, String label, bool isDark) {
    final isSelected = _selectedCategory == filterKey;
    return ChoiceChip(
      label: Text(label, style: GoogleFonts.poppins(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() => _selectedCategory = filterKey);
        }
      },
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(color: isSelected ? Colors.white : (isDark ? AppColors.textLight : AppColors.textDark)),
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Widget _buildNumberInputField(TextEditingController controller) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 70,
      height: 38,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? AppColors.textLight : AppColors.textDark),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 8),
        ),
        onChanged: (_) => setState(() {}),
      ),
    );
  }
}
