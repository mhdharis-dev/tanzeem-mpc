class SideEventRoundParticipantModel {
  final String participantId;
  final String participantName;
  final String participantClass;
  final String participantDiv;
  int roundPoint;
  int roundRank;
  String teamId;
  String teamName;
  String roundStatus; // 'passed' or 'failed'

  SideEventRoundParticipantModel({
    required this.participantId,
    required this.participantName,
    required this.participantClass,
    required this.participantDiv,
    this.roundPoint = 0,
    this.roundRank = 1,
    this.teamId = '',
    this.teamName = '',
    this.roundStatus = 'passed',
  });

  factory SideEventRoundParticipantModel.fromMap(Map<String, dynamic> map) {
    return SideEventRoundParticipantModel(
      participantId: map['participantId'] ?? '',
      participantName: map['participantName'] ?? map['name'] ?? '',
      participantClass: map['participantClass'] ?? map['currentClass'] ?? '',
      participantDiv: map['participantDiv'] ?? map['currentDiv'] ?? 'A',
      roundPoint: map['roundPoint'] ?? map['point'] ?? map['studentMark'] ?? 0,
      roundRank: map['roundRank'] ?? map['rank'] ?? 1,
      teamId: map['teamId'] ?? '',
      teamName: map['teamName'] ?? '',
      roundStatus: map['roundStatus'] ?? map['status'] ?? 'passed',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'participantId': participantId,
      'participantName': participantName,
      'participantClass': participantClass,
      'participantDiv': participantDiv,
      'roundPoint': roundPoint,
      'roundRank': roundRank,
      'teamId': teamId,
      'teamName': teamName,
      'roundStatus': roundStatus,
    };
  }
}

class SideEventRoundModel {
  final int roundNumber;
  int minPointToPass;
  final List<SideEventRoundParticipantModel> participants;

  SideEventRoundModel({
    required this.roundNumber,
    this.minPointToPass = 0,
    List<SideEventRoundParticipantModel>? participants,
  }) : participants = participants ?? [];

