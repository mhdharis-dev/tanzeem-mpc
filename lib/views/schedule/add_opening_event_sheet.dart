// Library: add_opening_event_sheet.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/models/ceremonial_event_model.dart';
import '../../core/providers/app_state.dart';
import '../../core/theme/app_colors.dart';

class OpeningEventTabItem {
  String programName;
  String position; // 'Starting (Opening)' or 'Ending (Closing)'
  int durationMinutes;
  String personName;
  String personDesignation;
  TextEditingController customNameController;
  TextEditingController durationController;
  TextEditingController personNameController;
  TextEditingController designationController;

  OpeningEventTabItem({
    this.programName = '1. Qur\'an Recitation (Qira\'at) (Opening)',
    this.position = 'Starting (Opening)',
    this.durationMinutes = 15,
    this.personName = '',
    this.personDesignation = '',
  })  : customNameController = TextEditingController(),
        durationController = TextEditingController(text: durationMinutes.toString()),
        personNameController = TextEditingController(text: personName),
        designationController = TextEditingController(text: personDesignation);
}

class AddOpeningEventSheet extends StatefulWidget {
  const AddOpeningEventSheet({super.key});

  @override
  State<AddOpeningEventSheet> createState() => _AddOpeningEventSheetState();
}

class _AddOpeningEventSheetState extends State<AddOpeningEventSheet> {
  final List<OpeningEventTabItem> _tabs = [];
  int _activeTabIndex = 0;
  bool _isSaving = false;

  final List<String> _presetPrograms = [
    'Mowleed (Opening)',
    '1. Qur\'an Recitation (Qira\'at) (Opening)',
    '2. Welcome Speech (Opening)',
    '3. Opening Nasheed (Opening)',
    '4. Presidential Address (Opening)',
    '5. Chief Guest Inauguration (Opening)',
    '6. Keynote Speech (Opening)',
    '7. Prize Distribution (Ending)',
    '8. Vote of Thanks (Ending)',
    '9. Prayer (Ending)',
    'Other / Custom Event',
  ];

  final List<String> _designationPresets = [
    'MLA',
    'Panchayath President',
    'Principal',
    'General Secretary',
    'Chairman',
    'President',
    'Chief Guest',
    'Qazi',
  ];

  @override
  void initState() {
    super.initState();
    _tabs.add(OpeningEventTabItem());
  }

  @override
  void dispose() {
    for (var tab in _tabs) {
      tab.customNameController.dispose();
      tab.durationController.dispose();
      tab.personNameController.dispose();
      tab.designationController.dispose();
    }
    super.dispose();
  }

  // Helper: Get list of already selected program names across previous tabs
  List<String> _getSelectedProgramsOtherThan(int currentIndex) {
    List<String> selected = [];
    for (int i = 0; i < _tabs.length; i++) {
      if (i != currentIndex) {
        final t = _tabs[i];
        if (t.programName != 'Other / Custom Event') {
          selected.add(t.programName);
        } else if (t.customNameController.text.trim().isNotEmpty) {
          selected.add(t.customNameController.text.trim().toLowerCase());
        }
      }
    }
    return selected;
  }

  void _addNewTab() {
    // Find first unselected preset
    final used = _getSelectedProgramsOtherThan(-1);
    String availablePreset = _presetPrograms.firstWhere(
      (p) => !used.contains(p) && p != 'Other / Custom Event',
      orElse: () => 'Other / Custom Event',
    );

    setState(() {
      _tabs.add(OpeningEventTabItem(programName: availablePreset));
      _activeTabIndex = _tabs.length - 1;
    });
  }

