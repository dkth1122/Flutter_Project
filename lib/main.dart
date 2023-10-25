import 'dart:async';
import 'package:flutter/material.dart';
import 'package:project_flutter/product.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('무한 반복 애니메이션'),
      ),
      body: Container(
        child: Column(
          children: [
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
                onPressed: (){
                  Navigator.push(
                      context, MaterialPageRoute(builder: (context) => Product())
                  );
                },
                icon: Icon(Icons.add_circle_outline)
            )
          ],
        ),
      ),
    );
  }
}