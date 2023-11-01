import 'package:flutter/material.dart';

import '../main.dart';
import 'adminAd.dart';
import 'adminBoard.dart';
import 'adminInquiry.dart';
import 'adminUser.dart';

class AdminDomainPage extends StatefulWidget {
  @override
  State<AdminDomainPage> createState() => _AdminDomainPageState();
}

class _AdminDomainPageState extends State<AdminDomainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('관리자 페이지'),
        backgroundColor: Color(0xff328772),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HomePage(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AdminAd()),
                  );
                },
                child: Text('광고 관리'),
                style: ElevatedButton.styleFrom(
                  primary: Color(0xff328772),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AdminBoard()),
                  );
                },
                child: Text('게시판 관리'),
                style: ElevatedButton.styleFrom(
                  primary: Color(0xff328772),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AdminUser()),
                  );
                },
                child: Text('회원 관리'),
                style: ElevatedButton.styleFrom(
                  primary: Color(0xff328772),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AdminInquiry()),
                  );
                },
                child: Text('문의 관리'),
                style: ElevatedButton.styleFrom(
                  primary: Color(0xff328772),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
