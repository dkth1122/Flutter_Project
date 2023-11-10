import 'dart:math';
import 'package:flutter/material.dart';
import 'package:project_flutter/chat/chatList.dart';
import 'package:project_flutter/customer/userCustomer.dart';
import 'package:project_flutter/expert/allPortfolioList.dart';
import 'package:project_flutter/join/login_email.dart';
import 'package:project_flutter/product/product.dart';
import 'package:project_flutter/proposal/myProposalList.dart';
import 'package:project_flutter/subBottomBar.dart';
import 'package:project_flutter/test.dart';
import 'package:project_flutter/tutorial.dart';
import 'package:provider/provider.dart';

import 'expert/messageResponse.dart';
import 'expert/my_expert.dart';
import 'expert/ratings.dart';
import 'expert/revenue.dart';
import 'join/userModel.dart';
import 'main.dart';
import 'myPage/myCoupon.dart';
import 'myPage/myCustomer.dart';
import 'myPage/myLike.dart';
import 'myPage/purchaseManagement.dart';

class CircularDialog extends StatefulWidget {
  @override
  State<CircularDialog> createState() => _CircularDialogState();
}
String sessionId = "";
class _CircularDialogState extends State<CircularDialog> {
  double rotation = 0.0;
  Offset initialPosition = Offset(0, 0);
  Offset currentPosition = Offset(0, 0);
  double dialogScale = 0.0; // 다이얼로그 크기의 초기 값
  double _dialogHeight = 0.0;

  List<Offset> calculateIconOffsets() {
    final double centerX = 300 / 2; // 컨테이너 가로 길이의 절반
    final double centerY = 300 / 2; // 컨테이너 세로 길이의 절반
    final double radius = 100.0; // 반지름

    final List<Offset> iconOffsets = [];

    for (int i = 0; i < 8; i++) {
      final double angle = i * (pi / 4); // 45도 간격으로 아이콘 배치
      final double x = centerX + radius * cos(angle) - 25; // 20은 아이콘의 크기 반값
      final double y = centerY + radius * sin(angle) - 30;
      iconOffsets.add(Offset(x, y));
    }

    return iconOffsets;
  }

  List<Offset> iconOffsets = [];
  List<String> addButtonTexts = ["구매관리", "쿠폰관리", "고객센터", "수익관리", "응답관리", "등급확인", "상품보기", "프로젝트"];
  List<IconData> iconData = [Icons.shopping_cart,Icons.card_giftcard,  Icons.headset_mic,  Icons.attach_money, Icons.chat, Icons.grade, Icons.shopping_bag,  Icons.insert_drive_file];
  List<Widget> pageChange = [PurchaseManagement(userId:sessionId),MyCoupon(),UserCustomer(),Revenue(),MessageResponse(),ExpertRating(),Product(),MyProposalList(userId : sessionId)];
  List<double> iconRotations = [pi / 2, 135 * (pi / 180), pi, 225 * (pi / 180), 270 * (pi / 180), 315 * (pi / 180), 360 * (pi / 180), 45 * (pi / 180)]; // 각 아이콘의 회전 각도
  List<Color> iconColors = [
    Color(0xFF5B5BFF),//구매
    Color(0xFF5B5BFF),//쿠폰

    Color(0xff79c41f),//고객센터

    Color(0xFFFF7D29),//수익
    Color(0xFFFF7D29),//응답
    Color(0xFFFF7D29),//등급

    Color(0xff79c41f),//상품보기

    Color(0xFF5B5BFF),//내프젝
  ];
  @override
  void initState() {
    super.initState();
    iconOffsets = calculateIconOffsets();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      alignment: Alignment.bottomCenter, // 중앙 정렬
      child: TweenAnimationBuilder<double>(
        duration: Duration(milliseconds: 500),
        tween: Tween<double>(begin: 0.0, end: 1.0),
        builder: (BuildContext context, double value, Widget? child) {
          dialogScale = value; // 크기 업데이트
          _dialogHeight = 200.0; // 원하는 높이로 설정

          return GestureDetector(
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
            child: Transform.translate(
              offset: Offset(0, _dialogHeight * (1 - value)), // 아래에서 위로 슬라이딩
              child: Transform.scale(
                scale: dialogScale,
                child: Transform.rotate(
                  angle: -360 * (pi / 180) + (360 * (pi / 180) * value),
                  child: Transform.rotate(
                    angle: rotation,
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          InkWell(
                            onTap: () {

                              Navigator.of(context).pop();
                            },
                            child: Image.asset(
                              'assets/logo.png',
                              width: 70,
                              height: 70,
                            ),
                          ),
                          for (int i = 0; i < iconOffsets.length; i++)
                            buildAddButton(
                              iconOffsets[i],
                              iconData[i],
                              iconRotations[i],
                              addButtonTexts[i],
                              i,
                              iconColors[i]
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildAddButton(Offset offset, IconData icon, double rotationAngle, String text, int pageIndex, Color iconColors) {
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
                color: iconColors,
              ),
            ),
            InkWell(
              onTap: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => pageChange[pageIndex]),
                );
              },
              child: Text(text,
                style: TextStyle(
                  color: iconColors, // 여기에 원하는 색상을 지정하세요.
                ),
              )
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: BottomBar(),
    // ... (앱 설정 및 라우팅 설정 등)
  ));
}

class BottomBar extends StatefulWidget {
  const BottomBar({Key? key}) : super(key: key);

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  void _showCircularDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CircularDialog();
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    UserModel um = Provider.of<UserModel>(context, listen: false);

    if (um.isLogin) {
      sessionId = um.userId!;
    } else {
      sessionId = "";
    }
    return BottomAppBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _leftButton(),
          InkWell(
              onTap: (){
                _showCircularDialog(context);
              },
              child: Image.asset(
                'assets/logo.png',
                width: 70,
                height: 70,
                fit: BoxFit.contain,
              )
          ),
          _rightButton()
        ],
      ),
    );
  }
  Widget _leftButton(){
    return Expanded(
      child: IconButton(
        onPressed: () async {
          final userModel = Provider.of<UserModel>(context, listen: false);
          if (!userModel.isLogin) {
            // 사용자가 로그인하지 않은 경우에만 LoginPage로 이동
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => LoginPage()));
          } else {
            // 사용자가 로그인한 경우에만 MyPage로 이동
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => MyLikeList()));
          }
        },
        icon: Icon(Icons.favorite),
      ),
    );
  }
  Widget _rightButton(){
    return Expanded(
      child: IconButton(
          onPressed: () async {
            final userModel = Provider.of<UserModel>(context, listen: false);
            if (!userModel.isLogin) {
              // 사용자가 로그인하지 않은 경우에만 LoginPage로 이동
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => LoginPage()));
            } else {
              // 사용자가 로그인한 경우, userModel의 status 값에 따라 MyCustomer 또는 MyExpert로 이동
              final status = userModel.status;
              final userId = userModel.userId;
              if (status == 'C') {
                print("의뢰인");
                // 'C'인 경우 MyCustomer로 이동
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => MyCustomer(userId: userId!)));
              } else if (status == 'E') {
                print("전문가");
                // 'E'인 경우 MyExpert로 이동
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => MyExpert(userId: userId!)));
              } else {
                print("예외");
                Navigator.of(context).push(MaterialPageRoute(builder: (context) =>MyExpert(userId: userId!)));
              }
            }
          },
          icon: Icon(Icons.person)
      ),
    );
  }
}
