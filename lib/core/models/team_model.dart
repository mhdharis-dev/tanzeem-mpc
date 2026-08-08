class TeamMemberModel {
  final String participantId;
  final String participantName;
  final String participantClass;
  final String participantDiv;
  final List<String> sideEventsIds;

  TeamMemberModel({
    required this.participantId,
    required this.participantName,
    required this.participantClass,
    required this.participantDiv,
    List<String>? sideEventsIds,
  }) : sideEventsIds = sideEventsIds ?? [];

  factory TeamMemberModel.fromMap(Map<String, dynamic> map) {
    return TeamMemberModel(
      participantId: map['participantId'] ?? '',
      participantName: map['participantName'] ?? map['name'] ?? '',
      participantClass: map['participantClass'] ?? map['currentClass'] ?? '',
      participantDiv: map['participantDiv'] ?? map['currentDiv'] ?? map['division'] ?? 'A',
      sideEventsIds: List<String>.from(map['sideEventsIds'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'participantId': participantId,
      'participantName': participantName,
      'participantClass': participantClass,
      'participantDiv': participantDiv,
      'sideEventsIds': sideEventsIds,
    };
  }
}

class TeamMedalWinnerModel {
  final String participantId;
  final String participantName;
  final String participantClass;
  final String participantDiv;
  final String sideEventId;

  TeamMedalWinnerModel({
    required this.participantId,
    required this.participantName,
    required this.participantClass,
    required this.participantDiv,
    required this.sideEventId,
  });

  factory TeamMedalWinnerModel.fromMap(Map<String, dynamic> map) {
    return TeamMedalWinnerModel(
      participantId: map['participantId'] ?? '',
      participantName: map['participantName'] ?? '',
      participantClass: map['participantClass'] ?? '',
      participantDiv: map['participantDiv'] ?? 'A',
      sideEventId: map['sideEventId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'participantId': participantId,
      'participantName': participantName,
      'participantClass': participantClass,
      'participantDiv': participantDiv,
      'sideEventId': sideEventId,
    };
  }
}

class TeamMedalsModel {
  final int firstCount;
  final List<TeamMedalWinnerModel> firstMedals;
  final int secondCount;
  final List<TeamMedalWinnerModel> secondMedals;
  final int thirdCount;
  final List<TeamMedalWinnerModel> thirdMedals;

  TeamMedalsModel({
    this.firstCount = 0,
    List<TeamMedalWinnerModel>? firstMedals,
    this.secondCount = 0,
    List<TeamMedalWinnerModel>? secondMedals,
    this.thirdCount = 0,
    List<TeamMedalWinnerModel>? thirdMedals,
  })  : firstMedals = firstMedals ?? [],
        secondMedals = secondMedals ?? [],
        thirdMedals = thirdMedals ?? [];

  factory TeamMedalsModel.fromMap(Map<String, dynamic> map) {
    return TeamMedalsModel(
      firstCount: map['firstCount'] ?? 0,
      firstMedals: (map['firstMedals'] as List<dynamic>?)
              ?.map((x) => TeamMedalWinnerModel.fromMap(x as Map<String, dynamic>))
              .toList() ??
          [],
      secondCount: map['secondCount'] ?? 0,
      secondMedals: (map['secondMedals'] as List<dynamic>?)
              ?.map((x) => TeamMedalWinnerModel.fromMap(x as Map<String, dynamic>))
              .toList() ??
          [],
      thirdCount: map['thirdCount'] ?? 0,
      thirdMedals: (map['thirdMedals'] as List<dynamic>?)
              ?.map((x) => TeamMedalWinnerModel.fromMap(x as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'firstCount': firstCount,
      'firstMedals': firstMedals.map((x) => x.toMap()).toList(),
      'secondCount': secondCount,
      'secondMedals': secondMedals.map((x) => x.toMap()).toList(),
      'thirdCount': thirdCount,
      'thirdMedals': thirdMedals.map((x) => x.toMap()).toList(),
    };
  }
}

class TeamModel {
  final String teamId;
  final String teamName;
  final String teamHouse;
  final String houseColor;
  final TeamMemberModel? teamCaptain;
  final TeamMemberModel? teamViceCaptain;
  final int totalMembers;
  final List<TeamMemberModel> members;
  int rank;
  int overallPoint;
  final TeamMedalsModel overallMedals;
  final String madrasaId;

  TeamModel({
    required this.teamId,
    required this.teamName,
    required this.teamHouse,
    required this.houseColor,
    this.teamCaptain,
    this.teamViceCaptain,
    required this.totalMembers,
    required this.members,
    this.rank = 1,
    this.overallPoint = 0,
    TeamMedalsModel? overallMedals,
    this.madrasaId = '',
  }) : overallMedals = overallMedals ?? TeamMedalsModel();

  factory TeamModel.fromMap(Map<String, dynamic> map) {
    return TeamModel(
      teamId: map['teamId'] ?? '',
      teamName: map['teamName'] ?? '',
      teamHouse: map['teamHouse'] ?? '',
      houseColor: map['houseColor'] ?? '0xFF3B82F6',
      teamCaptain: map['teamCaptain'] != null ? TeamMemberModel.fromMap(map['teamCaptain']) : null,
      teamViceCaptain: map['teamViceCaptain'] != null ? TeamMemberModel.fromMap(map['teamViceCaptain']) : null,
      totalMembers: map['totalMembers'] ?? 0,
      members: (map['members'] as List<dynamic>?)
              ?.map((x) => TeamMemberModel.fromMap(x as Map<String, dynamic>))
              .toList() ??
          [],
      rank: map['rank'] ?? 1,
      overallPoint: map['overallPoint'] ?? 0,
      overallMedals: map['overallMedals'] != null ? TeamMedalsModel.fromMap(map['overallMedals']) : TeamMedalsModel(),
      madrasaId: map['madrasaId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'teamId': teamId,
      'teamName': teamName,
      'teamHouse': teamHouse,
      'houseColor': houseColor,
      'teamCaptain': teamCaptain?.toMap(),
      'teamViceCaptain': teamViceCaptain?.toMap(),
      'totalMembers': totalMembers,
      'members': members.map((x) => x.toMap()).toList(),
      'rank': rank,
      'overallPoint': overallPoint,
      'overallMedals': overallMedals.toMap(),
      'madrasaId': madrasaId,
    };
  }

  /// Calculates tied ranks for a list of teams based on overall points (highest score = rank 1).
  static void calculateTiedRanks(List<TeamModel> teams) {
    if (teams.isEmpty) return;

    teams.sort((a, b) => b.overallPoint.compareTo(a.overallPoint));

    int currentRank = 1;
    teams[0].rank = 1;

    for (int i = 1; i < teams.length; i++) {
      if (teams[i].overallPoint == teams[i - 1].overallPoint) {
        teams[i].rank = teams[i - 1].rank;
      } else {
        currentRank = i + 1;
        teams[i].rank = currentRank;
      }
    }
  }
}
