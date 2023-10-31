import 'package:flutter/material.dart';

class Test extends StatefulWidget {
  const Test({super.key});

  @override
  State<Test> createState() => _TestState();
}

class _TestState extends State<Test> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('이미지 테스트'),
      ),
      body: Center(
        child: Image.asset('assets/cat1.jpeg'),
      ),
    )
    ;
  }
}
