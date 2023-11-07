import 'package:carousel_slider/carousel_controller.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:project_flutter/bottomBar.dart';
import 'package:project_flutter/product/productAdd.dart';
import 'package:project_flutter/product/productView.dart';
import 'package:intl/intl.dart';

class Product extends StatefulWidget {
  @override
  State<Product> createState() => _ProductState();
}

class _ProductState extends State<Product> {
  int selectedCategoryIndex = -1;
  late Stream<QuerySnapshot>? productStream = null;
  final CarouselController _controller = CarouselController();
  List<String> imageBanner = ['assets/banner1.webp','assets/banner2.webp','assets/banner3.webp','assets/banner4.webp','assets/banner5.webp'];
  int _current = 0;
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
/*            SizedBox(
              height: 150,
              child: Stack(
                children: [
                  sliderWidget(),
                  sliderIndicator(),
                ],
              ),
            ),*/ //광고 넘어갈 때 마다 오류로 잠시 막아둠
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
                }else if (selectedSort == '평점 높은 순') {
                  sortedProductList.sort((a, b) {
                    final aStarAvg = a['starAvg'] as double? ?? 0.0;
                    final bStarAvg = b['starAvg'] as double? ?? 0.0;
                    return bStarAvg.compareTo(aStarAvg);
                  });
                } else if (selectedSort == '후기 많은 순') {
                  sortedProductList.sort((a, b) {
                    final aReviewCount = a['reviewCount'] as int? ?? 0;
                    final bReviewCount = b['reviewCount'] as int? ?? 0;
                    return bReviewCount.compareTo(aReviewCount);
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

                    return FutureBuilder<double>(
                      future: getAverageRating(productName),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return CircularProgressIndicator(); // 평균을 계산하는 중이면 로딩 표시
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}'); // 오류가 있을 경우 오류 표시
                        } else {
                          starAvg = snapshot.data ?? 0.0; // 계산된 평균 평점
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
                                padding: EdgeInsets.all(8),
                                color: Colors.black.withOpacity(0.2),
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
                                        '$productName (★$starAvg)',
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
      bottomNavigationBar: BottomBar(),
    );
  }

  Widget sliderWidget() {
    return CarouselSlider(
      carouselController: _controller,
      items: imageBanner.map(
            (imagePath) {
          return Builder(
            builder: (context) {
              return SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                ),
              );
            },
          );
        },
      ).toList(),
      options: CarouselOptions(
        height: 150,
        viewportFraction: 1.0,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 2),
        onPageChanged: (index, reason) {
          setState(() {
            _current = index;
          });
        },
      ),
    );
  }

  Widget sliderIndicator() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: imageBanner.asMap().entries.map((entry) {
          return GestureDetector(
            onTap: () => _controller.animateToPage(entry.key),
            child: Container(
              width: 12,
              height: 12,
              margin:
              const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                Colors.white.withOpacity(_current == entry.key ? 0.9 : 0.4),
              ),
            ),
          );
        }).toList(),
      ),
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
    }

    starAvg = averageRating;
    return starAvg;
  }

  Future<int> getReviewCount(String productName) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('review')
        .where('pName', isEqualTo: productName)
        .get();

    return querySnapshot.docs.length;
  }


}
