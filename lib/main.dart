import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:project_flutter/chat/chatList.dart';
import 'package:project_flutter/myPage/my_page.dart';
import 'package:project_flutter/product/product.dart';
import 'package:project_flutter/product/productView.dart';
import 'package:project_flutter/search/search.dart';
import 'package:project_flutter/bottomBar.dart';
import 'package:project_flutter/test.dart';
import 'package:project_flutter/test2.dart';
import 'package:provider/provider.dart';
import 'admin/adminDomain.dart';
import 'category/categoryProduct.dart';
import 'chat/ChatProvider.dart';
import 'chat/chat.dart';
import 'expert/my_expert.dart';
import 'firebase_options.dart';
import 'join/login_email.dart';
import 'join/userModel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserModel()),
        ChangeNotifierProvider(create: (context) => ChatProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Color(0xFF4E598C),
        hintColor: Color(0xFFFCAF58),
        fontFamily: 'Pretendard',
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.black, fontSize: 16),
        ),
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: TextStyle(
            color: Colors.black, // 레이블 텍스트의 색상
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF4E598C), width: 2.0),
            borderRadius: BorderRadius.circular(10.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF4E598C), width: 2.0),
            borderRadius: BorderRadius.circular(10.0),
          ),
          // 여기에 필요한 다른 스타일을 추가할 수 있습니다.
        ),
      ),

      title: 'Flutter Project',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _current = 0;
  int _current2 = 0;
  final CarouselController _controller = CarouselController();
  // 1초에 한번씩 로딩되는 문제를 해결하기 위해 밖으로 뺏음
  // 현재는 가격 낮은 순으로 정렬했지만 cnt가 추가되면 조회수 높은 순으로 할 예정
  final Stream<QuerySnapshot> productStream = FirebaseFirestore.instance.collection("product").orderBy("cnt", descending: true).limit(4).snapshots();
  final Stream<QuerySnapshot> productStream2 = FirebaseFirestore.instance.collection("product")
      .where("likeCnt", isGreaterThanOrEqualTo: 1)
      .snapshots();
  FocusNode myFocusNode = FocusNode();

  List<String> imageBanner = ['assets/banner1.webp','assets/banner2.webp','assets/banner3.webp','assets/banner4.webp','assets/banner5.webp'];
  List<String> imagePaths1 = ['assets/category_ux.png','assets/category_web.png','assets/category_shop.png','assets/category_mobile.png',];
  List<String> imagePaths2 = ['assets/category_program.png','assets/category_trend.png','assets/category_data.png','assets/category_rest.png',];
  List<String> categories = ["UX기획", "웹", "커머스", "모바일"];
  List<String> categories2 = ["프로그램", "트렌드", "데이터", "기타"];

  String sessionId = "";
  @override
  Widget build(BuildContext context) {

    UserModel um = Provider.of<UserModel>(context, listen: false);

    if (um.isLogin) {
      sessionId = um.userId!;
    } else {
      sessionId = "";
    }

    final userModel = Provider.of<UserModel>(context, listen: false);
    bool isAdmin = userModel.userId == 'admin';

    return Scaffold(
      //appbar를 안하고 body를 한 이유는 스크롤 하면서 appbar를 사라지게 하기 위함
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              floating: false, // Appbar가 스크롤될 때 고정되지 않도록 설정
              pinned: false, // Appbar가 화면 상단에 고정되도록 설정
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: EdgeInsets.all(20),
                title: Text('Fixer 4 U'),
              ),
              actions: [
                if (isAdmin)
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AdminDomainPage()),
                      );
                    },
                    icon: Icon(Icons.admin_panel_settings),
                  ),
              ],
              backgroundColor: Color(0xFFFCAF58),
            ),
          ];
        },
        body: Column(
          children: [
            // 검색어
            Container(
                padding: EdgeInsets.fromLTRB(20, 25, 20, 25),
                child: TextField(
                  readOnly: true, // 이 속성을 true로 설정하여 키보드가 나타나지 않도록 함
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(10, 5, 5, 5),

                    hintText: "검색어를 입력하세요",
                    suffixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    filled: true,
                    fillColor: Color.fromRGBO(227, 227, 227, 0.7019607843137254),
                  ),
                  onTap: () {
                    Navigator.push(
                        context, MaterialPageRoute(builder: (context) => Search())
                    );
                  },
                )
            ),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // 슬라이드
                    SizedBox(
                      height: 150,
                      child: Stack(
                        children: [
                          sliderWidget(),
                          sliderIndicator(),
                        ],
                      ),
                    ),
                    SizedBox(height: 20,),
                    // 카테고리
                    SizedBox(
                      height: 130,
                      child: Stack(
                        children: [
                          sliderWidget2(),
                          sliderIndicator2(),
                        ],
                      ),
                    ),
                    SizedBox(height: 10,),
                    // 인기 서비스 제목
                    Row(
                      children: [
                        SizedBox(width: 20,),
                        Text(
                          "인기 서비스",
                          style: TextStyle(
                              fontSize: 24,
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      ],
                    ),
                    // 인기 서비스
                    Container(
                        height: 270,
                        child: _heartProduct()
                    ),
                    SizedBox(height: 20,),
                    // 가장 많이 본 서비스 제목
                    Row(
                      children: [
                        SizedBox(width: 20,),
                        Text(
                          "가장 많이 본 서비스",
                          style: TextStyle(
                              fontSize: 24,
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      ],
                    ),
                    // 가장 많이 본 서비스
                    Container(
                      padding: EdgeInsets.all(10),
                      child: _cntProduct()
                    ),
                    SizedBox(height: 20,),

                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // extendBody: true, // body를 침범하도록 함
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

  Widget sliderWidget2() {
    return CarouselSlider(
      carouselController: _controller,
      items: [
        Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                for (int i = 0; i < 4; i++)
                  Expanded(
                    child: Column(
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.push(
                                context, MaterialPageRoute(builder: (context) => CategoryProduct(sendText : categories[i]))
                            );

                          },
                          child: Image.asset(
                            imagePaths1[i],
                            width: 90,
                            height: 90,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Text(categories[i])
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
        Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                for (int i = 0; i < 4; i++)
                  Expanded(
                    child: Column(
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.push(
                                context, MaterialPageRoute(builder: (context) => CategoryProduct(sendText : categories2[i]))
                            );
                          },
                          child: Image.asset(
                            imagePaths2[i],
                            width: 90,
                            height: 90,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Text(categories2[i])
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ],
      options: CarouselOptions(
        height: 200,
        viewportFraction: 1,
        autoPlay: false,
        enableInfiniteScroll: false,
        onPageChanged: (index, reason) {
          setState(() {
            _current2 = index;
          });
        },
      ),
    );
  }

  Widget sliderIndicator2() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(2, (index) {
          return GestureDetector(
            onTap: () => _controller.animateToPage(index),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 8,
                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    color: Colors.black.withOpacity(_current2 == index ? 0.9 : 0.2),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _heartProduct() {
    return StreamBuilder(
      stream: productStream2,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snap) {
        if (!snap.hasData) {
          return Transform.scale(
            scale: 0.1,
            child: CircularProgressIndicator(strokeWidth: 20),
          );
        }

        int initialPage = snap.data!.docs.length ~/ 2;


        return PageView(
          scrollDirection: Axis.horizontal,
          pageSnapping: false,
          controller: PageController(initialPage: initialPage, viewportFraction: 0.6),
          children: snap.data!.docs.map((DocumentSnapshot document) {
            Map<String, dynamic> data = document.data() as Map<String, dynamic>;
            return InkWell(
              onTap: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductView(
                      productName: data['pName'],
                      price: data['price'].toString(),
                      imageUrl: data['iUrl'],
                    ),
                  ),
                );
              },
              child: Container(
                  child: Card(
                    child: Column(
                      children: [
                        SizedBox(height: 10),
                        Stack(
                          alignment: Alignment.topRight,
                          children: [
                            Image.network(
                              data['iUrl'],
                              width: 300,
                              height: 150,
                              fit: BoxFit.cover,
                            ),
                            IconButton(
                              onPressed: () async {
                                if (sessionId.isNotEmpty) {
                                  final QuerySnapshot result = await FirebaseFirestore.instance
                                      .collection('like')
                                      .where('user', isEqualTo: sessionId)
                                      .where('pName', isEqualTo: data['pName'])
                                      .get();

                                  if (result.docs.isNotEmpty) {
                                    // 찾은 데이터가 있는 경우 삭제
                                    final documentId = result.docs.first.id;
                                    FirebaseFirestore.instance.collection('like').doc(documentId).delete();

                                    // "product" 컬렉션의 "likeCnt" 업데이트
                                    final productQuery = await FirebaseFirestore.instance
                                        .collection('product')
                                        .where('pName', isEqualTo: data['pName'])
                                        .get();

                                    if (productQuery.docs.isNotEmpty) {
                                      final productDocId = productQuery.docs.first.id;
                                      final currentLikeCount = productQuery.docs.first['likeCnt'] ?? 0;

                                      // "likeCnt" 업데이트
                                      FirebaseFirestore.instance.collection('product').doc(productDocId).update({
                                        'likeCnt': currentLikeCount - 1, // 좋아요를 취소했으므로 감소
                                      });
                                    }
                                  } else {
                                    // 찾은 데이터가 없는 경우, 좋아요 버튼을 누를 때 Firestore에 데이터 추가
                                    FirebaseFirestore.instance.collection('like').add({
                                      'user': sessionId,
                                      'pName': data['pName'],
                                    });

                                    // "product" 컬렉션의 "likeCnt" 업데이트
                                    final productQuery = await FirebaseFirestore.instance
                                        .collection('product')
                                        .where('pName', isEqualTo: data['pName'])
                                        .get();

                                    if (productQuery.docs.isNotEmpty) {
                                      final productDocId = productQuery.docs.first.id;
                                      final currentLikeCount = productQuery.docs.first['likeCnt'] ?? 0;

                                      // "likeCnt" 업데이트
                                      FirebaseFirestore.instance.collection('product').doc(productDocId).update({
                                        'likeCnt': currentLikeCount + 1, // 좋아요를 추가했으므로 증가
                                      });
                                    }
                                  }
                                }
                              },
                              icon: sessionId.isNotEmpty
                                  ? StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('like')
                                    .where('user', isEqualTo: sessionId)
                                    .where('pName', isEqualTo: data['pName'])
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    if (snapshot.data!.docs.isNotEmpty) {
                                      return Icon(
                                        Icons.favorite,
                                        color: Colors.red,
                                        size: 30,
                                      );
                                    }
                                  }
                                  return Icon(
                                    Icons.favorite_border,
                                    color: Colors.red,
                                    size: 30,
                                  );
                                },
                              )
                                  : Container(), // 하트 아이콘
                            ),
                          ],
                        ),
                        ListTile(
                          title: Text(
                            data['pDetail'].length > 15
                                ? '${data['pDetail'].substring(0, 15)}...'
                                : data['pDetail'],
                          ),
                          subtitle: Text("가격 : ${data['price']}"),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text("좋아요 : ${data['likeCnt']}개"),
                            SizedBox(width: 10,)
                          ],
                        )
                      ],
                    ),
                  )
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _cntProduct() {
    return StreamBuilder(
      stream: productStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snap) {
        if (!snap.hasData) {
          return Transform.scale(
            scale: 0.1,
            child: CircularProgressIndicator(strokeWidth: 20,),
          );
        }
        return Column(
          children: snap.data!.docs.map((DocumentSnapshot document) {
            Map<String, dynamic> data = document.data() as Map<String, dynamic>;
            return InkWell(
              onTap: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductView(
                      productName: data['pName'],
                      price: data['price'].toString(),
                      imageUrl: data['iUrl'],
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
                      )
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
                                  data['pName'],
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                Container(
                                  width: 150,
                                  child: Text(
                                    data['pDetail'].length > 30
                                        ? '${data['pDetail'].substring(0, 30)}...'
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
          }).toList(),
        );
      },
    );
  }

}