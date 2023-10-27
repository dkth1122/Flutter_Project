import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


class UserModel with ChangeNotifier{
  String? _userId;
  String? get userId => _userId;
  bool get isLogin => _userId != null;

  UserModel(){
    _loadUserLoginState();
  }
  void login(String id){
    _userId = id;
    _saveUserLoginState(id);
    notifyListeners();
  }

  void logout(){
    _userId = null;
    _saveUserLoginState(null);
    notifyListeners();
  }

  final FlutterSecureStorage _storage = FlutterSecureStorage();

  // 사용자 로그인 상태를 안전한 저장소에서 불러오는 메서드
  Future<void> _loadUserLoginState() async {
    final userId = await _storage.read(key: 'userId');
    if (userId != null) {
      _userId = userId;
      notifyListeners();
    }
  }

  // 사용자 로그인 상태를 안전한 저장소에 저장하는 메서드
  Future<void> _saveUserLoginState(String? userId) async {
    if (userId != null) {
      await _storage.write(key: 'userId', value: userId);
    } else {
      await _storage.delete(key: 'userId');
    }
  }

}