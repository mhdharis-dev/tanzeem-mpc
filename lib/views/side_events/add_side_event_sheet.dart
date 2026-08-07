// Library: add_side_event_sheet.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/models/side_event_model.dart';
import '../../core/providers/app_state.dart';
import '../../core/theme/app_colors.dart';

class SideEventTabEntry {
  final TextEditingController nameController;
  final TextEditingController maxPointController;
  final TextEditingController scheduledDateController;
  final TextEditingController scheduledTimeController;
  final TextEditingController customController = TextEditingController();

  Set<String> selectedCategories;
  String selectedColorHex;
  String selectedStatus;

  SideEventTabEntry({
    String name = '',
    int maxPoint = 50,
    String? scheduledDate,
    String? scheduledTime,
    Set<String>? selectedCategories,
    this.selectedColorHex = '0xFF14B8A6',
    this.selectedStatus = 'pending',
  })  : nameController = TextEditingController(text: name),
        maxPointController = TextEditingController(text: '$maxPoint'),
        scheduledDateController = TextEditingController(
          text: scheduledDate ?? DateFormat('yyyy-MM-dd').format(DateTime.now()),
        ),
        scheduledTimeController = TextEditingController(
          text: scheduledTime ?? '10:00 AM - 12:00 PM',
        ),
        selectedCategories = selectedCategories ??
            {'All', 'Sub-Junior', 'Junior', 'Senior', 'Super Senior'};

  void dispose() {
    nameController.dispose();
    maxPointController.dispose();
    scheduledDateController.dispose();
    scheduledTimeController.dispose();
    customController.dispose();
  }

  String getFormattedCategory(List<String> specificCategories) {
    if (selectedCategories.contains('All') ||
        selectedCategories.containsAll(specificCategories) ||
        selectedCategories.isEmpty) {
      return 'All';
    } else {
      return specificCategories.where((c) => selectedCategories.contains(c)).join(', ');
    }
  }
}

class AddSideEventSheet extends StatefulWidget {
  final SideEventModel? initialSideEvent;

  const AddSideEventSheet({super.key, this.initialSideEvent});

  @override
  State<AddSideEventSheet> createState() => _AddSideEventSheetState();
}

class _AddSideEventSheetState extends State<AddSideEventSheet> {
  int _activeTabIndex = 0;
  final List<SideEventTabEntry> _eventTabs = [];

  final List<String> _categories = ['All', 'Sub-Junior', 'Junior', 'Senior', 'Super Senior'];
  final List<String> _specificCategories = ['Sub-Junior', 'Junior', 'Senior', 'Super Senior'];

  // Preset Side Event Name Suggestions
  final List<String> _presetEventNames = [
    'CALLIGRAPHY',
    'ESSAY WRITING',
    'DRAWING',
    'ISLAMIC QUIZ',
    'QIRA\'AT RECITATION',
    'SPEECH',
    'MEHDYA',
    'AL-QURAN',
    'POEM RECITATION',
    'STORY TELLING',
  ];

  final List<Map<String, String>> _statusOptions = [
    {'value': 'pending', 'label': 'Scheduled', 'icon': '⏳'},
    {'value': 'live now', 'label': 'Live Now', 'icon': '🔴'},
    {'value': 'completed', 'label': 'Completed', 'icon': '✅'},
    {'value': 'canceled', 'label': 'Canceled', 'icon': '❌'},
  ];

  final List<String> _themeColors = [
    '0xFF14B8A6', // Teal
    '0xFF3B82F6', // Blue
    '0xFF8B5CF6', // Purple
    '0xFFEF4444', // Red
    '0xFFF59E0B', // Amber
    '0xFF10B981', // Emerald
    '0xFFEC4899', // Pink
    '0xFF6366F1', // Indigo
  ];

  @override
  void initState() {
    super.initState();
    final event = widget.initialSideEvent;

    if (event != null) {
      Set<String> selCats = {};
      final rawCat = event.participantsCategory;
      if (rawCat == 'All' || rawCat.isEmpty) {
        selCats = {'All', ..._specificCategories};
      } else {
        final parts = rawCat.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
        selCats = Set<String>.from(parts);
        if (selCats.containsAll(_specificCategories)) {
          selCats.add('All');
        }
      }

      _eventTabs.add(
        SideEventTabEntry(
          name: event.sideEventName,
          maxPoint: event.sideEventMaxPoint,
          scheduledDate: event.scheduledDate,
          scheduledTime: event.scheduledTime,
          selectedCategories: selCats,
          selectedColorHex: event.sideEventColor.isNotEmpty ? event.sideEventColor : '0xFF14B8A6',
          selectedStatus: event.sideEventStatus,
        ),
      );
    } else {
      _eventTabs.add(SideEventTabEntry());
    }
  }

