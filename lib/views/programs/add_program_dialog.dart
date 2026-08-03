import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/models/models.dart';
import '../../core/providers/app_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/dummy_data.dart';

class AddProgramDialog extends StatefulWidget {
  const AddProgramDialog({super.key});

  @override
  State<AddProgramDialog> createState() => _AddProgramDialogState();
}

class _AddProgramDialogState extends State<AddProgramDialog> {
  final _formKey = GlobalKey<FormState>();
  final _studentNameController = TextEditingController();
  final _itemController = TextEditingController();
  final _teacherController = TextEditingController();
  final _durationController = TextEditingController(text: '12');
  final _remarksController = TextEditingController();

  String _selectedClass = DummyData.classes[0];
  String _selectedCategory = DummyData.categories[0];
  String _selectedStage = DummyData.stages[0];
  String _priority = 'Normal';

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDark = appState.isDarkMode;

    return Dialog(
      backgroundColor: isDark ? AppColors.cardDark : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 680),
        padding: const EdgeInsets.all(28),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withAlpha(30),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.note_add_rounded, color: AppColors.primary, size: 24),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Add New Meelad Program',
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppColors.textLight : AppColors.textDark,
                              ),
                            ),
                            Text(
                              'Register participant performance details for festival schedule.',
                              style: GoogleFonts.poppins(fontSize: 12, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(height: 32),

                // Form Fields Grid
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Student Name', isDark),
                          TextFormField(
                            controller: _studentNameController,
                            validator: (v) => v == null || v.isEmpty ? 'Enter student name' : null,
                            decoration: const InputDecoration(hintText: 'e.g. Abdullah Ibn Umar'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Class Category', isDark),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedClass,
                            items: DummyData.classes
                                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                                .toList(),
                            onChanged: (val) => setState(() => _selectedClass = val!),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Competition Category', isDark),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedCategory,
                            items: DummyData.categories
                                .map((cat) => DropdownMenuItem(value: cat, child: Text(cat, overflow: TextOverflow.ellipsis)))
                                .toList(),
                            onChanged: (val) => setState(() => _selectedCategory = val!),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Item / Topic Name', isDark),
                          TextFormField(
                            controller: _itemController,
                            validator: (v) => v == null || v.isEmpty ? 'Enter item name' : null,
                            decoration: const InputDecoration(hintText: 'e.g. Surah Yasin Recitation'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Assigned Teacher / Usthad', isDark),
                          TextFormField(
                            controller: _teacherController,
                            decoration: const InputDecoration(hintText: 'e.g. Usthad Ahmed Musliyar'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Duration (Minutes)', isDark),
                          TextFormField(
                            controller: _durationController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(hintText: '12'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Stage Venue', isDark),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedStage,
                            items: DummyData.stages
                                .map((stg) => DropdownMenuItem(value: stg, child: Text(stg)))
                                .toList(),
                            onChanged: (val) => setState(() => _selectedStage = val!),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Priority Level', isDark),
                          DropdownButtonFormField<String>(
                            initialValue: _priority,
                            items: ['High', 'Normal', 'Low']
                                .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                                .toList(),
                            onChanged: (val) => setState(() => _priority = val!),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                _buildLabel('Remarks / Technical Setup Notes', isDark),
                TextFormField(
                  controller: _remarksController,
                  maxLines: 2,
                  decoration: const InputDecoration(hintText: 'e.g. Requires dual podium mic, projector screen, etc.'),
                ),

                const SizedBox(height: 28),

                // Form Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () => _submitForm(context, appState, keepOpen: true),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
                      child: const Text('Save & Add Next'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () => _submitForm(context, appState, keepOpen: false),
                      child: const Text('Save Program'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: 13,
          color: isDark ? AppColors.textLight : AppColors.textDark,
        ),
      ),
    );
  }

  void _submitForm(BuildContext context, AppState appState, {required bool keepOpen}) {
    if (_formKey.currentState!.validate()) {
      final newProg = Program(
        id: 'p_${DateTime.now().millisecondsSinceEpoch}',
        number: 'PRG-${appState.programs.length + 101}',
        studentName: _studentNameController.text.trim(),
        studentPhoto: 'https://i.pravatar.cc/150?img=${(appState.programs.length % 70) + 1}',
        studentClass: _selectedClass,
        category: _selectedCategory,
        item: _itemController.text.trim(),
        durationMinutes: int.tryParse(_durationController.text) ?? 12,
        stage: _selectedStage,
        status: ProgramStatus.pending,
        startTime: '11:00 AM',
        teacher: _teacherController.text.isEmpty ? 'Usthad Main' : _teacherController.text,
        remarks: _remarksController.text,
        priority: _priority,
      );

      appState.addProgram(newProg);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Program "${newProg.item}" saved successfully!'),
          backgroundColor: AppColors.success,
        ),
      );

      if (keepOpen) {
        _studentNameController.clear();
        _itemController.clear();
        _remarksController.clear();
      } else {
        Navigator.pop(context);
      }
    }
  }
}
