import 'package:cloud_firestore/cloud_firestore.dart';

class UserData {
  final String id; // 사용자 ID
  final String name; // 이름
  final String nick; // 닉네임
  final String email; // 이메일
  final String pw; // 비밀번호
  final String banYn; // ban 여부
  final String delYn; // 삭제 여부
  final String birth; // 생년월일
  final String status; // 상태
  late final DateTime cdatetime; // 생성 시간

  UserData({
    required this.id,
    required this.name,
    required this.nick,
    required this.email,
    required this.pw,
    required this.banYn,
    required this.delYn,
    required this.birth,
    required this.status,
    required this.cdatetime,
  });

  factory UserData.fromMap(Map<String, dynamic> data) {
    return UserData(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      nick: data['nick'] ?? '',
      email: data['email'] ?? '',
      pw: data['pw'] ?? '',
      banYn: data['banYn'] ?? '',
      delYn: data['delYn'] ?? '',
      birth: data['birth'] ?? '',
      status: data['status'] ?? '',
      cdatetime: (data['cdatetime'] as Timestamp).toDate() ?? DateTime.now(),
    );
  }
}
