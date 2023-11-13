import 'package:flutter/material.dart';
import 'package:project_flutter/main.dart';
import 'package:project_flutter/test.dart';
import 'package:provider/provider.dart';

import 'expert/my_expert.dart';
import 'join/login_email.dart';
import 'join/userModel.dart';
import 'myPage/myCustomer.dart';
import 'myPage/myLike.dart';

class SubBottomBar extends StatefulWidget {
  const SubBottomBar({super.key});

  @override
  State<SubBottomBar> createState() => _SubBottomBarState();
}

class _SubBottomBarState extends State<SubBottomBar> {
  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _leftButton(),
          InkWell(
              onTap: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyHomePage()),
                );
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
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => MyLike()));
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
                // 'C'인 경우 MyCustomer로 이동
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => MyCustomer(userId: userId!)));
              } else if (status == 'E') {
                // 'E'인 경우 MyExpert로 이동
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => MyExpert(userId: userId!)));
              } else {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) =>MyExpert(userId: userId!)));
              }
            }
          },
          icon: Icon(Icons.person)
      ),
    );
  }
}
