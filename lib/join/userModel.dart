import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserModel with ChangeNotifier {
  String? _userId;
  String? _status;
  String? get userId => _userId;
  String? get status => _status;
  bool get isLogin => _userId != null;

  UserModel() {
    loadUserLoginState();
  }

  void login(String id, String status) {
    _userId = id;
    _status = status;
    _saveUserLoginState(id, status);
    notifyListeners();
  }

  void logout() {
    _userId = null;
    _status = null; // 로그아웃 시 status를 초기화
    _saveUserLoginState(null, null); // userId와 status 모두 초기화
    notifyListeners();
  }

  final FlutterSecureStorage _storage = FlutterSecureStorage();

  // 사용자 로그인 상태를 안전한 저장소에서 불러오는 메서드
  Future<void> loadUserLoginState() async {
    final userId = await _storage.read(key: 'userId');
    final status = await _storage.read(key: 'status'); // status를 읽어옴
    if (userId != null) {
      _userId = userId;
      _status = status; // status를 설정
      notifyListeners();
    }
  }

  // 사용자 로그인 상태를 안전한 저장소에 저장하는 메서드
  Future<void> _saveUserLoginState(String? userId, String? status) async {
    if (userId != null) {
      await _storage.write(key: 'userId', value: userId);
      await _storage.write(key: 'status', value: status); // status도 저장
    } else {
      await _storage.delete(key: 'userId');
      await _storage.delete(key: 'status'); // userId와 status를 모두 삭제
    }
  }

  void updateStatus(String newStatus) {
    _status = newStatus;
    notifyListeners(); // 상태가 업데이트되었음을 알립니다.
  }
}
