import 'package:flutter/material.dart';

class AdminInquiry extends StatefulWidget {

  @override
  State<AdminInquiry> createState() => _AdminInquiryState();
}

class _AdminInquiryState extends State<AdminInquiry> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('문의 관리'),
        backgroundColor: Color(0xFF4E598C),
      ),
      body: Center(
      ),
    );
  }
}