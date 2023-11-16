import 'package:carousel_slider/carousel_controller.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:project_flutter/bottomBar.dart';
import 'package:project_flutter/product/productAdd.dart';
import 'package:project_flutter/product/productView.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../firebase_options.dart';
import '../join/userModel.dart';
import '../subBottomBar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class Product extends StatefulWidget {
  @override
  State<Product> createState() => _ProductState();
}

class _ProductState extends State<Product> {
  int selectedCategoryIndex = -1;
  late Stream<QuerySnapshot>? productStream = null;
  Stream<QuerySnapshot> getStream() {
    if (productStream != null) {
      return productStream!;
    } else {
      return Stream<QuerySnapshot>.empty();
    }
  }

  String user = "";

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
  String selectedSort = '기본 순';
  double starAvg = 0.0;

  // 정렬 방식 목록
  List<String> sortOptions = [
    '기본 순',
    '조회수 높은 순',
    '최신 등록 순',
    '가격 높은 순',
    '가격 낮은 순',
  ];

  @override
  void initState() {
    super.initState();
    UserModel um = Provider.of<UserModel>(context, listen: false);
    Firebase.initializeApp().then((value) {
      setState(() {
        productStream = FirebaseFirestore.instance.collection("product").snapshots();
      });
    });

    if (um.isLogin) {
      // 사용자가 로그인한 경우
      user = um.userId!;
    } else {
      // 사용자가 로그인하지 않은 경우
      user = "없음";
      print("로그인 안됨");
    }
  }

  void checkUserStatusForProductRegistration() {

    // 사용자의 상태 확인
    var userQuery = FirebaseFirestore.instance
        .collection('userList')
        .where('userId', isEqualTo: user)
        .get();

// 쿼리의 결과를 비동기로 받아옴
    userQuery.then((QuerySnapshot querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        // 상태가 'E'이면 상품 등록 가능
        var userData = querySnapshot.docs.first.data() as Map<String, dynamic>?;
        if (userData != null && userData['status'] == 'E') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(),
            ),
          );
        } else {
          // 상태가 'E'가 아니면 스낵바로 메시지 표시
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('상품 등록은 전문가로 진행 가능합니다.'),
            ),
          );
        }
      } else {
        // 쿼리 결과가 비어있으면 스낵바로 메시지 표시
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('사용자를 찾을 수 없습니다.'),
          ),
        );
      }
    }).catchError((error) {
      // 에러가 발생하면 스낵바로 메시지 표시
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('에러: $error'),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("상품 페이지",
          style: TextStyle(
            color: Color(0xff424242),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Color(0xff424242),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            color: Color(0xff424242),
            onPressed: () {
              checkUserStatusForProductRegistration();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              child: GridView.count(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 4,
                mainAxisSpacing: 3, // 세로 방향 간격 설정
                crossAxisSpacing: 1, // 가로 방향 간격 설정
                childAspectRatio: 2 / 1, // 각 그리드 아이템의 가로 세로 비율 설정
                children: List.generate(categories.length, (index) {
                  return ElevatedButton(
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
                      primary: selectedCategoryIndex == index ? Colors.orange : Color(0xFFFCAF58),
                      minimumSize: Size(double.infinity, 90),
                    ),
                    child: Text(categories[index]),
                  );
                }),
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
              stream: getStream(),
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

                List<Map<String, dynamic>> sortedProductList = productList.map((doc) => doc.data() as Map<String, dynamic>).toList();

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

                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: sortedProductList.length,
                  itemBuilder: (context, index) {
                    final document = sortedProductList[index];
                    final productName = document['pName'] as String;
                    final price = document['price'] as int;
                    final imageUrl = document['iUrl'] as String;

                    final formattedPrice = NumberFormat("#,###").format(price);

                    return FutureBuilder<double>(
                      future: getAverageRating(productName),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          starAvg = snapshot.data ?? 0.0;
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
                              margin: EdgeInsets.only(bottom: 16), // 간격 조절 (원하는 만큼 설정)
                              height: 150,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 3,
                                    blurRadius: 5,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center, // 가로 중앙 정렬
                                children: [
                                  Expanded(
                                    flex: 6,
                                    child: Container(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.horizontal(
                                          left: Radius.circular(10),
                                        ),
                                        child: Image.network(
                                          imageUrl,
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: Container(
                                      padding: EdgeInsets.all(8),
                                      color: Colors.black.withOpacity(0.8),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center, // 세로 중앙 정렬
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
                                              '$productName (★${starAvg.toStringAsFixed(1)})',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
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
                                                color: Colors.amber,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
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

                        }
                      },
                    );
                  },
                );

              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: SubBottomBar(),
    );
  }

  Future<double> getAverageRating(String productName) async {
    double averageRating = 0.0;
    double reviewCount = 0.0;

    await FirebaseFirestore.instance
        .collection('review')
        .where('pName', isEqualTo: productName)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        final star = doc['star'].toDouble();
        averageRating += star;
        reviewCount++;
      });
    });

    if (reviewCount != 0) {
      averageRating /= reviewCount;
    } else {
      return 0.0;
    }

    starAvg = averageRating;
    return starAvg;
  }
  Future<double> getAverageRating2(String productName) async {
    double averageRating = 0.0;
    double reviewCount = 0.0;

    await FirebaseFirestore.instance
        .collection('review')
        .where('pName', isEqualTo: productName)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        final star = doc['star'].toDouble();
        averageRating += star;
        reviewCount++;
      });
    });

    if (reviewCount != 0) {
      averageRating /= reviewCount;
    } else {
      return 0.0;
    }

    starAvg = averageRating;
    return starAvg;
  }


}