  void _removeTab(int index) {
    if (_tabs.length <= 1) return;
    setState(() {
      _tabs.removeAt(index);
      if (_activeTabIndex >= _tabs.length) {
        _activeTabIndex = _tabs.length - 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDark = appState.isDarkMode;
    final activeTab = _tabs[_activeTabIndex];
    final selectedOtherPrograms = _getSelectedProgramsOtherThan(_activeTabIndex);

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 820, maxHeight: 780),
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(80),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER BAR WITH CLOSE
          Padding(
            padding: const EdgeInsets.all(22.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(25),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.stars_rounded, color: AppColors.primary, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Add Ceremonial / Opening & Ending Events',
                          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18, color: isDark ? AppColors.textLight : AppColors.textDark),
                        ),
                        Text(
                          'Batch add inaugural and closing events directly to secured madrasa database.',
                          style: GoogleFonts.poppins(fontSize: 12, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // CHROME-STYLE MULTI-TAB SWITCHER BAR
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ..._tabs.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final tab = entry.value;
                    final isSelected = idx == _activeTabIndex;

                    String tabTitle = tab.programName;
                    if (tab.programName == 'Other / Custom Event') {
                      tabTitle = tab.customNameController.text.trim().isNotEmpty
                          ? tab.customNameController.text.trim()
                          : 'Custom Event';
                    } else {
                      tabTitle = tabTitle.split('(').first.trim();
                    }

                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: InkWell(
                        onTap: () => setState(() => _activeTabIndex = idx),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : (isDark ? const Color(0xFF0F172A) : Colors.white),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? AppColors.primary : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                tab.position.startsWith('Starting') ? Icons.play_circle_outline_rounded : Icons.flag_outlined,
                                size: 14,
                                color: isSelected ? Colors.white : AppColors.primary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Tab ${idx + 1}: $tabTitle',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  color: isSelected ? Colors.white : (isDark ? AppColors.textLight : AppColors.textDark),
                                ),
                              ),
                              if (_tabs.length > 1) ...[
                                const SizedBox(width: 8),
                                InkWell(
                                  onTap: () => _removeTab(idx),
                                  child: Icon(Icons.close_rounded, size: 14, color: isSelected ? Colors.white70 : Colors.grey),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  }),

                  // + ADD EVENT TAB BUTTON
                  OutlinedButton.icon(
                    onPressed: _addNewTab,
                    icon: const Icon(Icons.add_rounded, size: 16),
                    label: Text('+ Add Event Tab', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // TAB CONTENT FORM
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(22),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. SELECT PROGRAM NAME / TYPE PRESETS
                  Text('Program Name / Type:', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13.5, color: isDark ? AppColors.textLight : AppColors.textDark)),
                  const SizedBox(height: 8),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _presetPrograms.map((p) {
                      final isSelected = activeTab.programName == p;
                      final isAlreadyUsed = selectedOtherPrograms.contains(p);

                      return ChoiceChip(
                        selected: isSelected,
                        label: Text(
                          isAlreadyUsed && !isSelected ? '$p (Already Added)' : p,
                          style: GoogleFonts.poppins(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : (isAlreadyUsed ? Colors.grey : (isDark ? AppColors.textLight : AppColors.textDark)),
                          ),
                        ),
                        selectedColor: AppColors.primary,
                        disabledColor: isDark ? Colors.white10 : Colors.black12,
                        backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                        onSelected: isAlreadyUsed && !isSelected
                            ? null
                            : (val) {
                                if (val) {
                                  setState(() {
                                    activeTab.programName = p;
                                    if (p.contains('(Ending)') || p.contains('Prize') || p.contains('Vote') || p.contains('Prayer')) {
                                      activeTab.position = 'Ending (Closing)';
                                    } else {
                                      activeTab.position = 'Starting (Opening)';
                                    }
                                  });
                                }
                              },
                      );
                    }).toList(),
                  ),

                  // CUSTOM EVENT NAME INPUT (If "Other / Custom Event" selected)
                  if (activeTab.programName == 'Other / Custom Event') ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: activeTab.customNameController,
                      style: GoogleFonts.poppins(fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Enter custom event title (e.g. Special Keynote Address)...',
                        prefixIcon: const Icon(Icons.edit_note_rounded, size: 20, color: AppColors.primary),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),

                  // 2. TIMING POSITION & DURATION ROW
                  Row(
                    children: [
                      // Position Dropdown (Starting or Ending)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Event Position:', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13, color: isDark ? AppColors.textLight : AppColors.textDark)),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<String>(
                              initialValue: activeTab.position,
                              items: const [
                                DropdownMenuItem(value: 'Starting (Opening)', child: Text('Starting (Opening)')),
                                DropdownMenuItem(value: 'Ending (Closing)', child: Text('Ending (Closing)')),
                              ],
                              onChanged: (val) {
                                if (val != null) setState(() => activeTab.position = val);
                              },
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Duration Field
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Duration (mins):', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13, color: isDark ? AppColors.textLight : AppColors.textDark)),
                            const SizedBox(height: 6),
                            TextField(
                              controller: activeTab.durationController,
                              keyboardType: TextInputType.number,
                              style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold),
                              decoration: InputDecoration(
                                hintText: 'Duration mins',
                                suffixText: 'm',
                                filled: true,
                                fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // 3. PERSON / SPEAKER NAME & SHORT DESIGNATION FIELD
                  Text('Person / Speaker Name:', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13, color: isDark ? AppColors.textLight : AppColors.textDark)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: activeTab.personNameController,
                    style: GoogleFonts.poppins(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'e.g. Sayyid Hyderali Shihab Thangal, Dr. PK Abdul Aziz',
                      prefixIcon: const Icon(Icons.person_outline_rounded, size: 20, color: AppColors.primary),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text('Person Short Title / Designation View:', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13, color: isDark ? AppColors.textLight : AppColors.textDark)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: activeTab.designationController,
                    style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      hintText: 'e.g. MLA, Panchayath President, Principal, General Secretary',
                      prefixIcon: const Icon(Icons.badge_outlined, size: 20, color: AppColors.secondary),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // PRESET DESIGNATION SUGGESTION CHIPS
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _designationPresets.map((desig) {
                      return ActionChip(
                        label: Text(desig, style: GoogleFonts.poppins(fontSize: 10.5, fontWeight: FontWeight.bold, color: AppColors.secondary)),
                        backgroundColor: AppColors.secondary.withAlpha(20),
                        onPressed: () {
                          setState(() {
                            activeTab.designationController.text = desig;
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),

          // FOOTER SAVE ACTIONS
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_tabs.length} Event Tab(s) Ready to Save',
                  style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Cancel', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _isSaving
                          ? null
                          : () async {
                              setState(() => _isSaving = true);

                              int savedCount = 0;
                              for (var tab in _tabs) {
                                String progName = tab.programName;
                                if (progName == 'Other / Custom Event') {
                                  progName = tab.customNameController.text.trim();
                                  if (progName.isEmpty) progName = 'Custom Opening Event';
                                }

                                final dur = int.tryParse(tab.durationController.text) ?? 15;
                                final person = tab.personNameController.text.trim();
                                final desig = tab.designationController.text.trim();

                                final event = CeremonialEventModel(
                                  eventId: 'ceremonial-${DateTime.now().millisecondsSinceEpoch}-$savedCount',
                                  madrasaId: appState.madrasaId,
                                  programName: progName,
                                  programType: tab.position.contains('Starting') ? 'Opening' : 'Ending',
                                  durationMinutes: dur,
                                  personName: person,
                                  personDesignation: desig,
                                  position: tab.position.contains('Starting') ? 'Starting' : 'Ending',
                                  createdAt: DateTime.now().toIso8601String(),
                                );

                                final ok = await appState.saveCeremonialEventToFirestore(event);
                                if (ok) savedCount++;
                              }

                              setState(() => _isSaving = false);
                              if (context.mounted) {
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('✨ $savedCount Ceremonial / Opening event(s) saved to Secured Database!'),
                                    backgroundColor: AppColors.success,
                                  ),
                                );
                              }
                            },
                      icon: _isSaving
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.cloud_upload_rounded, size: 18),
                      label: Text(_isSaving ? 'Saving...' : 'Save All Tabs to Secured DB', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
}