  @override
  void dispose() {
    for (var tab in _eventTabs) {
      tab.dispose();
    }
    super.dispose();
  }

  void _addNewTab() {
    setState(() {
      _eventTabs.add(SideEventTabEntry());
      _activeTabIndex = _eventTabs.length - 1;
    });
  }

  void _removeTab(int index) {
    if (_eventTabs.length > 1) {
      setState(() {
        _eventTabs[index].dispose();
        _eventTabs.removeAt(index);
        if (_activeTabIndex >= _eventTabs.length) {
          _activeTabIndex = _eventTabs.length - 1;
        }
      });
    }
  }

  bool _isCategoryChipHighlighted(SideEventTabEntry tab, String cat) {
    final hasAll4 = _specificCategories.every((c) => tab.selectedCategories.contains(c));
    if (hasAll4) {
      return cat == 'All';
    } else {
      if (cat == 'All') return false;
      return tab.selectedCategories.contains(cat);
    }
  }

  void _toggleCategory(SideEventTabEntry tab, String cat) {
    setState(() {
      final hasAll4 = _specificCategories.every((c) => tab.selectedCategories.contains(c));
      if (cat == 'All') {
        if (hasAll4) {
          tab.selectedCategories.clear();
        } else {
          tab.selectedCategories = {'All', ..._specificCategories};
        }
      } else {
        if (tab.selectedCategories.contains(cat)) {
          tab.selectedCategories.remove(cat);
          tab.selectedCategories.remove('All');
        } else {
          tab.selectedCategories.add(cat);
          if (_specificCategories.every((c) => tab.selectedCategories.contains(c))) {
            tab.selectedCategories.add('All');
          }
        }
      }
    });
  }

  String _generateAutoEventId(AppState appState, int offsetIndex) {
    if (widget.initialSideEvent != null) return widget.initialSideEvent!.sideEventId;
    final nextNum = appState.sideEventRecords.length + 1 + offsetIndex;
    return 'sdevnt-${nextNum.toString().padLeft(3, '0')}';
  }

