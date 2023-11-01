import 'package:flutter/material.dart';

class Test extends StatefulWidget {
  const Test({Key? key});

  @override
  State<Test> createState() => _TestState();
}

class _TestState extends State<Test> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              floating: false, // Appbar가 스크롤될 때 고정되지 않도록 설정
              pinned: false, // Appbar가 화면 상단에 고정되도록 설정
              flexibleSpace: FlexibleSpaceBar(
                title: Text('이미지 테스트'),
              ),
            ),
          ];
        },
        body: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Image.asset('assets/cat1.jpeg'),
                    Image.asset('assets/cat1.jpeg'),
                    Image.asset('assets/cat1.jpeg'),
                    Image.asset('assets/cat1.jpeg'),
                    Image.asset('assets/cat1.jpeg'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}