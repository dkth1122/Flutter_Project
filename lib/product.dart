import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:project_flutter/productAdd.dart';
import 'package:project_flutter/productView.dart';
import 'package:project_flutter/join/userModel.dart';
import 'package:project_flutter/test2.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'chat/chatList.dart';
import 'join/login_email.dart';
import 'myPage/my_page.dart';

class Product extends StatefulWidget {
  @override
  State<Product> createState() => _ProductState();
}

class _ProductState extends State<Product> {
  late Stream<QuerySnapshot>? productStream = null;
  List<String> categories = [
    'UX기획',
    '웹',
    '커머스',
    '모바일',
    '프로그램',
    '트렌드',
    '데이터',
    '기타',
  ];
  String selectedCategory = '전체';
  String selectedSort = '조회수 높은 순'; // 선택된 정렬 방식

  // 정렬 방식 목록
  List<String> sortOptions = [
    '조회수 높은 순',
    '최신 등록 순',
    '평점 높은 순',
    '후기 많은 순',
    '가격 높은 순',
    '가격 낮은 순',
  ];

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp().then((value) {
      setState(() {
        productStream = FirebaseFirestore.instance.collection("product").snapshots();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("상품페이지"),
        backgroundColor: Color(0xff328772),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HomeScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: categories.map((String category) {
                return Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedCategory = category;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      primary: selectedCategory == category ? Color(0xfff48752) : Color(0xff328772),
                      minimumSize: Size(double.infinity, 50),
                    ),
                    child: Text(category),
                  ),
                );
              }).toList(),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.filter_alt_sharp), // 아이콘 추가
                DropdownButton<String>(
                  value: selectedSort,
                  items: sortOptions.map((String option) {
                    return DropdownMenuItem<String>(
                      value: option,
                      child: Text(option),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    setState(() {
                      selectedSort = value!;
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(10),
              child: StreamBuilder<QuerySnapshot>(
                stream: productStream!,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text('상품이 없습니다.'),
                    );
                  }

                  final productList = snapshot.data!.docs;

                  return GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: productList.length,
                    itemBuilder: (context, index) {
                      final document = productList[index];
                      final productName = document['pName'] as String;
                      final price = document['price'] as int;
                      final imageUrl = document['iUrl'] as String;

                      final formattedPrice = NumberFormat("#,###").format(price);

                      if (selectedCategory != '전체' && document['category'] != selectedCategory) {
                        return Container();
                      }

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductView(
                                productName: productName,
                                price: price.toString(),
                                imageUrl: imageUrl,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          width: 100,
                          height: 100,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 1.0),
                          ),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                bottom: 8,
                                left: 8,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ProductView(
                                              productName: productName,
                                              price: formattedPrice,
                                              imageUrl: imageUrl,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        productName,
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ProductView(
                                              productName: productName,
                                              price: formattedPrice,
                                              imageUrl: imageUrl,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        '가격: $formattedPrice 원',
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        height: 60,
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
            ),
            IconButton(
                onPressed: (){
                  Navigator.push(
                      context, MaterialPageRoute(builder: (context) => ChatList())
                  );
                },
                icon: Icon(Icons.chat_outlined)
            ),
            IconButton(
              onPressed: () async {
                final userModel = Provider.of<UserModel>(context, listen: false);
                if (userModel.isLogin) {
                  // 사용자가 로그인한 경우에만 MyPage로 이동
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => MyPage()));
                } else {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => LoginPage()));
                }
              },
              icon: Icon(Icons.person),
            ),
            IconButton(
                onPressed: (){
                  Navigator.push(
                      context, MaterialPageRoute(builder: (context) => Test2())
                  );
                },
                icon: Icon(Icons.telegram_sharp)
            ),
          ],
        ),
      ),
    );
  }
}
