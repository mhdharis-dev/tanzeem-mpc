// Library: add_program_dialog.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/models/models.dart';
import '../../core/providers/app_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/dummy_data.dart';

class AddProgramDialog extends StatefulWidget {
  final String programType; // 'Single', 'Group', 'Other'

  const AddProgramDialog({super.key, this.programType = 'Single'});

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

  @override
  void initState() {
    super.initState();
    if (widget.programType == 'Group') {
      _selectedCategory = 'Group Choir';
      _studentNameController.text = 'Group Team A';
    } else if (widget.programType == 'Other') {
      _selectedCategory = 'Islamic Quiz';
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDark = appState.isDarkMode;

    IconData typeIcon = Icons.person_add_rounded;
    Color typeColor = AppColors.primary;
    String typeTitle = 'Add Single Program (Solo)';

    if (widget.programType == 'Group') {
      typeIcon = Icons.group_add_rounded;
      typeColor = AppColors.secondary;
      typeTitle = 'Add Group Program (Team / Choir)';
    } else if (widget.programType == 'Other') {
      typeIcon = Icons.extension_rounded;
      typeColor = AppColors.accent;
      typeTitle = 'Add Other Program (General Event)';
    }

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
                            color: typeColor.withAlpha(30),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(typeIcon, color: typeColor, size: 24),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              typeTitle,
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppColors.textLight : AppColors.textDark,
                              ),
                            ),
                            Text(
                              'Register ${widget.programType.toLowerCase()} item performance for festival schedule.',
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
                          _buildLabel(widget.programType == 'Group' ? 'Group / Team Name' : 'Participant Name', isDark),
                          TextFormField(
                            controller: _studentNameController,
                            validator: (v) => v == null || v.isEmpty ? 'Enter name' : null,
                            decoration: InputDecoration(
                              hintText: widget.programType == 'Group' ? 'e.g. Al-Ansar Choir Team' : 'e.g. Abdullah Ibn Umar',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Class Level', isDark),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedClass,
                            items: DummyData.classes.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedClass = val);
                            },
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
                          _buildLabel('Category', isDark),
                          DropdownButtonFormField<String>(
                            initialValue: DummyData.categories.contains(_selectedCategory) ? _selectedCategory : DummyData.categories[0],
                            items: DummyData.categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedCategory = val);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Item / Title', isDark),
                          TextFormField(
                            controller: _itemController,
                            validator: (v) => v == null || v.isEmpty ? 'Enter item title' : null,
                            decoration: const InputDecoration(hintText: 'e.g. Qira\'at Surah Yasin'),
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
                          _buildLabel('Assigned Stage', isDark),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedStage,
                            items: DummyData.stages.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedStage = val);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Duration (minutes)', isDark),
                          TextFormField(
                            controller: _durationController,
                            keyboardType: TextInputType.number,
                            validator: (v) => v == null || v.isEmpty ? 'Enter duration' : null,
                            decoration: const InputDecoration(suffixText: 'mins'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                _buildLabel('Teacher / Mentor Name', isDark),
                TextFormField(
                  controller: _teacherController,
                  decoration: const InputDecoration(hintText: 'e.g. Usthad Mohammed'),
                ),

                const SizedBox(height: 18),

                _buildLabel('Special Remarks (Optional)', isDark),
                TextFormField(
                  controller: _remarksController,
                  maxLines: 2,
                  decoration: const InputDecoration(hintText: 'Add stage setup requirements or notes...'),
                ),

                const SizedBox(height: 28),

                // Submit Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final nextNum = (appState.programs.length + 1).toString().padLeft(3, '0');
                          final newProg = Program(
                            id: 'p${DateTime.now().millisecondsSinceEpoch}',
                            number: 'P-$nextNum',
                            studentName: _studentNameController.text.trim(),
                            studentPhoto: 'https://i.pravatar.cc/150?img=${(appState.programs.length % 20) + 1}',
                            studentClass: _selectedClass,
                            category: _selectedCategory,
                            item: _itemController.text.trim(),
                            durationMinutes: int.tryParse(_durationController.text) ?? 12,
                            stage: _selectedStage,
                            status: ProgramStatus.pending,
                            startTime: 'TBD',
                            teacher: _teacherController.text.trim(),
                          );

                          appState.addProgram(newProg);
                          Navigator.pop(context);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Program P-$nextNum (${newProg.item}) created!'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: typeColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      ),
                      icon: const Icon(Icons.check_rounded, size: 18),
                      label: Text('Save ${widget.programType} Program'),
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
}
