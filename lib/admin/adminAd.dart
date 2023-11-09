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
        title: Text(
          "광고 관리",
          style: TextStyle(
            color: Color(0xff424242),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Color(0xff424242),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
      ),
    );
  }
}
