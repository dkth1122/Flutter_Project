import 'package:flutter/material.dart';

class Test extends StatefulWidget {
  const Test({Key? key});

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
      body: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Image.asset('assets/cat1.jpeg'),
                  Image.asset('assets/cat1.jpeg'),
                  Image.asset('assets/cat1.jpeg'),
                  Image.asset('assets/cat1.jpeg'),
                  Image.asset('assets/cat1.jpeg'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}