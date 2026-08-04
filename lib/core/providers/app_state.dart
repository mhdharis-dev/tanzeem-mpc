import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../utils/dummy_data.dart';
import '../utils/schedule_generator.dart';

class AppState extends ChangeNotifier {
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  bool _isLoggedIn = false; // Starts on login page for role-based authentication
  bool get isLoggedIn => _isLoggedIn;

  int _activeTabIndex = 0;
  int get activeTabIndex => _activeTabIndex;

  String _userRole = 'Program Coordinator'; // 'Program Coordinator' or 'Super Admin'
  String get userRole => _userRole;

  String _userEmail = '';
  String get userEmail => _userEmail;

  String _madrasaId = '7020@tanzeem';
  String get madrasaId => _madrasaId;

  bool _isSidebarCollapsed = false;
  bool get isSidebarCollapsed => _isSidebarCollapsed;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  String _selectedClassFilter = 'All';
  String get selectedClassFilter => _selectedClassFilter;

  String _selectedCategoryFilter = 'All';
  String get selectedCategoryFilter => _selectedCategoryFilter;

  String _selectedTypeFilter = 'All';
  String get selectedTypeFilter => _selectedTypeFilter;

  String _selectedStatusFilter = 'All';
  String get selectedStatusFilter => _selectedStatusFilter;

  // Data lists
  late List<Program> _programs;
  List<Program> get programs => _programs;

  late List<Participant> _participants;
  List<Participant> get participants => _participants;

  late List<MadrasaModel> _madrasas;
  List<MadrasaModel> get madrasas => _madrasas;

  List<ParticipantModel> _realParticipants = [];
  List<ParticipantModel> get realParticipants => _realParticipants;

  List<ProgramModel> _realPrograms = [];
  List<ProgramModel> get realPrograms => _realPrograms;

  late List<NotificationItem> _notifications;
  List<NotificationItem> get notifications => _notifications;

  List<ScheduleSlot> _scheduleSlots = [];
  List<ScheduleSlot> get scheduleSlots => _scheduleSlots;

  // Live stage countdown state
  int _liveStageProgramIndex = 0;
  int get liveStageProgramIndex => _liveStageProgramIndex;

  int _liveTimerRemainingSeconds = 12 * 60; // 12 minutes default
  int get liveTimerRemainingSeconds => _liveTimerRemainingSeconds;

  bool _isTimerRunning = false;
  bool get isTimerRunning => _isTimerRunning;

  Timer? _liveTimer;

  // Settings state
  String festivalName = 'Meelad Fest 2026 - Central Zone';
  String madrasaName = 'Tanzeem Central Institute';
  TimeOfDay defaultStartTime = const TimeOfDay(hour: 8, minute: 30);
  TimeOfDay dhuhrPrayerTime = const TimeOfDay(hour: 13, minute: 0);
  TimeOfDay asrPrayerTime = const TimeOfDay(hour: 16, minute: 15);
  int defaultDurationMinutes = 12;

  AppState() {
    _programs = List.from(DummyData.initialPrograms);
    _participants = List.from(DummyData.initialParticipants);
    _madrasas = List.from(DummyData.initialMadrasas);
    _notifications = List.from(DummyData.initialNotifications);

    _fetchMadrasasFromFirestore();
    _fetchParticipantsFromFirestore();
    _fetchProgramsFromFirestore();
    generateAutoSchedule();
    _loadUserSession();
  }

  void _fetchMadrasasFromFirestore() {
    try {
      FirebaseFirestore.instance.collection('madrasa').snapshots().listen((snapshot) {
        _madrasas = snapshot.docs.map((doc) => MadrasaModel.fromSnapshot(doc)).toList();
        notifyListeners();
      }, onError: (e) {
        debugPrint('Firestore _fetchMadrasasFromFirestore stream error: $e');
      });
    } catch (e) {
      debugPrint('Firestore stream init error: $e');
    }
  }

