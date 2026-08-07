import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../models/side_event_model.dart';
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

  List<PresentModel> _presentRecords = [];
  List<PresentModel> get presentRecords => _presentRecords;

  List<MarkModel> _markRecords = [];
  List<MarkModel> get markRecords => _markRecords;

  List<TeamModel> _teamRecords = [];
  List<TeamModel> get teamRecords => _teamRecords;

  List<SideEventModel> _sideEventRecords = [];
  List<SideEventModel> get sideEventRecords => _sideEventRecords;

  List<CeremonialEventModel> _ceremonialEvents = [];
  List<CeremonialEventModel> get ceremonialEvents => _ceremonialEvents;

  late List<NotificationItem> _notifications;
  List<NotificationItem> get notifications => _notifications;

  List<ScheduleSlot> _scheduleSlots = [];
  List<ScheduleSlot> get scheduleSlots => _scheduleSlots;

  final List<CustomBreakItem> _customBreaks = [];
  List<CustomBreakItem> get customBreaks => _customBreaks;

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
    _programs = [];
    _participants = [];
    _madrasas = [];
    _notifications = List.from(DummyData.initialNotifications);

    _fetchMadrasasFromFirestore();
    _fetchParticipantsFromFirestore();
    _fetchProgramsFromFirestore();
    _fetchPresentRecordsFromFirestore();
    _fetchMarkRecordsFromFirestore();
    _fetchTeamRecordsFromFirestore();
    _fetchSideEventsFromFirestore();
    _fetchCeremonialEventsFromFirestore();
    generateAutoSchedule();
    _loadUserSession();
  }

  void _fetchCeremonialEventsFromFirestore() {
    try {
      FirebaseFirestore.instance
          .collection('madrasa')
          .doc(_madrasaId)
          .collection('ceremonial_events')
          .snapshots()
          .listen((snapshot) {
        _ceremonialEvents = snapshot.docs.map((doc) => CeremonialEventModel.fromSnapshot(doc)).toList();
        notifyListeners();
      }, onError: (e) {
        debugPrint('Firestore _fetchCeremonialEventsFromFirestore error: $e');
      });
    } catch (e) {
      debugPrint('Firestore ceremonial stream init error: $e');
    }
  }

  Future<bool> saveCeremonialEventToFirestore(CeremonialEventModel event) async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection('madrasa')
          .doc(_madrasaId)
          .collection('ceremonial_events')
          .doc(event.eventId);

      await docRef.set(event.toMap());

      final idx = _ceremonialEvents.indexWhere((e) => e.eventId == event.eventId);
      if (idx >= 0) {
        _ceremonialEvents[idx] = event;
      } else {
        _ceremonialEvents.add(event);
      }

      addSpecialProgram(
        title: '${event.programName}${event.personName.isNotEmpty ? " - ${event.personName}" : ""}${event.personDesignation.isNotEmpty ? " (${event.personDesignation})" : ""}',
        category: event.programType,
        durationMinutes: event.durationMinutes,
        stage: 'Main Stage',
      );

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error saving ceremonial event to Firestore: $e');
      return false;
    }
  }

  void _fetchMadrasasFromFirestore() {
    try {
      FirebaseFirestore.instance.collection('madrasa').snapshots().listen((snapshot) {
        final fetched = snapshot.docs.map((doc) => MadrasaModel.fromSnapshot(doc)).toList();
        if (fetched.isNotEmpty) {
          _madrasas = fetched;
        }
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
        if (_realParticipants.isNotEmpty) {
          _participants = _realParticipants.map((p) => p.toParticipant()).toList();
        }
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
        if (_realPrograms.isNotEmpty) {
          _programs = _realPrograms.map((p) => p.toProgram()).toList();
          generateAutoSchedule();
        }
        notifyListeners();
      }, onError: (e) {
        debugPrint('Firestore _fetchProgramsFromFirestore group stream error: $e');
      });
    } catch (e) {
      debugPrint('Firestore group stream init error: $e');
    }
  }

  void _fetchPresentRecordsFromFirestore() {
    try {
      FirebaseFirestore.instance
          .collection('madrasa')
          .doc(_madrasaId)
          .collection('present')
          .snapshots()
          .listen((snapshot) {
        _presentRecords = snapshot.docs.map((doc) => PresentModel.fromSnapshot(doc)).toList();
        notifyListeners();
      }, onError: (e) {
        debugPrint('Firestore _fetchPresentRecordsFromFirestore stream error: $e');
      });
    } catch (e) {
      debugPrint('Firestore present stream error: $e');
    }
  }

  void _fetchMarkRecordsFromFirestore() {
    try {
      FirebaseFirestore.instance
          .collection('madrasa')
          .doc(_madrasaId)
          .collection('mark')
          .snapshots()
          .listen((snapshot) {
        _markRecords = snapshot.docs.map((doc) => MarkModel.fromSnapshot(doc)).toList();
        notifyListeners();
      }, onError: (e) {
        debugPrint('Firestore _fetchMarkRecordsFromFirestore stream error: $e');
      });
    } catch (e) {
      debugPrint('Firestore mark stream error: $e');
    }
  }

  void _fetchTeamRecordsFromFirestore() {
    try {
      FirebaseFirestore.instance
          .collection('madrasa')
          .doc(_madrasaId)
          .collection('teams')
          .snapshots()
          .listen((snapshot) {
        _teamRecords = snapshot.docs.map((doc) => TeamModel.fromMap(doc.data())).toList();
        TeamModel.calculateTiedRanks(_teamRecords);
        recalculateAllTeamScoresAndMedals();
        notifyListeners();
      }, onError: (e) {
        debugPrint('Firestore _fetchTeamRecordsFromFirestore stream error: $e');
      });
    } catch (e) {
      debugPrint('Firestore teams stream error: $e');
    }
  }

  Future<bool> saveTeamRecordToFirestore(TeamModel record) async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection('madrasa')
          .doc(_madrasaId)
          .collection('teams')
          .doc(record.teamId);

      await docRef.set(record.toMap());

      final idx = _teamRecords.indexWhere((r) => r.teamId == record.teamId);
      if (idx >= 0) {
        _teamRecords[idx] = record;
      } else {
        _teamRecords.add(record);
      }
      TeamModel.calculateTiedRanks(_teamRecords);
      recalculateAllTeamScoresAndMedals();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error saving team record to Firestore: $e');
      return false;
    }
  }

  Future<bool> deleteTeamRecordFromFirestore(String teamId) async {
    try {
      await FirebaseFirestore.instance
          .collection('madrasa')
          .doc(_madrasaId)
          .collection('teams')
          .doc(teamId)
          .delete();

      _teamRecords.removeWhere((r) => r.teamId == teamId);
      TeamModel.calculateTiedRanks(_teamRecords);
      recalculateAllTeamScoresAndMedals();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error deleting team record from Firestore: $e');
      return false;
    }
  }

  void _fetchSideEventsFromFirestore() {
    try {
      FirebaseFirestore.instance
          .collection('madrasa')
          .doc(_madrasaId)
          .collection('side_events')
          .snapshots()
          .listen((snapshot) async {
        _sideEventRecords = snapshot.docs.map((doc) => SideEventModel.fromMap(doc.data())).toList();

        // Merge any uncompleted local drafts from SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        for (int i = 0; i < _sideEventRecords.length; i++) {
          final key = 'draft_side_event_${_sideEventRecords[i].sideEventId}';
          if (_sideEventRecords[i].sideEventStatus != 'completed' && prefs.containsKey(key)) {
            final draftJson = prefs.getString(key);
            if (draftJson != null) {
              try {
                final Map<String, dynamic> map = jsonDecode(draftJson);
                _sideEventRecords[i] = SideEventModel.fromMap(map);
              } catch (e) {
                debugPrint('Error parsing local side event draft: $e');
              }
            }
          }
        }

        recalculateAllTeamScoresAndMedals();
        notifyListeners();
      }, onError: (e) {
        debugPrint('Firestore _fetchSideEventsFromFirestore stream error: $e');
      });
    } catch (e) {
      debugPrint('Firestore side_events stream error: $e');
    }
  }

  // --- SAVE SIDE EVENT SCORE SHEET ACCORDING TO STATUS RULE ---
  // If status is 'completed' -> Commit to Cloud Firestore & recalculate team scores/medals.
  // Otherwise ('live now' or 'pending') -> Save draft locally in SharedPreferences.
  Future<bool> saveSideEventRecordWithStatusRule(SideEventModel record) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'draft_side_event_${record.sideEventId}';

      if (record.sideEventStatus == 'completed') {
        // COMMIT TO FIRESTORE ON COMPLETED
        final docRef = FirebaseFirestore.instance
            .collection('madrasa')
            .doc(_madrasaId)
            .collection('side_events')
            .doc(record.sideEventId);

        await docRef.set(record.toMap());

        // Remove local draft
        await prefs.remove(key);

        final idx = _sideEventRecords.indexWhere((r) => r.sideEventId == record.sideEventId);
        if (idx >= 0) {
          _sideEventRecords[idx] = record;
        } else {
          _sideEventRecords.add(record);
        }
        await recalculateAllTeamScoresAndMedals();
        notifyListeners();
        return true;
      } else {
        // DRAFT SAVE LOCALLY IN SHAREDPREFERENCES
        final jsonStr = jsonEncode(record.toMap());
        await prefs.setString(key, jsonStr);

        final idx = _sideEventRecords.indexWhere((r) => r.sideEventId == record.sideEventId);
        if (idx >= 0) {
          _sideEventRecords[idx] = record;
        } else {
          _sideEventRecords.add(record);
        }
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Error in saveSideEventRecordWithStatusRule: $e');
      return false;
    }
  }

  Future<bool> saveSideEventRecordToFirestore(SideEventModel record) async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection('madrasa')
          .doc(_madrasaId)
          .collection('side_events')
          .doc(record.sideEventId);

      await docRef.set(record.toMap());

      final idx = _sideEventRecords.indexWhere((r) => r.sideEventId == record.sideEventId);
      if (idx >= 0) {
        _sideEventRecords[idx] = record;
      } else {
        _sideEventRecords.add(record);
      }

      if (record.sideEventStatus == 'completed') {
        await recalculateAllTeamScoresAndMedals();
      }

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error saving side event record to Firestore: $e');
      return false;
    }
  }

  // --- RECALCULATE ALL TEAM POINTS & MEDAL TALLY IN CLOUD FIRESTORE ---
  Future<void> recalculateAllTeamScoresAndMedals() async {
    if (_teamRecords.isEmpty) return;

    for (var team in _teamRecords) {
      int totalPts = 0;
      int firstCnt = 0;
      int secondCnt = 0;
      int thirdCnt = 0;
      List<TeamMedalWinnerModel> firstList = [];
      List<TeamMedalWinnerModel> secondList = [];
      List<TeamMedalWinnerModel> thirdList = [];

      for (var se in _sideEventRecords) {
        // ONLY INCLUDE COMPLETED SIDE EVENTS WHEN UPDATING FIRESTORE TEAM SCORES AND MEDALS
        if (se.sideEventStatus == 'completed') {
          for (var p in se.participants) {
            bool isInTeam = p.teamId == team.teamId || team.members.any((m) => m.participantId == p.participantId);
            if (isInTeam) {
              totalPts += p.point;

              if (p.rank == 1 && p.point > 0) {
                firstCnt++;
                firstList.add(TeamMedalWinnerModel(
                  participantId: p.participantId,
                  participantName: p.participantName,
                  participantClass: p.participantClass,
                  participantDiv: p.participantDiv,
                  sideEventId: se.sideEventId,
                ));
              } else if (p.rank == 2 && p.point > 0) {
                secondCnt++;
                secondList.add(TeamMedalWinnerModel(
                  participantId: p.participantId,
                  participantName: p.participantName,
                  participantClass: p.participantClass,
                  participantDiv: p.participantDiv,
                  sideEventId: se.sideEventId,
                ));
              } else if (p.rank == 3 && p.point > 0) {
                thirdCnt++;
                thirdList.add(TeamMedalWinnerModel(
                  participantId: p.participantId,
                  participantName: p.participantName,
                  participantClass: p.participantClass,
                  participantDiv: p.participantDiv,
                  sideEventId: se.sideEventId,
                ));
              }
            }
          }
        }
      }

      final updatedTeam = TeamModel(
        teamId: team.teamId,
        teamName: team.teamName,
        teamHouse: team.teamHouse,
        houseColor: team.houseColor,
        teamCaptain: team.teamCaptain,
        teamViceCaptain: team.teamViceCaptain,
        totalMembers: team.members.length,
        overallPoint: totalPts,
        members: team.members,
        overallMedals: TeamMedalsModel(
          firstCount: firstCnt,
          firstMedals: firstList,
          secondCount: secondCnt,
          secondMedals: secondList,
          thirdCount: thirdCnt,
          thirdMedals: thirdList,
        ),
      );

      final docRef = FirebaseFirestore.instance
          .collection('madrasa')
          .doc(_madrasaId)
          .collection('teams')
          .doc(team.teamId);

      await docRef.set(updatedTeam.toMap());

      final idx = _teamRecords.indexWhere((r) => r.teamId == team.teamId);
      if (idx >= 0) {
        _teamRecords[idx] = updatedTeam;
      }
    }

    TeamModel.calculateTiedRanks(_teamRecords);
  }

  // --- DELETE TEAM RECORD FROM FIRESTORE & UNASSIGN MEMBERS ---
  Future<void> deleteTeamFromFirestore(String teamId) async {
    try {
      // 1. Delete team document from Cloud Firestore
      await FirebaseFirestore.instance
          .collection('madrasa')
          .doc(_madrasaId)
          .collection('teams')
          .doc(teamId)
          .delete();

      // 2. Unassign teamId and teamName (set to '') for all participants in side events
      for (var se in _sideEventRecords) {
        bool isModified = false;
        for (var p in se.participants) {
          if (p.teamId == teamId) {
            p.teamId = '';
            p.teamName = '';
            isModified = true;
          }
        }
        for (var r in se.rounds) {
          for (var rp in r.participants) {
            if (rp.teamId == teamId) {
              rp.teamId = '';
              rp.teamName = '';
              isModified = true;
            }
          }
        }
        if (isModified) {
          await saveSideEventRecordToFirestore(se);
        }
      }

      // 3. Remove team from local memory
      _teamRecords.removeWhere((t) => t.teamId == teamId);

      // 4. Recalculate standings and notify
      await recalculateAllTeamScoresAndMedals();
      notifyListeners();
    } catch (e) {
      debugPrint("Error deleting team $teamId: $e");
    }
  }

  // --- REASSIGN STUDENT TEAM (UPDATES SIDE EVENTS IN FIRESTORE & TRANSFERS SCORE/MEDALS) ---
  Future<void> assignStudentToTeam({
    required String studentId,
    required String studentName,
    required String studentClass,
    required String studentDiv,
    required TeamModel newTeam,
  }) async {
    // 1. Remove student from any existing team (Old Team)
    for (var t in _teamRecords) {
      if (t.teamId != newTeam.teamId && t.members.any((m) => m.participantId == studentId)) {
        t.members.removeWhere((m) => m.participantId == studentId);
        final updatedOldTeam = TeamModel(
          teamId: t.teamId,
          teamName: t.teamName,
          teamHouse: t.teamHouse,
          houseColor: t.houseColor,
          teamCaptain: t.teamCaptain,
          teamViceCaptain: t.teamViceCaptain,
          totalMembers: t.members.length,
          overallPoint: t.overallPoint,
          members: t.members,
          overallMedals: t.overallMedals,
        );
        await saveTeamRecordToFirestore(updatedOldTeam);
      }
    }

    // 2. Add to New Team
    if (!newTeam.members.any((m) => m.participantId == studentId)) {
      newTeam.members.add(
        TeamMemberModel(
          participantId: studentId,
          participantName: studentName,
          participantClass: studentClass,
          participantDiv: studentDiv,
        ),
      );
      await saveTeamRecordToFirestore(newTeam);
    }

    // 3. Update all Side Events in Firestore with new teamId and teamName
    String matchedTeamName = '${newTeam.teamName} (${newTeam.teamHouse})';
    for (var se in _sideEventRecords) {
      bool isModified = false;
      for (var p in se.participants) {
        if (p.participantId == studentId) {
          p.teamId = newTeam.teamId;
          p.teamName = matchedTeamName;
          isModified = true;
        }
      }
      for (var r in se.rounds) {
        for (var rp in r.participants) {
          if (rp.participantId == studentId) {
            rp.teamId = newTeam.teamId;
            rp.teamName = matchedTeamName;
            isModified = true;
          }
        }
      }
      if (isModified) {
        await saveSideEventRecordToFirestore(se);
      }
    }

    // 4. Recalculate all scores & medals across teams
    await recalculateAllTeamScoresAndMedals();
    notifyListeners();
  }

  Future<void> removeStudentFromTeam({
    required String studentId,
    required TeamModel team,
  }) async {
    team.members.removeWhere((m) => m.participantId == studentId);
    await saveTeamRecordToFirestore(team);

    // Clear teamId and teamName from Side Events in Firestore
    for (var se in _sideEventRecords) {
      bool isModified = false;
      for (var p in se.participants) {
        if (p.participantId == studentId) {
          p.teamId = '';
          p.teamName = '';
          isModified = true;
        }
      }
      for (var r in se.rounds) {
        for (var rp in r.participants) {
          if (rp.participantId == studentId) {
            rp.teamId = '';
            rp.teamName = '';
            isModified = true;
          }
        }
      }
      if (isModified) {
        await saveSideEventRecordToFirestore(se);
      }
    }

    await recalculateAllTeamScoresAndMedals();
    notifyListeners();
  }

  Future<bool> deleteSideEventRecordFromFirestore(String sideEventId) async {
    try {
      await FirebaseFirestore.instance
          .collection('madrasa')
          .doc(_madrasaId)
          .collection('side_events')
          .doc(sideEventId)
          .delete();

      _sideEventRecords.removeWhere((r) => r.sideEventId == sideEventId);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error deleting side event record from Firestore: $e');
      return false;
    }
  }

  Future<bool> saveMarkRecordToFirestore(MarkModel record) async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection('madrasa')
          .doc(_madrasaId)
          .collection('mark')
          .doc(record.docId);

      await docRef.set(record.toMap());

      final idx = _markRecords.indexWhere((r) => r.docId == record.docId);
      if (idx >= 0) {
        _markRecords[idx] = record;
      } else {
        _markRecords.add(record);
      }
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error saving mark record to Firestore: $e');
      return false;
    }
  }

  Future<bool> deleteMarkRecordFromFirestore(String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection('madrasa')
          .doc(_madrasaId)
          .collection('mark')
          .doc(docId)
          .delete();

      _markRecords.removeWhere((r) => r.docId == docId);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error deleting mark record from Firestore: $e');
      return false;
    }
  }

  Future<bool> savePresentRecordToFirestore(PresentModel record) async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection('madrasa')
          .doc(_madrasaId)
          .collection('present')
          .doc(record.docId);

      await docRef.set(record.toMap());

      final idx = _presentRecords.indexWhere((r) => r.docId == record.docId);
      if (idx >= 0) {
        _presentRecords[idx] = record;
      } else {
        _presentRecords.add(record);
      }
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error saving present record to Firestore: $e');
      return false;
    }
  }

  Future<bool> deletePresentRecordFromFirestore(String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection('madrasa')
          .doc(_madrasaId)
          .collection('present')
          .doc(docId)
          .delete();

      _presentRecords.removeWhere((r) => r.docId == docId);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error deleting present record from Firestore: $e');
      return false;
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

  void resetManualProgramOrder() {
    _programs = List.from(DummyData.initialPrograms);
    generateAutoSchedule();
    notifyListeners();
  }

  void addSpecialProgram({
    required String title,
    required String category,
    required int durationMinutes,
    required String stage,
  }) {
    final newId = 'special-${DateTime.now().millisecondsSinceEpoch}';
    final newProg = Program(
      id: newId,
      number: 'SP-${_programs.length + 1}',
      studentName: 'Committee / Inaugural Event',
      studentPhoto: '',
      studentClass: 'Ceremonial',
      category: category,
      item: title,
      durationMinutes: durationMinutes,
      stage: stage,
      status: ProgramStatus.pending,
      startTime: '08:30 AM',
      teacher: 'Festival Committee',
      priority: 'High',
    );
    _programs.insert(0, newProg);
    generateAutoSchedule();
    notifyListeners();
  }

  // Automatic Schedule Generation
  void generateAutoSchedule({
    int fallbackDurationMins = 12,
    int stageBufferSecs = 60,
    int participantGapMins = 20,
    bool autoShiftOnCancel = true,
  }) {
    _scheduleSlots = ScheduleGenerator.generateSchedule(
      programs: _programs,
      startTime: defaultStartTime,
      dhuhrTime: dhuhrPrayerTime,
      asrTime: asrPrayerTime,
      breakDurationMins: 15,
      dhuhrDurationMins: 45,
      customBreaks: _customBreaks,
      fallbackDurationMins: fallbackDurationMins,
      stageBufferSecs: stageBufferSecs,
      participantGapMins: participantGapMins,
      autoShiftOnCancel: autoShiftOnCancel,
    );
    notifyListeners();
  }

  void addCustomBreak(CustomBreakItem breakItem) {
    _customBreaks.add(breakItem);
    generateAutoSchedule();
  }

  void removeCustomBreak(String id) {
    _customBreaks.removeWhere((b) => b.id == id);
    generateAutoSchedule();
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
