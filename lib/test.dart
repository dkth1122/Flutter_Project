import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: Test(),
    // ... (앱 설정 및 라우팅 설정 등)
  ));
}

class Test extends StatefulWidget {
  const Test({Key? key}) : super(key: key);

  @override
  State<Test> createState() => _TestState();
}

class _TestState extends State<Test> {
  bool isExpanded = false; // 다이얼로그 확장 여부

  void _animateDialogPosition() {
    setState(() {
      isExpanded = !isExpanded; // 상태 업데이트
    });
  }

  Widget _buildDialog() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeIn,
        width: double.infinity,
        height: isExpanded ? 150.0 : 0.0, // Dialog height changes
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("바텀"),
      ),
      body: Container(),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          child: ElevatedButton(
            onPressed: () {
              _animateDialogPosition();
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return _buildDialog();
                },
              );
            },
            child: Text("실험"),
          ),
        ),
      ),
    );
  }
}
