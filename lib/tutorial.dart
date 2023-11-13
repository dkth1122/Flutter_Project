import 'package:flutter/material.dart';
import 'main.dart';

void main() {
  runApp(MaterialApp(
    home: Tutorial(),
  ));
}

class Tutorial extends StatefulWidget {
  const Tutorial({Key? key}) : super(key: key);

  @override
  _TutorialState createState() => _TutorialState();
}

class _TutorialState extends State<Tutorial> {
  int currentPage = 0;
  final List<String> tutorialPages = [
    "assets/tutorial1.jpg",
    "assets/tutorial2.jpg",
    "assets/tutorial3.jpg",
  ];

  void nextPage() {
    if (currentPage < tutorialPages.length - 1) {
      setState(() {
        currentPage++;
      });
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MyHomePage()),
      );
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
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  Image.asset(tutorialPages[currentPage]),
                  Container(
                    padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        ElevatedButton(
                          onPressed: previousPage,
                          child: Icon(Icons.arrow_back, size: 32),  // 아이콘을 사용하여 버튼 크기 조절
                          style: ElevatedButton.styleFrom(
                            shape: CircleBorder(),
                            fixedSize: Size(64, 64),  // 버튼 크기 조절
                            primary: Colors.grey,  // 배경색을 회색으로 설정
                          ),
                        ),
                        ElevatedButton(
                          onPressed: nextPage,
                          child: Icon(Icons.arrow_forward, size: 32),  // 아이콘을 사용하여 버튼 크기 조절
                          style: ElevatedButton.styleFrom(
                            shape: CircleBorder(),
                            fixedSize: Size(64, 64),  // 버튼 크기 조절
                            primary: Colors.grey,  // 배경색을 회색으로 설정
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
