import 'package:flutter/material.dart';

import 'main.dart';

void main() {
  runApp(
    MaterialApp(
      home: Test(),
    ),
  );
}

class Test extends StatefulWidget {
  const Test({Key? key});

  @override
  State<Test> createState() => _TestState();
}

class _TestState extends State<Test> {
  int currentPage = 0;
  double positionTop = 0.0;

  final List<String> tutorialPages = ["1", "2", "3"];

  Future<void> showDialogWithPosition() async {
    if (mounted) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            insetPadding: EdgeInsets.all(0),
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.transparent,
                ),
                Positioned(
                  top: positionTop,
                  right: 10,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                    ),
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).size.height / 2 - 20,
                  left: MediaQuery.of(context).size.width / 2 - 60,
                  child: ElevatedButton(
                    child: Text('이전'),
                    onPressed: previousPage,
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).size.height / 2 - 20,
                  left: MediaQuery.of(context).size.width / 2 + 20,
                  child: ElevatedButton(
                    child: Text('다음'),
                    onPressed: nextPage,
                  ),
                ),
              ],
            ),
          );
        },
      );
    }
  }



  void nextPage() {
    if (currentPage < tutorialPages.length - 1) {
      setState(() {
        currentPage++;
        positionTop += 100.0;
        showDialogWithPosition(); // 위치를 변경한 다음 다시 Dialog를 열기
      });
    } else {
      Navigator.pop(context); // Dialog 닫기
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    }
  }

  void previousPage() {
    if (currentPage > 0) {
      setState(() {
        currentPage--;
        showDialogWithPosition(); // 위치를 변경한 다음 다시 Dialog를 열기
      });
    }
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 1), () {
      showDialogWithPosition();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('다이얼로그 테스트'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: showDialogWithPosition,
          child: Text('다이얼로그 열기'),
        ),
      ),
    );
  }
}
