import 'package:flutter/material.dart';

class Product extends StatelessWidget {
  Product({super.key});
  List<String> path = [ 'azi1.jpg', 'azi2.jpg', 'azi3.jpg'];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Container(
        padding: EdgeInsets.all(10),
        child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8
            ),
            itemCount: path.length,
            itemBuilder: (context, index){
              return Container(
                padding: EdgeInsets.all(10),
                child: Image.asset(path[index], fit : BoxFit.fill),

              );
            }),
      ),
    );
  }
}

