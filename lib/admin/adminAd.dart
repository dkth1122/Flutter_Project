import 'package:flutter/material.dart';

class AdminAd extends StatefulWidget {

  @override
  State<AdminAd> createState() => _AdminAdState();
}

class _AdminAdState extends State<AdminAd> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('광고 관리'),
        backgroundColor: Color(0xff328772),
      ),
      body: Center(
      ),
    );
  }
}
