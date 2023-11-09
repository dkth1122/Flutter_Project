import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../firebase_options.dart';
import '../main.dart';
import 'adminAd.dart';
import 'adminBoard.dart';
import 'adminUser.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Project',
      home: AdminDomainPage(),
    );
  }
}

class AdminDomainPage extends StatefulWidget {
  @override
  State<AdminDomainPage> createState() => _AdminDomainPageState();
}

class _AdminDomainPageState extends State<AdminDomainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('관리자 페이지',
            style: TextStyle(
            color: Color(0xff424242),
        fontWeight: FontWeight.bold,
      ),

    ),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.home),
          color: Color(0xff424242),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MyHomePage(),
              ),
            );
          },
        ),

      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 20.0),
            child: Text(
              '오늘도 파이팅!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                  primary: Color(0xFFFF8C42),
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
                  primary: Color(0xFFFF8C42),
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
                  primary: Color(0xFFFF8C42),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

