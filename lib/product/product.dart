import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:project_flutter/product/productAdd.dart';
import 'package:project_flutter/product/productView.dart';
import 'package:project_flutter/join/userModel.dart';
import 'package:project_flutter/test2.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../chat/chatList.dart';
import '../join/login_email.dart';
import '../myPage/my_page.dart';

class Product extends StatefulWidget {
  @override
  State<Product> createState() => _ProductState();
}

class _ProductState extends State<Product> {
  int selectedCategoryIndex = -1;
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

    List<Map<String, dynamic>> sortedProductList = [];

    return Scaffold(
      appBar: AppBar(
        title: const Text("상품페이지"),
        backgroundColor: Color(0xFF4E598C),
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              child: Container(
                child: Row(
                  children: List.generate(categories.length, (index) {
                    return Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            if (selectedCategoryIndex == index) {
                              selectedCategory = '전체'; // 카테고리 선택 해제
                              selectedCategoryIndex = -1; // 선택된 카테고리 인덱스 초기화
                            } else {
                              selectedCategory = categories[index]; // 선택한 카테고리로 업데이트
                              selectedCategoryIndex = index; // 선택한 카테고리 인덱스로 업데이트
                            }
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          primary: selectedCategoryIndex == index ? Color(0xFFFCAF58) : Color(0xFF4E598C),
                          minimumSize: Size(double.infinity, 90),
                        ),
                        child: Text(categories[index]),
                      ),
                    );
                  }),
                ),
              ),
            ),
            Container(
              height: 100, // 광고 영역의 높이를 150으로 고정
              color: Colors.black, // 광고 영역의 배경색 설정
              alignment: Alignment.center, // 광고 내용을 가운데로 정렬
              child: Text(
                '여기에 광고를 한다면 매출이 얼마나 오를까\n02-000-0000',
                style: TextStyle(fontSize: 18, color: Colors.white),
                textAlign: TextAlign.center,
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
            StreamBuilder<QuerySnapshot>(
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

                List<QueryDocumentSnapshot> sortedProductList = List.from(productList);

                sortedProductList = sortedProductList.where((document) {
                  final category = document['category'] as String;
                  return selectedCategory == '전체' || category == selectedCategory;
                }).toList();

                if (selectedSort == '조회수 높은 순') {
                  sortedProductList.sort((a, b) {
                    final aCnt = a['cnt'] as int;
                    final bCnt = b['cnt'] as int;
                    return bCnt.compareTo(aCnt);
                  });
                } else if (selectedSort == '최신 등록 순') {
                  sortedProductList.sort((a, b) {
                    final aTime = a['sendTime'] as Timestamp;
                    final bTime = b['sendTime'] as Timestamp;
                    return bTime.compareTo(aTime);
                  });
                }else if (selectedSort == '가격 높은 순') {
                  sortedProductList.sort((a, b) {
                    final aPrice = a['price'] as int;
                    final bPrice = b['price'] as int;
                    return bPrice.compareTo(aPrice);
                  });
                }else if (selectedSort == '가격 낮은 순') {
                  sortedProductList.sort((a, b) {
                    final aPrice = a['price'] as int;
                    final bPrice = b['price'] as int;
                    return aPrice.compareTo(bPrice);
                  });
                }

                return GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: sortedProductList.length, // 수정된 부분: 선택된 카테고리에 속하는 상품의 개수로 설정
                  itemBuilder: (context, index) {
                    final document = sortedProductList[index];
                    final productName = document['pName'] as String;
                    final price = document['price'] as int;
                    final imageUrl = document['iUrl'] as String;

                    final formattedPrice = NumberFormat("#,###").format(price);

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
                        width: 150,
                        height: 100,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey, width: 1.0),
                        ),
                        child: Stack(
                          children: [
                            Image.network(
                              imageUrl,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                padding: EdgeInsets.all(8), // 내용과 상하 좌우 간격 조절
                                color: Colors.black.withOpacity(0.2), // 검정색 배경 색상 및 불투명도 설정
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
                                          color: Colors.white,
                                          fontSize: 12,
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
                                        '$formattedPrice 원',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
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
          ],
        ),
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
