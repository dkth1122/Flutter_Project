import 'package:flutter/material.dart';

class Product extends StatefulWidget {
  Product({Key? key});

  @override
  _ProductState createState() => _ProductState();
}

class _ProductState extends State<Product> {
  List<String> path = ['dog1.PNG', 'dog2.PNG', 'dog3.PNG'];
  List<bool> isFavoriteList = [false, false, false];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Container(
        padding: EdgeInsets.all(10),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: path.length,
          itemBuilder: (context, index) {
            return Container(
              padding: EdgeInsets.all(10),
              child: Stack(
                children: [
                  Image.asset(path[index], fit: BoxFit.fill),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: IconButton(
                      icon: Icon(
                        isFavoriteList[index]
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: Colors.red,
                        size: 16,
                      ),
                      onPressed: () {
                        setState(() {
                          isFavoriteList[index] = !isFavoriteList[index];
                        });
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}



