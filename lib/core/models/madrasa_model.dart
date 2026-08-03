import 'package:cloud_firestore/cloud_firestore.dart';

class MadrasaModel {
  final String madrasaId; // Auto-generated: ${madrasaRegNo}@tanzeem
  final String madrasaName;
  final String madrasaRegNo;
  final String address;
  final String coordinatorName;
  final String coordinatorPhone;
  final String email; // Auto-generated: ${coordinatorFirstName}@${madrasaRegNo}.tanzeem
  final String password; // Auto-generated: ${coordinatorName}@${madrasaRegNo}
  final String createdAt;
  bool isOnline; // WhatsApp style online active status
  String lastActive; // WhatsApp style last seen / active time

  MadrasaModel({
    required this.madrasaId,
    required this.madrasaName,
    required this.madrasaRegNo,
    required this.address,
    required this.coordinatorName,
    required this.coordinatorPhone,
    required this.email,
    required this.password,
    required this.createdAt,
    this.isOnline = false,
    this.lastActive = 'Offline',
  });

  // Auto-generator helper methods
  static String generateMadrasaId(String regNo) {
    final cleanReg = regNo.trim().replaceAll(' ', '').toLowerCase();
    return cleanReg.isEmpty ? 'regno@tanzeem' : '$cleanReg@tanzeem';
  }

  static String generateEmail(String coordinatorName, String regNo) {
    final firstName = coordinatorName.trim().split(' ').first.toLowerCase();
    final cleanReg = regNo.trim().replaceAll(' ', '').toLowerCase();
    if (firstName.isEmpty || cleanReg.isEmpty) return 'coordinator@regno.tanzeem';
    return '$firstName@$cleanReg.tanzeem';
  }

  static String generatePassword(String coordinatorName, String regNo) {
    final cleanName = coordinatorName.trim().replaceAll(' ', '').toLowerCase();
    final cleanReg = regNo.trim().replaceAll(' ', '').toLowerCase();
    if (cleanName.isEmpty || cleanReg.isEmpty) return 'coordinator@regno';
    return '$cleanName@$cleanReg';
  }

  Map<String, dynamic> toMap() {
    return {
      'madrasaId': madrasaId,
      'madrasaName': madrasaName,
      'madrasaRegNo': madrasaRegNo,
      'address': address,
      'coordinatorName': coordinatorName,
      'coordinatorPhone': coordinatorPhone,
      'email': email,
      'password': password,
      'createdAt': createdAt,
      'isOnline': isOnline,
      'lastActive': lastActive,
    };
  }

  factory MadrasaModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    return MadrasaModel(
      madrasaId: map['madrasaId'] ?? docId ?? '',
      madrasaName: map['madrasaName'] ?? '',
      madrasaRegNo: map['madrasaRegNo'] ?? '',
      address: map['address'] ?? '',
      coordinatorName: map['coordinatorName'] ?? '',
      coordinatorPhone: map['coordinatorPhone'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      createdAt: map['createdAt'] ?? DateTime.now().toIso8601String(),
      isOnline: map['isOnline'] ?? false,
      lastActive: map['lastActive'] ?? 'Offline',
    );
  }

  factory MadrasaModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return MadrasaModel.fromMap(data, docId: doc.id);
  }
}