  factory SideEventRoundModel.fromMap(Map<String, dynamic> map) {
    return SideEventRoundModel(
      roundNumber: map['roundNumber'] ?? 1,
      minPointToPass: map['minPointToPass'] ?? 0,
      participants: (map['participants'] as List<dynamic>?)
              ?.map((x) => SideEventRoundParticipantModel.fromMap(x as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'roundNumber': roundNumber,
      'minPointToPass': minPointToPass,
      'participants': participants.map((x) => x.toMap()).toList(),
    };
  }

  /// Calculates tied ranks for a round's participants based on points (highest point = rank 1).
  void calculateRanks() {
    if (participants.isEmpty) return;

    participants.sort((a, b) => b.roundPoint.compareTo(a.roundPoint));

    int currentRank = 1;
    participants[0].roundRank = 1;

    for (int i = 1; i < participants.length; i++) {
      if (participants[i].roundPoint == participants[i - 1].roundPoint) {
        participants[i].roundRank = participants[i - 1].roundRank;
      } else {
        currentRank = i + 1;
        participants[i].roundRank = currentRank;
      }
    }
  }

  /// Updates roundStatus ('passed' or 'failed') based on minPointToPass cutoff.
  void updateQualificationStatuses() {
    for (var p in participants) {
      p.roundStatus = (p.roundPoint >= minPointToPass) ? 'passed' : 'failed';
    }
  }
}

class SideEventParticipantModel {
  final String participantId;
  final String participantName;
  final String participantClass;
  final String participantDiv;
  int point;
  int rank;
  String teamId;
  String teamName;

  SideEventParticipantModel({
    required this.participantId,
    required this.participantName,
    required this.participantClass,
    required this.participantDiv,
    this.point = 0,
    this.rank = 1,
    this.teamId = '',
    this.teamName = '',
  });

  factory SideEventParticipantModel.fromMap(Map<String, dynamic> map) {
    return SideEventParticipantModel(
      participantId: map['participantId'] ?? '',
      participantName: map['participantName'] ?? map['name'] ?? '',
      participantClass: map['participantClass'] ?? map['currentClass'] ?? '',
      participantDiv: map['participantDiv'] ?? map['currentDiv'] ?? 'A',
      point: map['point'] ?? map['studentMark'] ?? 0,
      rank: map['rank'] ?? 1,
      teamId: map['teamId'] ?? '',
      teamName: map['teamName'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'participantId': participantId,
      'participantName': participantName,
      'participantClass': participantClass,
      'participantDiv': participantDiv,
      'point': point,
      'rank': rank,
      'teamId': teamId,
      'teamName': teamName,
    };
  }
}

class SideEventModel {
  final String sideEventId;
  final String sideEventName;
  final int participantsCount;
  final String participantsCategory;
  final String scheduledDate;
  final String scheduledTime;
  final String sideEventColor;
  final int sideEventMaxPoint;
  String sideEventStatus; // 'pending', 'live now', 'completed', 'canceled'
  int totalRounds;
  final List<SideEventRoundModel> rounds;
  final List<SideEventParticipantModel> participants;

  SideEventModel({
    required this.sideEventId,
    required this.sideEventName,
    required this.participantsCount,
    required this.participantsCategory,
    required this.scheduledDate,
    required this.scheduledTime,
    required this.sideEventColor,
    this.sideEventMaxPoint = 50,
    this.sideEventStatus = 'pending',
    this.totalRounds = 1,
    List<SideEventRoundModel>? rounds,
    List<SideEventParticipantModel>? participants,
  })  : rounds = rounds ?? [],
        participants = participants ?? [];

  factory SideEventModel.fromMap(Map<String, dynamic> map) {
    List<SideEventRoundModel> parsedRounds = (map['rounds'] as List<dynamic>?)
            ?.map((x) => SideEventRoundModel.fromMap(x as Map<String, dynamic>))
            .toList() ??
        [];

    List<SideEventParticipantModel> parsedParticipants = (map['participants'] as List<dynamic>?)
            ?.map((x) => SideEventParticipantModel.fromMap(x as Map<String, dynamic>))
            .toList() ??
        [];

    // Ensure at least 1 round exists for legacy compatibility
    if (parsedRounds.isEmpty) {
      final initialRoundParticipants = parsedParticipants
          .map((p) => SideEventRoundParticipantModel(
                participantId: p.participantId,
                participantName: p.participantName,
                participantClass: p.participantClass,
                participantDiv: p.participantDiv,
                roundPoint: p.point,
                roundRank: p.rank,
                teamId: p.teamId,
                teamName: p.teamName,
                roundStatus: 'passed',
              ))
          .toList();

      parsedRounds = [
        SideEventRoundModel(
          roundNumber: 1,
          minPointToPass: 0,
          participants: initialRoundParticipants,
        ),
      ];
    }

    return SideEventModel(
      sideEventId: map['sideEventId'] ?? '',
      sideEventName: map['sideEventName'] ?? '',
      participantsCount: map['participantsCount'] ?? parsedParticipants.length,
      participantsCategory: map['participantsCategory'] ?? 'All',
      scheduledDate: map['scheduledDate'] ?? '',
      scheduledTime: map['scheduledTime'] ?? '',
      sideEventColor: map['sideEventColor'] ?? '0xFF14B8A6',
      sideEventMaxPoint: map['sideEventMaxPoint'] ?? 50,
      sideEventStatus: map['sideEventStatus'] ?? 'pending',
      totalRounds: map['totalRounds'] ?? parsedRounds.length,
      rounds: parsedRounds,
      participants: parsedParticipants,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sideEventId': sideEventId,
      'sideEventName': sideEventName,
      'participantsCount': participants.length,
      'participantsCategory': participantsCategory,
      'scheduledDate': scheduledDate,
      'scheduledTime': scheduledTime,
      'sideEventColor': sideEventColor,
      'sideEventMaxPoint': sideEventMaxPoint,
      'sideEventStatus': sideEventStatus,
      'totalRounds': rounds.length,
      'rounds': rounds.map((x) => x.toMap()).toList(),
      'participants': participants.map((x) => x.toMap()).toList(),
    };
  }

  /// Calculates tied ranks for event participants based on points (highest point = rank 1).
  static void calculateParticipantRanks(List<SideEventParticipantModel> parts) {
    if (parts.isEmpty) return;

    parts.sort((a, b) => b.point.compareTo(a.point));

    int currentRank = 1;
    parts[0].rank = 1;

    for (int i = 1; i < parts.length; i++) {
      if (parts[i].point == parts[i - 1].point) {
        parts[i].rank = parts[i - 1].rank;
      } else {
        currentRank = i + 1;
        parts[i].rank = currentRank;
      }
    }
  }
}
