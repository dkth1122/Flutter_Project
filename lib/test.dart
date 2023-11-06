import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: Test(),
    // 테스트 스크린을 앱의 홈 화면으로 설정합니다.
  ));
}

class Test extends StatefulWidget {
  const Test({Key? key}) : super(key: key);

  @override
  _TestState createState() => _TestState();
}

class _TestState extends State<Test> {
  int currentPage = 0;
  final List<String> tutorialPages = [
    "페이지 1 내용",
    "페이지 2 내용",
    "페이지 3 내용",
  ];

  void nextPage() {
    if (currentPage < tutorialPages.length - 1) {
      setState(() {
        currentPage++;
      });
    }
  }

  void previousPage() {
    if (currentPage > 0) {
      setState(() {
        currentPage--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("테스트 튜토리얼")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              tutorialPages[currentPage],
              style: TextStyle(fontSize: 24.0),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  onPressed: previousPage,
                  child: Text("이전"),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: nextPage,
                  child: Text("다음"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
