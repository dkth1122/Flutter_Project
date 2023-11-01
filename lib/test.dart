import 'package:flutter/material.dart';

import 'bottomBar.dart';

class Test extends StatefulWidget {
  const Test({super.key});

  @override
  State<Test> createState() => _TestState();
}

class _TestState extends State<Test> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text("테스트")),
      extendBody: true, // body를 침범하도록 함
      bottomNavigationBar: BottomBar(),

    );
  }
}
