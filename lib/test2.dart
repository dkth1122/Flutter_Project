import 'package:flutter/material.dart';
import 'package:project_flutter/bottomBar.dart';

class Test2 extends StatefulWidget {
  const Test2({super.key});

  @override
  State<Test2> createState() => _Test2State();
}

class _Test2State extends State<Test2> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("테스트"),),
      body: Center(child: Text("테스트")),
      bottomNavigationBar: BottomBar(),
    );
  }
}
