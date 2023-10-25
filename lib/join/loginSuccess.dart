import 'package:flutter/material.dart';

class LoginSuccess extends StatefulWidget {
  const LoginSuccess({super.key});

  @override
  State<LoginSuccess> createState() => _LoginSuccessState();
}

class _LoginSuccessState extends State<LoginSuccess> {
  @override
  Widget build(BuildContext context) {
    return Text("로그인성공페이지", style: TextStyle(fontFamily: 'Pretendard'),);
  }
}
