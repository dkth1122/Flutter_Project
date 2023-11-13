import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../firebase_options.dart';
import '../product/productView.dart';
import '../search/searchPortfolioDetail.dart';
import '../subBottomBar.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(CategoryProduct(sendText: '',));
}

class CategoryProduct extends StatefulWidget {

  final String sendText;
  CategoryProduct({required this.sendText});

  @override
  State<CategoryProduct> createState() => _CategoryProductState();
}

class _CategoryProductState extends State<CategoryProduct> {
  final Stream<QuerySnapshot> portfolioStream = FirebaseFirestore.instance.collectionGroup("portfolio").snapshots();
  int _current = 0;
  final CarouselController _controller = CarouselController();

  List<String> imageBanner = ['assets/banner1.webp','assets/banner2.webp','assets/banner3.webp','assets/banner4.webp','assets/banner5.webp'];
  @override
  Widget build(BuildContext context) {
    String sendText = widget.sendText;
    return MaterialApp(
      theme: ThemeData(
        fontFamily: 'Pretendard',
      ),
      home: DefaultTabController(
        length: 2, // 탭의 수 (여기서는 2개)
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              '${sendText} 목록',
              style: TextStyle(color:Color(0xff424242), fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            elevation: 1.0,
            backgroundColor: Colors.white,
            iconTheme: IconThemeData(color: Color(0xff424242)),
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            bottom: TabBar(
              tabs: [
                Tab(
                  text: '서비스',
                ),
                Tab(
                  text: '포트폴리오',
                ),
              ],
              labelColor:Color(0xFFFF8C42), // 선택된 탭의 텍스트 컬러
              unselectedLabelColor: Color(0xff424242), // 선택되지 않은 탭의 텍스트 컬러
              indicator: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Color(0xFFFF8C42), // 밑줄의 색상을 변경하려면 여기에서 지정
                    width: 3.0, // 밑줄의 두께를 조절할 수 있습니다.
                  ),
                ),
              ),
              labelStyle: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          body: TabBarView(
            children: [
              SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.fromLTRB(10, 0,10, 0),
                  child: Column(
                    children: [
                      _categoryProductList(sendText)
                    ],
                  ),
                ),
              ),
              SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.fromLTRB(10, 0,10, 0),
                  child: Column(
                    children: [
                      _categoryPortfolioList(sendText)
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: SubBottomBar(),

        ),
      ),


    );
  }

  Widget _categoryProductList(String sendText) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("product")
          .where("category", isEqualTo: sendText)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snap) {
        if (!snap.hasData) {
          return CircularProgressIndicator();
        }

        final List<DocumentSnapshot> filteredDocs = snap.data!.docs;

        return ListView.builder(
          physics: NeverScrollableScrollPhysics(), // 스크롤 금지
          shrinkWrap: true,
          itemCount: filteredDocs.length,
          itemBuilder: (context, index) {
            Map<String, dynamic> data = filteredDocs[index].data() as Map<String, dynamic>;
            final document = filteredDocs[index];
            final productName = document['pName'] as String;
            final price = document['price'] as int;
            final imageUrl = document['iUrl'] as String;
            final formattedPrice = NumberFormat("#,###").format(price);

            return InkWell(
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
              child: Column(
                children: [
                  SizedBox(height: 10,),
                  Container(
                    height: 100,
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                        border: Border.all(
                            width: 0.6,
                            color: Color.fromRGBO(182, 182, 182, 0.6)
                        ),
                      color: Colors.white,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10.0), // 라운드 정도를 조절하세요
                              child: Image.network(
                                data['iUrl'],
                                width: 130,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(width: 10,),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data['pName'].length > 7
                                      ? '${data['pName'].substring(0, 7)}...'
                                      : data['pName'],
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                Container(
                                  width: 110,
                                  child: Text(
                                    data['pDetail'].length > 20
                                        ? '${data['pDetail'].substring(0, 20)}...'
                                        : data['pDetail'],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              '조회수: ${data['cnt'].toString()}',
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _categoryPortfolioList(String searchText) {
    return StreamBuilder<QuerySnapshot>(
      stream: portfolioStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Transform.scale(
            scale: 0.1,
            child: CircularProgressIndicator(strokeWidth: 20,),
          );
        }

        var portfolios = snapshot.data!.docs;

        // searchText가 포함된 아이템만 필터링
        var filteredPortfolios = portfolios.where((portfolio) {
          var data = portfolio.data() as Map<String, dynamic>;
          return data['category'].toLowerCase().contains(searchText.toLowerCase());
        }).toList();

        if (filteredPortfolios.isEmpty) {
          return Column(
            children: [
              SizedBox(height: 20,),
              Center(
                child: Text('포트폴리오 리스트 없음'),
              ),
            ],
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: filteredPortfolios.length,
          itemBuilder: (context, index) {
            var data = filteredPortfolios[index].data() as Map<String, dynamic>;
            return InkWell(
              onTap: () {
                var parentCollectionId = filteredPortfolios[index].reference.parent!.parent!.id;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchPortfolioDetail(
                      portfolioItem: filteredPortfolios[index].data() as Map<String, dynamic>,
                      user: parentCollectionId,
                    ),
                  ),
                );
              },
              child: Column(
                children: [
                  SizedBox(height: 10,),
                  Container(
                    height: 100,
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 0.6,
                        color: Color.fromRGBO(182, 182, 182, 0.6),
                      ),
                      color: Colors.white,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10.0),
                              child: Image.network(
                                data['thumbnailUrl'],
                                width: 130,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(width: 10,),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data['title'].length > 7
                                      ? '${data['title'].substring(0, 7)}...'
                                      : data['title'],
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                Container(
                                  width: 110,
                                  child: Text(
                                    data['description'].length > 20
                                        ? '${data['description'].substring(0, 20)}...'
                                        : data['description'],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              '조회수: ${data['cnt'].toString()}',
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 10,)
                ],
              ),
            );
          },
        );
      },
    );
  }
}