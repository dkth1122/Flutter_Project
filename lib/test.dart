import 'package:flutter/material.dart';

class Test extends StatefulWidget {
  const Test({Key? key}) : super(key: key);

  @override
  State<Test> createState() => _TestState();
}

class _TestState extends State<Test> {
  double _dialogHeight = 0.0;

  // 함수를 사용하여 다이얼로그를 표시
  void _showDialog() {
    setState(() {
      _dialogHeight = 200.0; // 원하는 높이로 설정
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 500), // 애니메이션 지속 시간
            tween: Tween<double>(begin: 0, end: 1),
            builder: (BuildContext context, double value, Widget? child) {
              return Transform.translate(
                offset: Offset(0, _dialogHeight * (1 - value)), // 아래에서 위로 슬라이딩
                child: Material(
                  child: Container(
                    height: _dialogHeight,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text('다이얼로그 제목'),
                        Text('다이얼로그 내용'),
                        TextButton(
                          child: Text('닫기'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('애니메이션 다이얼로그 예제'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _showDialog,
          child: Text('다이얼로그 열기'),
        ),
      ),
    );
  }
}
