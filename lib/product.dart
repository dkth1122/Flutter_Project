import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:project_flutter/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(Product());
}

class Product extends StatefulWidget {
  @override
  _ProductState createState() => _ProductState();
}

class _ProductState extends State<Product> {
  List<String> path = ['dog1.PNG','dog2.PNG','dog3.PNG', 'dog4.png'];
  List<String> productNames = ['뽀짝이 \n25,000', '꼬순이 \n25,000', '시잡이 \n25,000', '쒸익이 \n25,000']; // 각 이미지에 대한 텍스트
  List<bool> isFavoriteList = [false, false, false, false];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("상품페이지"),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context); // 뒤로가기 버튼을 누를 때 이전 페이지로 돌아가도록 설정
            },
          ),
        ),
        body: Container(
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
                width: 100,
                height: 100,
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 1.0),
                ),
                child: Stack(
                  children: [
                    Image.asset(
                      path[index],
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Text(
                        productNames[index], // 각 이미지에 대한 텍스트 설정
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: IconButton(
                        icon: Icon(
                          isFavoriteList[index]
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: Colors.red,
                          size: 24,
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
      ),
    );
  }
}
