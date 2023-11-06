import 'package:flutter/material.dart';

class Test extends StatefulWidget {
  const Test({Key? key}) : super(key: key);

  @override
  State<Test> createState() => _TestState();
}

class _TestState extends State<Test> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("테스트")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            TextField(),
            SizedBox(height: 10,),
            TextFormField(
              maxLines: 20,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10,),
            ElevatedButton(
              onPressed: () {},
              child: Text('버튼'),
            )
          ],
        ),
      ),
    );
  }
}