  void _fetchParticipantsFromFirestore() {
    try {
      FirebaseFirestore.instance.collectionGroup('participants').snapshots().listen((snapshot) {
        _realParticipants = snapshot.docs.map((doc) => ParticipantModel.fromSnapshot(doc)).toList();
        notifyListeners();
      }, onError: (e) {
        debugPrint('Firestore _fetchParticipantsFromFirestore group stream error: $e');
      });
    } catch (e) {
      debugPrint('Firestore group stream init error: $e');
    }
  }

  void _fetchProgramsFromFirestore() {
    try {
      FirebaseFirestore.instance.collectionGroup('programs').snapshots().listen((snapshot) {
        _realPrograms = snapshot.docs.map((doc) => ProgramModel.fromSnapshot(doc)).toList();
        notifyListeners();
      }, onError: (e) {
        debugPrint('Firestore _fetchProgramsFromFirestore group stream error: $e');
      });
    } catch (e) {
      debugPrint('Firestore group stream init error: $e');
    }
  }

  Future<bool> addParticipantToFirestore(ParticipantModel participant) async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection('madrasa')
          .doc(participant.madrasaId)
          .collection('participants')
          .doc(participant.participantId);

      await docRef.set(participant.toMap());

      if (!_realParticipants.any((p) => p.participantId == participant.participantId)) {
        _realParticipants.add(participant);
        notifyListeners();
      }
      return true;
    } catch (e) {
      debugPrint('Error adding participant to Firestore: $e');
      return false;
    }
  }

  Future<bool> addProgramToFirestore(ProgramModel program) async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection('madrasa')
          .doc(program.madrasaId)
          .collection('programs')
          .doc(program.programId);

      await docRef.set(program.toMap());

      final idx = _realPrograms.indexWhere((p) => p.programId == program.programId);
      if (idx >= 0) {
        _realPrograms[idx] = program;
      } else {
        _realPrograms.add(program);
      }
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error adding program to Firestore: $e');
      return false;
    }
  }

  Future<bool> updateProgramInFirestore(ProgramModel program) async {
    return addProgramToFirestore(program);
  }

  Future<bool> deleteProgramFromFirestore(String programId, String madrasaId) async {
    try {
      final mId = madrasaId.isEmpty ? _madrasaId : madrasaId;
      await FirebaseFirestore.instance
          .collection('madrasa')
          .doc(mId)
          .collection('programs')
          .doc(programId)
          .delete();

      _realPrograms.removeWhere((p) => p.programId == programId);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error deleting program from Firestore: $e');
      return false;
    }
  }

  Future<bool> startProgramLiveInFirestore(String targetProgramId, String madrasaId) async {
    try {
      final mId = madrasaId.isEmpty ? _madrasaId : madrasaId;
      final now = DateTime.now();
      final timeStr = DateFormat('HH:mm:ss').format(now);
      final batch = FirebaseFirestore.instance.batch();

      // Stop any other currently live program
      for (final prog in _realPrograms) {
        if (prog.status.toLowerCase() == 'live' && prog.programId != targetProgramId) {
          final ref = FirebaseFirestore.instance
              .collection('madrasa')
              .doc(mId)
              .collection('programs')
              .doc(prog.programId);

          batch.update(ref, {
            'status': 'completed',
            'endTime': timeStr,
          });
        }
      }

      final targetRef = FirebaseFirestore.instance
          .collection('madrasa')
          .doc(mId)
          .collection('programs')
          .doc(targetProgramId);

      batch.update(targetRef, {
        'status': 'live',
        'startTime': timeStr,
      });

      await batch.commit();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error starting live program: $e');
      return false;
    }
  }

  Future<bool> stopProgramLiveInFirestore(String targetProgramId, String madrasaId) async {
    try {
      final mId = madrasaId.isEmpty ? _madrasaId : madrasaId;
      final now = DateTime.now();
      final endTimeStr = DateFormat('HH:mm:ss').format(now);

      final progIdx = _realPrograms.indexWhere((p) => p.programId == targetProgramId);
      String calculatedDuration = '50 sec';

      if (progIdx >= 0) {
        final prog = _realPrograms[progIdx];
        if (prog.startTime.isNotEmpty && prog.startTime != 'TBD') {
          try {
            DateTime? parsedStart;
            try {
              final t = DateFormat('HH:mm:ss').parse(prog.startTime);
              parsedStart = DateTime(now.year, now.month, now.day, t.hour, t.minute, t.second);
            } catch (_) {
              final t = DateFormat('hh:mm a').parse(prog.startTime);
              parsedStart = DateTime(now.year, now.month, now.day, t.hour, t.minute);
            }

            final diffSeconds = now.difference(parsedStart).inSeconds;
            if (diffSeconds > 0) {
              calculatedDuration = ProgramModel.formatSecondsToDuration(diffSeconds);
            }
          } catch (e) {
            debugPrint('Error calculating exact duration: $e');
          }
        }
      }

      final targetRef = FirebaseFirestore.instance
          .collection('madrasa')
          .doc(mId)
          .collection('programs')
          .doc(targetProgramId);

      await targetRef.update({
        'status': 'completed',
        'endTime': endTimeStr,
        'duration': calculatedDuration,
      });

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error stopping live program: $e');
      return false;
    }
  }

  Future<bool> cancelProgramInFirestore(String targetProgramId, String madrasaId) async {
    try {
      final mId = madrasaId.isEmpty ? _madrasaId : madrasaId;
      final targetRef = FirebaseFirestore.instance
          .collection('madrasa')
          .doc(mId)
          .collection('programs')
          .doc(targetProgramId);

      await targetRef.update({
        'status': 'cancelled',
      });

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error cancelling program: $e');
      return false;
    }
  }

  Future<bool> uncancelProgramInFirestore(String targetProgramId, String madrasaId) async {
    try {
      final mId = madrasaId.isEmpty ? _madrasaId : madrasaId;
      final targetRef = FirebaseFirestore.instance
          .collection('madrasa')
          .doc(mId)
          .collection('programs')
          .doc(targetProgramId);

      await targetRef.update({
        'status': 'pending',
      });

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error uncancelling program: $e');
      return false;
    }
  }

  Future<void> recalculateProgramOrdersInFirestore() async {
    try {
      final batch = FirebaseFirestore.instance.batch();
      for (int i = 0; i < _realPrograms.length; i++) {
        final prog = _realPrograms[i];
        final newOrder = i + 1;
        if (prog.order != newOrder) {
          final ref = FirebaseFirestore.instance
              .collection('madrasa')
              .doc(prog.madrasaId.isEmpty ? _madrasaId : prog.madrasaId)
              .collection('programs')
              .doc(prog.programId);
          batch.update(ref, {'order': newOrder});
        }
      }
      await batch.commit();
      notifyListeners();
    } catch (e) {
      debugPrint('Error recalculating program orders: $e');
    }
  }

  Future<bool> setSingleProgramLiveInFirestore(String targetProgramId, String madrasaId) async {
    return startProgramLiveInFirestore(targetProgramId, madrasaId);
  }

  Future<void> _loadUserSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      _userEmail = prefs.getString('userEmail') ?? '';
      _userRole = prefs.getString('userRole') ?? 'Program Coordinator';
      _madrasaId = prefs.getString('madrasaId') ?? '7020@tanzeem';
      madrasaName = prefs.getString('madrasaName') ?? 'Tanzeem Central Institute';
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading user session: $e');
    }
  }

  Future<void> _saveUserSession(bool loggedIn, String email, String role, {String? madrasaId, String? name}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (loggedIn) {
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('userEmail', email);
        await prefs.setString('userRole', role);
        if (madrasaId != null) await prefs.setString('madrasaId', madrasaId);
        if (name != null) await prefs.setString('madrasaName', name);
      } else {
        await prefs.remove('isLoggedIn');
        await prefs.remove('userEmail');
        await prefs.remove('userRole');
        await prefs.remove('madrasaId');
        await prefs.remove('madrasaName');
      }
    } catch (e) {
      debugPrint('Error saving user session: $e');
    }
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void toggleSidebar() {
    _isSidebarCollapsed = !_isSidebarCollapsed;
    notifyListeners();
  }

  void setTabIndex(int index) {
    _activeTabIndex = index;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    final cleanEmail = email.trim().toLowerCase();
    
    // 1. Super Admin Firestore Verification ('admin' collection document / query)
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('admin')
          .where('email', isEqualTo: cleanEmail)
          .where('password', isEqualTo: password)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        _userRole = 'Super Admin';
        _userEmail = cleanEmail;
        _isLoggedIn = true;
        _activeTabIndex = 0;
        await _saveUserSession(true, _userEmail, _userRole);
        notifyListeners();
        return true;
      }

      final docSnapshot = await FirebaseFirestore.instance.collection('admin').doc('admin').get();
      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        if (data != null) {
          final docEmail = (data['email'] ?? '').toString().trim().toLowerCase();
          final docPassword = (data['password'] ?? '').toString();
          if (docEmail == cleanEmail && docPassword == password) {
            _userRole = 'Super Admin';
            _userEmail = cleanEmail;
            _isLoggedIn = true;
            _activeTabIndex = 0;
            await _saveUserSession(true, _userEmail, _userRole);
            notifyListeners();
            return true;
          }
        }
      }
    } catch (e) {
      debugPrint('Firestore Admin Auth check error: $e');
    }

    // Static fallback check if Firestore is offline
    if (cleanEmail == 'admin@haris.tanzeem' && password == 'tanzeem@admin') {
      _userRole = 'Super Admin';
      _userEmail = cleanEmail;
      _isLoggedIn = true;
      _activeTabIndex = 0;
      await _saveUserSession(true, _userEmail, _userRole);
      notifyListeners();
      return true;
    }
    
    // 2. Program Coordinator Real Role-Based Authentication (querying registered madrasa credentials in Firestore)
    try {
      final madrasaQuery = await FirebaseFirestore.instance
          .collection('madrasa')
          .where('email', isEqualTo: cleanEmail)
          .where('password', isEqualTo: password)
          .get();

      if (madrasaQuery.docs.isNotEmpty) {
        final madrasaDoc = madrasaQuery.docs.first;
        final madrasa = MadrasaModel.fromSnapshot(madrasaDoc);

        _userRole = 'Program Coordinator';
        _userEmail = cleanEmail;
        _isLoggedIn = true;
        _activeTabIndex = 0;
        _madrasaId = madrasa.madrasaId;
        madrasaName = madrasa.madrasaName;

        updateMadrasaOnlineStatus(cleanEmail, true);
        await _saveUserSession(true, _userEmail, _userRole, madrasaId: _madrasaId, name: madrasaName);
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Firestore Coordinator Auth check error: $e');
    }

    // Local in-memory fallback check for registered madrasas
    final localMadrasaIndex = _madrasas.indexWhere(
      (m) => m.email.trim().toLowerCase() == cleanEmail && m.password == password,
    );
    if (localMadrasaIndex != -1) {
      final madrasa = _madrasas[localMadrasaIndex];
      _userRole = 'Program Coordinator';
      _userEmail = cleanEmail;
      _isLoggedIn = true;
      _activeTabIndex = 0;
      _madrasaId = madrasa.madrasaId;
      madrasaName = madrasa.madrasaName;

      updateMadrasaOnlineStatus(cleanEmail, true);
      await _saveUserSession(true, _userEmail, _userRole, madrasaId: _madrasaId, name: madrasaName);
      notifyListeners();
      return true;
    }

    return false;
  }

  void updateMadrasaOnlineStatus(String email, bool online) {
    int idx = _madrasas.indexWhere((m) => m.email.toLowerCase() == email.toLowerCase());
    if (idx != -1) {
      _madrasas[idx].isOnline = online;
      _madrasas[idx].lastActive = online ? 'Online now' : 'Last seen just now';
      notifyListeners();

      try {
        FirebaseFirestore.instance.collection('madrasa').doc(_madrasas[idx].madrasaId).set({
          'isOnline': online,
          'lastActive': online ? 'Online now' : 'Last seen just now',
        }, SetOptions(merge: true));
      } catch (e) {
        debugPrint('Firestore updateMadrasaOnlineStatus error: $e');
      }
    }
  }

  void logout() {
    if (_userEmail.isNotEmpty) {
      updateMadrasaOnlineStatus(_userEmail, false);
    }
    _isLoggedIn = false;
    _userEmail = '';
    _activeTabIndex = 0;
    _saveUserSession(false, '', '');
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setClassFilter(String val) {
    _selectedClassFilter = val;
    notifyListeners();
  }

  void setCategoryFilter(String val) {
    _selectedCategoryFilter = val;
    notifyListeners();
  }

  void setTypeFilter(String val) {
    _selectedTypeFilter = val;
    notifyListeners();
  }

  void setStatusFilter(String val) {
    _selectedStatusFilter = val;
    notifyListeners();
  }

  void resetAllFilters() {
    _searchQuery = '';
    _selectedClassFilter = 'All';
    _selectedCategoryFilter = 'All';
    _selectedTypeFilter = 'All';
    _selectedStatusFilter = 'All';
    notifyListeners();
  }

  // Program Management CRUD & Actions
  void addParticipant(Participant participant) {
    _participants.add(participant);
    notifyListeners();
  }

  void addProgram(Program newProg) {
    _programs.add(newProg);
    // Add corresponding participant
    _participants.add(Participant(
      id: 'part-${newProg.id}',
      name: newProg.studentName,
      photoUrl: newProg.studentPhoto,
      studentClass: newProg.studentClass,
      category: newProg.category,
      item: newProg.item,
      teacher: newProg.teacher,
      madrasaName: madrasaName,
      status: 'Scheduled',
    ));
    generateAutoSchedule();
    notifyListeners();
  }

  void updateProgramStatus(String id, ProgramStatus newStatus) {
    int idx = _programs.indexWhere((p) => p.id == id);
    if (idx != -1) {
      _programs[idx].status = newStatus;
      if (newStatus == ProgramStatus.live) {
        _liveStageProgramIndex = idx;
        _liveTimerRemainingSeconds = _programs[idx].durationMinutes * 60;
        startLiveTimer();
      }
      notifyListeners();
    }
  }

  void deleteProgram(String id) {
    _programs.removeWhere((p) => p.id == id);
    generateAutoSchedule();
    notifyListeners();
  }

  void reorderProgram(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    final item = _programs.removeAt(oldIndex);
    _programs.insert(newIndex, item);
    generateAutoSchedule();
    notifyListeners();
  }

  // Automatic Schedule Generation
  void generateAutoSchedule() {
    _scheduleSlots = ScheduleGenerator.generateSchedule(
      programs: _programs,
      startTime: defaultStartTime,
      dhuhrTime: dhuhrPrayerTime,
      asrTime: asrPrayerTime,
      breakDurationMins: 15,
      dhuhrDurationMins: 45,
    );
    notifyListeners();
  }

  // Live Timer Controls
  void startLiveTimer() {
    _isTimerRunning = true;
    _liveTimer?.cancel();
    _liveTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_liveTimerRemainingSeconds > 0) {
        _liveTimerRemainingSeconds--;
        notifyListeners();
      } else {
        _isTimerRunning = false;
        t.cancel();
        notifyListeners();
      }
    });
    notifyListeners();
  }

  void pauseLiveTimer() {
    _isTimerRunning = false;
    _liveTimer?.cancel();
    notifyListeners();
  }

  void nextLiveProgram() {
    if (_liveStageProgramIndex < _programs.length - 1) {
      _programs[_liveStageProgramIndex].status = ProgramStatus.completed;
      _liveStageProgramIndex++;
      _programs[_liveStageProgramIndex].status = ProgramStatus.live;
      _liveTimerRemainingSeconds = _programs[_liveStageProgramIndex].durationMinutes * 60;
      startLiveTimer();
      notifyListeners();
    }
  }

  void prevLiveProgram() {
    if (_liveStageProgramIndex > 0) {
      _liveStageProgramIndex--;
      _liveTimerRemainingSeconds = _programs[_liveStageProgramIndex].durationMinutes * 60;
      notifyListeners();
    }
  }

  void addNotification(String title, String message, String type) {
    _notifications.insert(
      0,
      NotificationItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        message: message,
        timestamp: 'Just now',
        type: type,
      ),
    );
    notifyListeners();
  }

  void markNotificationAsRead(String id) {
    int idx = _notifications.indexWhere((n) => n.id == id);
    if (idx != -1) {
      _notifications[idx].isRead = true;
      notifyListeners();
    }
  }

  // Madrasa Network CRUD Operations (with Cloud Firestore sync)
  void addMadrasa(MadrasaModel newMadrasa) {
    _madrasas.add(newMadrasa);
    addNotification('Madrasa Registered', '${newMadrasa.madrasaName} registered to Tanzeem Network.', 'system');
    notifyListeners();

    try {
      FirebaseFirestore.instance.collection('madrasa').doc(newMadrasa.madrasaId).set(newMadrasa.toMap());
    } catch (e) {
      debugPrint('Firestore addMadrasa error: $e');
    }
  }

  void updateMadrasa(MadrasaModel updatedMadrasa) {
    int idx = _madrasas.indexWhere((m) => m.madrasaId == updatedMadrasa.madrasaId);
    if (idx != -1) {
      _madrasas[idx] = updatedMadrasa;
      addNotification('Madrasa Updated', '${updatedMadrasa.madrasaName} details updated.', 'system');
      notifyListeners();

      try {
        FirebaseFirestore.instance.collection('madrasa').doc(updatedMadrasa.madrasaId).set(updatedMadrasa.toMap(), SetOptions(merge: true));
      } catch (e) {
        debugPrint('Firestore updateMadrasa error: $e');
      }
    }
  }

  void deleteMadrasa(String id) {
    int idx = _madrasas.indexWhere((m) => m.madrasaId == id);
    if (idx != -1) {
      final name = _madrasas[idx].madrasaName;
      _madrasas.removeAt(idx);
      addNotification('Madrasa Removed', '$name was removed from Tanzeem Network.', 'system');
      notifyListeners();

      try {
        FirebaseFirestore.instance.collection('madrasa').doc(id).delete();
      } catch (e) {
        debugPrint('Firestore deleteMadrasa error: $e');
      }
    }
  }

  // Filtered Programs Getter
  List<Program> get filteredPrograms {
    return _programs.where((p) {
      bool matchesSearch = p.studentName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.item.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.number.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.category.toLowerCase().contains(_searchQuery.toLowerCase());

      bool matchesClass = _selectedClassFilter == 'All' || p.studentClass == _selectedClassFilter;
      bool matchesCategory = _selectedCategoryFilter == 'All' || p.category.startsWith(_selectedCategoryFilter);
      bool matchesStatus = _selectedStatusFilter == 'All' || p.status.name.toLowerCase() == _selectedStatusFilter.toLowerCase();

      return matchesSearch && matchesClass && matchesCategory && matchesStatus;
    }).toList();
  }

  @override
  void dispose() {
    _liveTimer?.cancel();
    super.dispose();
  }
}
