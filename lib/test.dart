import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:project_flutter/join/login_email.dart';
import 'package:project_flutter/product.dart';


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
  double rotation = 0.0;
  Offset initialPosition = Offset(0, 0);
  Offset currentPosition = Offset(0, 0);
  double containerSize = 100.0; // 초기 컨테이너 크기
  bool isExpanded = false; // 컨테이너 확장 여부
  Color bottomAppBarColor = Colors.white; // BottomAppBar의 배경색

  // 아이콘들의 좌표를 계산하는 함수
  List<Offset> calculateIconOffsets() {
    final double centerX = containerSize / 2;
    final double centerY = containerSize / 2.6;
    final double radius = 110.0; // 반지름

    final List<Offset> iconOffsets = [];

    for (int i = 0; i < 8; i++) {
      final double angle = i * (2 * pi / 8);
      final double x = centerX + radius * cos(angle) - 20; // 20은 아이콘의 크기 반값
      final double y = centerY + radius * sin(angle);
      iconOffsets.add(Offset(x, y));
    }

    return iconOffsets;
  }

  List<Offset> iconOffsets = [];

  List<String> addButtonTexts = ["테스트", "상품", "로그인", "얍얍", "얍얍", "얍얍", "얍얍", "얍얍"];
  List<IconData> iconData = [
    Icons.access_time_filled, Icons.check_box, Icons.person, Icons.chat, Icons.access_alarms_rounded, Icons.back_hand, Icons.cabin_outlined, Icons.dark_mode
  ];
  List<Widget> pageChange = [Test(),Product(),LoginPage(),Test(),Test(),Test(),Test(),Test()];
  List<double> iconRotations = [pi / 2, 135 * (pi / 180), pi, 225 * (pi / 180), 270 * (pi / 180), 315 * (pi / 180), 360 * (pi / 180), 0]; // 각 아이콘의 회전 각도

  void _animateContainerSize() {
    setState(() {
      if (isExpanded) {
        containerSize = 100.0; // 작아짐
        bottomAppBarColor = Colors.white; // 클릭하면 다시 원래 색상으로
        rotation = 0;
      } else {
        containerSize = 300.0; // 확장
        bottomAppBarColor = Color.fromRGBO(222, 222, 222, 1.0); // 클릭하면 회색으로 변경
      }
      isExpanded = !isExpanded; // 상태 업데이트
    });
  }

  // 새로운 위젯을 만들어 아이콘과 텍스트를 포함시킵니다.
  Widget buildAddButton(Offset offset, String text, IconData icon, double rotationAngle, int pageIndex) {
    return Positioned(
      top: offset.dy,
      left: offset.dx,
      child: Transform.rotate(
        angle: rotationAngle,
        child: Column(
          children: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => pageChange[pageIndex]),
                );
              },
              icon: Icon(
                icon,
              ),
            ),
            Text(text),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    iconOffsets = calculateIconOffsets(); // 아이콘 좌표를 계산

    return Scaffold(
      appBar: AppBar(
        title: Text("테스트"),
      ),
      body: Center(
        child: Image.asset('assets/cat1.jpeg'),
      ),
      extendBody: true, // body를 침범하도록 함
      bottomNavigationBar: BottomAppBar(
        color: bottomAppBarColor, // BottomAppBar의 배경색을 변수에 따라 변경
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onPanStart: (details) {
                setState(() {
                  initialPosition = details.localPosition;
                });
              },
              onPanUpdate: (details) {
                setState(() {
                  // Calculate the rotation angle based on the drag direction
                  double angle = (details.localPosition - initialPosition).direction;
                  rotation = angle;
                  currentPosition = details.localPosition;
                });
              },
              onPanEnd: (details) {
                setState(() {
                });
              },
              child: Transform.rotate(
                angle: rotation,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white
                  ),
                  child: InkWell(
                    onTap: () {
                      _animateContainerSize();
                    },
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      width: containerSize,
                      height: containerSize,
                      child: Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          Image.asset('assets/naver.png'),
                          if (isExpanded)
                            for (int i = 0; i < iconOffsets.length; i++)
                              buildAddButton(
                                  iconOffsets[i],
                                  addButtonTexts[i],
                                  iconData[i],
                                  iconRotations[i],
                                  i
                              ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}