  Future<void> _selectDate(SideEventTabEntry tab) async {
    DateTime initial = DateTime.now();
    try {
      if (tab.scheduledDateController.text.isNotEmpty) {
        initial = DateFormat('yyyy-MM-dd').parse(tab.scheduledDateController.text);
      }
    } catch (_) {}

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2025),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        tab.scheduledDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _selectTime(SideEventTabEntry tab) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 10, minute: 0),
    );

    if (pickedTime != null && mounted) {
      final formattedTime = pickedTime.format(context);
      setState(() {
        tab.scheduledTimeController.text = formattedTime;
      });
    }
  }

  // --- CHECK DUPLICATE SIDE EVENT ON FIREBASE / APPSTATE FOR SAME CATEGORY ---
  bool _isDuplicateOnFirebase(SideEventTabEntry currentTab, AppState appState) {
    final name = currentTab.nameController.text.trim().toLowerCase();
    if (name.isEmpty) return false;

    final currentCatStr = currentTab.getFormattedCategory(_specificCategories);

    for (var existing in appState.sideEventRecords) {
      if (widget.initialSideEvent != null &&
          existing.sideEventId == widget.initialSideEvent!.sideEventId) {
        continue; // Skip self when editing
      }

      if (existing.sideEventName.trim().toLowerCase() == name) {
        final existingCatStr = existing.participantsCategory;

        if (currentCatStr == 'All' || existingCatStr == 'All') {
          return true;
        }

        final currentCats = currentCatStr.split(', ').map((e) => e.trim()).toSet();
        final existingCats = existingCatStr.split(', ').map((e) => e.trim()).toSet();

        if (currentCats.intersection(existingCats).isNotEmpty) {
          return true;
        }
      }
    }
    return false;
  }

  // --- CHECK DUPLICATE SIDE EVENT ACROSS OTHER TABS ---
  int? _findDuplicateInOtherTabs(int currentTabIndex, SideEventTabEntry currentTab) {
    final name = currentTab.nameController.text.trim().toLowerCase();
    if (name.isEmpty) return null;

    final currentCatStr = currentTab.getFormattedCategory(_specificCategories);

    for (int i = 0; i < _eventTabs.length; i++) {
      if (i == currentTabIndex) continue;

      final otherTab = _eventTabs[i];
      final otherName = otherTab.nameController.text.trim().toLowerCase();
      if (otherName == name) {
        final otherCatStr = otherTab.getFormattedCategory(_specificCategories);

        if (currentCatStr == 'All' || otherCatStr == 'All') {
          return i + 1;
        }

        final currentCats = currentCatStr.split(', ').map((e) => e.trim()).toSet();
        final otherCats = otherCatStr.split(', ').map((e) => e.trim()).toSet();

        if (currentCats.intersection(otherCats).isNotEmpty) {
          return i + 1;
        }
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDark = appState.isDarkMode;

    final totalTabs = _eventTabs.length;
    _activeTabIndex = _activeTabIndex.clamp(0, totalTabs - 1);
    final activeTab = _eventTabs[_activeTabIndex];

    final autoEventId = _generateAutoEventId(appState, _activeTabIndex);
    Color currentColor = Color(int.parse(activeTab.selectedColorHex));

    final isDuplicateOnFirebase = _isDuplicateOnFirebase(activeTab, appState);
    final duplicateOtherTabNum = _findDuplicateInOtherTabs(_activeTabIndex, activeTab);

    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.90),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Top Header Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              border: Border(
                bottom: BorderSide(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: currentColor.withAlpha(35),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: currentColor.withAlpha(90)),
                  ),
                  child: Icon(Icons.festival_rounded, color: currentColor, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.initialSideEvent != null
                            ? 'Edit Side Event Setup'
                            : 'Host New Side Event(s)',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: isDark ? AppColors.textLight : AppColors.textDark,
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: currentColor.withAlpha(30),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              autoEventId,
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: currentColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Batch setup side event contests & categories',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: isDark ? AppColors.subtextLight : AppColors.subtextDark,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 22),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          // --- CHROME STYLE TAB BAR WITH "+ Add Entry Tab" BUTTON ---
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            color: isDark ? const Color(0xFF1E293B).withAlpha(120) : const Color(0xFFF1F5F9),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ...List.generate(totalTabs, (idx) {
                    final isSel = _activeTabIndex == idx;
                    final tabLabel = 'Tab ${idx + 1}';

                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => setState(() => _activeTabIndex = idx),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSel
                                  ? currentColor
                                  : (isDark ? const Color(0xFF0F172A) : Colors.white),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSel
                                    ? currentColor
                                    : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.festival_rounded,
                                  size: 15,
                                  color: isSel
                                      ? Colors.white
                                      : (isDark ? AppColors.subtextLight : AppColors.subtextDark),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  tabLabel,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isSel
                                        ? Colors.white
                                        : (isDark ? AppColors.textLight : AppColors.textDark),
                                  ),
                                ),
                                if (totalTabs > 1 && widget.initialSideEvent == null) ...[
                                  const SizedBox(width: 8),
                                  InkWell(
                                    onTap: () => _removeTab(idx),
                                    borderRadius: BorderRadius.circular(10),
                                    child: Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: Icon(
                                        Icons.close_rounded,
                                        size: 14,
                                        color: isSel ? Colors.white70 : Colors.redAccent,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),

                  if (widget.initialSideEvent == null) ...[
                    ElevatedButton.icon(
                      onPressed: _addNewTab,
                      icon: const Icon(Icons.add_rounded, size: 16),
                      label: Text(
                        '+ Add Entry Tab',
                        style: GoogleFonts.poppins(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Scrollable Form Body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Duplicate Warning Alert Pill
                  if (isDuplicateOnFirebase) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.red.withAlpha(20),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.withAlpha(80)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '🚫 Event "${activeTab.nameController.text.trim()}" is already exists for ${activeTab.getFormattedCategory(_specificCategories)} category',
                              style: GoogleFonts.poppins(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: Colors.redAccent,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ] else if (duplicateOtherTabNum != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.orange.withAlpha(20),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.withAlpha(80)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '⚠️ Duplicate Event "${activeTab.nameController.text.trim()}" in Tab $duplicateOtherTabNum for same category!',
                              style: GoogleFonts.poppins(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange.shade800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // --- 1. EVENT IDENTITY & POINTS ---
                  Text(
                    '1. Event Information & Max Points',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: currentColor,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Event Name Field
                      Expanded(
                        flex: 3,
                        child: TextField(
                          controller: activeTab.nameController,
                          onChanged: (val) => setState(() {}),
                          decoration: InputDecoration(
                            labelText: 'Side Event Name',
                            hintText: 'e.g. CALLIGRAPHY',
                            prefixIcon: Icon(
                              Icons.drive_file_rename_outline_rounded,
                              size: 20,
                              color: currentColor,
                            ),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                            filled: true,
                            fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      // Max Points Field
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: activeTab.maxPointController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Max Mark / Points',
                            hintText: '50',
                            prefixIcon: const Icon(
                              Icons.star_rounded,
                              size: 20,
                              color: Color(0xFFF59E0B),
                            ),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                            filled: true,
                            fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Preset Event Suggestions
                  Text(
                    'Preset Event Suggestions',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.subtextLight : AppColors.subtextDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _presetEventNames.map((sugName) {
                      final isSelected = activeTab.nameController.text.trim().toUpperCase() == sugName;
                      return InkWell(
                        onTap: () {
                          setState(() {
                            activeTab.nameController.text = sugName;
                          });
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? currentColor.withAlpha(30)
                                : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? currentColor : Colors.transparent,
                              width: 1.2,
                            ),
                          ),
                          child: Text(
                            sugName,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected
                                  ? currentColor
                                  : (isDark ? AppColors.textLight : AppColors.textDark),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 22),
                  const Divider(height: 1),
                  const SizedBox(height: 18),

                  // --- 2. PARTICIPANT CATEGORY SELECTOR ---
                  Text(
                    '2. Target Participant Category',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: currentColor,
                    ),
                  ),
                  Text(
                    'Only students in the selected category will be eligible for registration.',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: isDark ? AppColors.subtextLight : AppColors.subtextDark,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _categories.map((cat) {
                      bool isSelected = _isCategoryChipHighlighted(activeTab, cat);
                      return GestureDetector(
                        onTap: () => _toggleCategory(activeTab, cat),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? currentColor
                                : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? currentColor
                                  : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: currentColor.withAlpha(120),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    )
                                  ]
                                : null,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isSelected ? Icons.check_circle_rounded : Icons.category_rounded,
                                size: 16,
                                color: isSelected
                                    ? Colors.white
                                    : (isDark ? AppColors.subtextLight : AppColors.subtextDark),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                cat,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  color: isSelected
                                      ? Colors.white
                                      : (isDark ? AppColors.textLight : AppColors.textDark),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 22),
                  const Divider(height: 1),
                  const SizedBox(height: 18),

                  // --- 3. EVENT STATUS SELECTOR ---
                  Text(
                    '3. Initial Event Status',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: currentColor,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: _statusOptions.map((st) {
                      final val = st['value']!;
                      final label = st['label']!;
                      final iconStr = st['icon']!;
                      bool isSelected = activeTab.selectedStatus == val;

                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => activeTab.selectedStatus = val),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? currentColor.withAlpha(30)
                                  : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? currentColor
                                    : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(iconStr, style: const TextStyle(fontSize: 16)),
                                const SizedBox(height: 4),
                                Text(
                                  label,
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                    color: isSelected
                                        ? currentColor
                                        : (isDark ? AppColors.textLight : AppColors.textDark),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 22),
                  const Divider(height: 1),
                  const SizedBox(height: 18),

                  // --- 4. SCHEDULE DATE & TIME PICKERS ---
                  Text(
                    '4. Event Schedule Timing',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: currentColor,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      // Date Picker Tile
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectDate(activeTab),
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withAlpha(25),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.calendar_month_rounded,
                                    color: AppColors.primary,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Scheduled Date',
                                      style: GoogleFonts.poppins(
                                        fontSize: 10,
                                        color: isDark
                                            ? AppColors.subtextLight
                                            : AppColors.subtextDark,
                                      ),
                                    ),
                                    Text(
                                      activeTab.scheduledDateController.text,
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Time Picker Tile
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectTime(activeTab),
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.warning.withAlpha(25),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.access_time_rounded,
                                    color: AppColors.warning,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Scheduled Time Range',
                                      style: GoogleFonts.poppins(
                                        fontSize: 10,
                                        color: isDark
                                            ? AppColors.subtextLight
                                            : AppColors.subtextDark,
                                      ),
                                    ),
                                    Text(
                                      activeTab.scheduledTimeController.text,
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),
                  const Divider(height: 1),
                  const SizedBox(height: 18),

                  // --- 5. THEME COLOR PALETTE ---
                  Text(
                    '5. Event Theme Accent Color',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: currentColor,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Wrap(
                    spacing: 12,
                    children: _themeColors.map((hexStr) {
                      Color c = Color(int.parse(hexStr));
                      bool isSel = activeTab.selectedColorHex == hexStr;
                      return GestureDetector(
                        onTap: () => setState(() => activeTab.selectedColorHex = hexStr),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                            border: isSel ? Border.all(color: Colors.white, width: 3.5) : null,
                            boxShadow: isSel
                                ? [
                                    BoxShadow(
                                      color: c.withAlpha(180),
                                      blurRadius: 10,
                                      offset: const Offset(0, 3),
                                    )
                                  ]
                                : null,
                          ),
                          child: isSel
                              ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Action Button Bar
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
              border: Border(
                top: BorderSide(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  final nav = Navigator.of(context);
                  int createdCount = 0;

                  // Validate each tab for name and duplicate on Firebase / other tabs
                  for (int tIdx = 0; tIdx < _eventTabs.length; tIdx++) {
                    final tab = _eventTabs[tIdx];
                    final eName = tab.nameController.text.trim();

                    if (eName.isEmpty) {
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text('Tab ${tIdx + 1}: Please enter Side Event Name!'),
                          backgroundColor: AppColors.error,
                        ),
                      );
                      return;
                    }

                    if (_isDuplicateOnFirebase(tab, appState)) {
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            'Tab ${tIdx + 1}: Event "$eName" is already exists for ${tab.getFormattedCategory(_specificCategories)} category',
                          ),
                          backgroundColor: AppColors.error,
                        ),
                      );
                      return;
                    }

                    final dupTabNum = _findDuplicateInOtherTabs(tIdx, tab);
                    if (dupTabNum != null) {
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            'Tab ${tIdx + 1}: Side Event "$eName" duplicates Tab $dupTabNum for category (${tab.getFormattedCategory(_specificCategories)})!',
                          ),
                          backgroundColor: AppColors.error,
                        ),
                      );
                      return;
                    }
                  }

                  // Save all tabs to Firestore
                  for (int tIdx = 0; tIdx < _eventTabs.length; tIdx++) {
                    final tab = _eventTabs[tIdx];
                    final eName = tab.nameController.text.trim();
                    final maxPt = int.tryParse(tab.maxPointController.text.trim()) ?? 50;

                    final existingParticipants = widget.initialSideEvent?.participants ?? [];
                    final formattedCategory = tab.getFormattedCategory(_specificCategories);
                    final eventId = _generateAutoEventId(appState, tIdx);

                    final record = SideEventModel(
                      sideEventId: eventId,
                      sideEventName: eName,
                      participantsCount: existingParticipants.length,
                      participantsCategory: formattedCategory,
                      scheduledDate: tab.scheduledDateController.text,
                      scheduledTime: tab.scheduledTimeController.text,
                      sideEventColor: tab.selectedColorHex,
                      sideEventMaxPoint: maxPt,
                      sideEventStatus: tab.selectedStatus,
                      participants: existingParticipants,
                    );

                    await appState.saveSideEventRecordToFirestore(record);
                    createdCount++;
                  }

                  nav.pop();
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        widget.initialSideEvent != null
                            ? '✨ Side Event "${_eventTabs.first.nameController.text}" updated successfully!'
                            : '✨ Successfully created $createdCount Side Event(s) across ${_eventTabs.length} tab(s)!',
                      ),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
                icon: const Icon(Icons.save_rounded, size: 20),
                label: Text(
                  widget.initialSideEvent != null
                      ? 'Save Side Event Changes'
                      : 'Save All $totalTabs Side Event Tab(s)',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: currentColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
