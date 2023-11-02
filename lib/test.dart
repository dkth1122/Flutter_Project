import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'join/userModel.dart';

class Test extends StatefulWidget {
  const Test({super.key});

  @override
  State<Test> createState() => _TestState();
}

class _TestState extends State<Test> {
  bool _isLogged = false; // 로그인 여부를 나타내는 상태
  bool _isFavorite = false; // 하트 아이콘의 색을 나타내는 상태
  final Stream<QuerySnapshot> productStream = FirebaseFirestore.instance.collection("product").snapshots();

  @override
  void initState() {
    super.initState();
    String sessionId = "";

    UserModel um = Provider.of<UserModel>(context, listen: false);

    if (um.isLogin) {
      sessionId = um.userId!;
      _isLogged = true; // 로그인되어 있으면 _isLogged를 true로 설정
      print(sessionId);
    } else {
      sessionId = "";
      print("상품페이지 로그인 안됨");
      print(sessionId);
    }
  }

  void _toggleFavorite() {
    if (_isLogged) {
      setState(() {
        _isFavorite = !_isFavorite; // 클릭할 때마다 색을 토글
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("테스트"),),
      body: Center(
        child: _isLogged
            ? IconButton(
          onPressed: () {
          },
          icon: Icon(Icons.add_circle_outline
          ),
        )
            : Text(""),
      ),
    );
  }
}
