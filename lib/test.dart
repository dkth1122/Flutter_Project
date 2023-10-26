import 'package:flutter/material.dart';

class My extends StatefulWidget {
  const My({super.key});

  @override
  State<My> createState() => _MyState();
}

class _MyState extends State<My> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("gd"),),
      body: Column(
        children: [
          // 다른 위젯들 추가

          Expanded(
            child: PageView(
              // 페이지 목록
              children: [
                // 첫 번째 페이지
                SizedBox.expand(
                  child: Container(
                    color: Colors.red,
                    child: Center(
                      child: Text(
                        'Page index : 0',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                ),
                // 두 번째 페이지
                SizedBox.expand(
                  child: Container(
                    color: Colors.yellow,
                    child: Center(
                      child: Text(
                        'Page index : 1',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                ),
                // 세 번째 페이지
                SizedBox.expand(
                  child: Container(
                    color: Colors.green,
                    child: Center(
                      child: Text(
                        'Page index : 2',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                ),
                // 네 번째 페이지
                SizedBox.expand(
                  child: Container(
                    color: Colors.blue,
                    child: Center(
                      child: Text(
                        'Page index : 3',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                )
              ],
            )
          ),

          // 다른 위젯들 추가
        ],
      ),
    );
  }
}
