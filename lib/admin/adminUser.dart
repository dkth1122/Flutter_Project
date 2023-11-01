import 'package:flutter/material.dart';

class AdminUser extends StatefulWidget {

  @override
  State<AdminUser> createState() => _AdminUserState();
}

class _AdminUserState extends State<AdminUser> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('회원 관리'),
        backgroundColor: Color(0xff328772),
      ),
      body: Center(
      ),
    );
  }
}