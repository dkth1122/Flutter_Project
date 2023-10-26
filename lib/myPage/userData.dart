class UserData {
  final String userId;
  final String pw;
  final String name;
  final String birth;// 이걸로 나이 알수 있음
  final String nick;
  final String email;

  UserData({
    required this.userId,
    required this.pw,
    required this.name,
    required this.birth,
    required this.nick,
    required this.email,
  });

  factory UserData.fromMap(Map<String, dynamic> data) {
    return UserData(
      userId: data['id'] ?? '',
      pw: data['pw'] ?? '',
      name: data['name'] ?? '',
      birth: data['birth'] ?? '',
      nick: data['nick'] ?? '',
      email: data['email'] ?? '',
    );
  }
}
