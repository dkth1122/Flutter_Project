import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
class Test2 extends StatefulWidget {
  const Test2({Key? key}) : super(key: key);

  @override
  State<Test2> createState() => _Test2State();
}

class _Test2State extends State<Test2> {
  double rotation = 0.0;
  Offset initialPosition = Offset(0, 0);
  Offset currentPosition = Offset(0, 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Drag and Spin"),
      ),
      body: Center(
        child: GestureDetector(
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
              // You can add any additional logic here if needed.
            });
          },
          child: Container(
            child: Transform.rotate(
              angle: rotation,
              child: Container(
                width: 300,
                height: 300,
                color: Colors.lightBlue,
                alignment: Alignment.center,
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          child: GestureDetector(
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
                // You can add any additional logic here if needed.
              });
            },
            child: Container(
              child: Transform.rotate(
                angle: rotation,
                child: Container(
                  width: 300,
                  height: 300,
                  color: Colors.lightBlue,
                  alignment: Alignment.center,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}