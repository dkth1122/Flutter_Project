import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:project_flutter/chat/chatList.dart';
import 'package:project_flutter/myPage/my_page.dart';
import 'package:project_flutter/product.dart';
import 'package:provider/provider.dart';
import 'chat/chat.dart';
import 'firebase_options.dart';
import 'join/userModel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
      ChangeNotifierProvider(
        create: (context) => UserModel(),
        child: MyApp(),
      )
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Project',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _current = 0;
  int _current2 = 0;
  final CarouselController _controller = CarouselController();
  // 1초에 한번씩 로딩되는 문제를 해결하기 위해 밖으로 뺏음
  // 현재는 가격 낮은 순으로 정렬했지만 cnt가 추가되면 조회수 높은 순으로 할 예정
  final Stream<QuerySnapshot> productStream = FirebaseFirestore.instance.collection("product").orderBy("price").limit(3).snapshots();
  List imageList = [
    "https://cdn.pixabay.com/photo/2014/04/14/20/11/pink-324175_1280.jpg",
    "https://cdn.pixabay.com/photo/2014/02/27/16/10/flowers-276014_1280.jpg",
    "https://cdn.pixabay.com/photo/2012/03/01/00/55/flowers-19830_1280.jpg",
    "https://cdn.pixabay.com/photo/2015/06/19/20/13/sunset-815270_1280.jpg",
    "https://cdn.pixabay.com/photo/2016/01/08/05/24/sunflower-1127174_1280.jpg",
  ];
  List<String> imagePaths1 = ['dog1.PNG','dog2.PNG','dog3.PNG','dog4.PNG',];
  List<String> imagePaths2 = ['dog1.PNG','dog2.PNG','dog3.PNG','dog4.PNG',];
  List<String> imagePaths3 = ['dog1.PNG','dog2.PNG','dog3.PNG','dog4.PNG',];
  List<String> imagePaths4 = ['dog1.PNG','dog2.PNG','dog3.PNG','dog4.PNG',];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('용채'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(20),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "검색어를 입력하세요",
                  suffixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25)
                  ),
                  filled: true,
                  fillColor: Color.fromRGBO(211, 211, 211, 0.7019607843137254)

                ),
                onChanged: (text) {
                },
              ),
            ),
            SizedBox(
              height: 100,
              child: Stack(
                children: [
                  sliderWidget(),
                  sliderIndicator(),
                ],
              ),
            ),
            SizedBox(height: 20,),
            SizedBox(
              height: 300,
              child: Stack(
                children: [
                  sliderWidget2(),
                  sliderIndicator2(),
                ],
              ),
            ),
            SizedBox(height: 20,),
            // Row는 가장 많이 본 서비스
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
            Container(
              height: 100,
              child: PageView(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    height: 200, // 원하는 높이 설정
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal, // 수평 스크롤을 위해
                      child: Row(
                        children: [
                          Image.asset('dog1.png'),
                          Image.asset('dog1.png'),
                          Image.asset('dog1.png'),
                          Image.asset('dog1.png'),
                          Image.asset('dog1.png'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _cntProduct(),
            SizedBox(
              height: 300,
              child: Stack(
                children: [
                  sliderWidget3(),
                ],
              ),
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
                      context, MaterialPageRoute(builder: (context) => ChatApp(chatRoomId: 'chatRoomId',))
                  );
                },
                icon: Icon(Icons.chat)
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
                DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('userList').doc('id').get();
                Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyPage(),
                  ),
                );
              },
              icon: Icon(Icons.person),
            ),
          ],
        ),
      ),
    );
  }

  Widget sliderWidget() {
    return CarouselSlider(
      carouselController: _controller,
      items: imageList.map(
            (imgLink) {
          return Builder(
            builder: (context) {
              return SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Image(
                  fit: BoxFit.cover,
                  image: NetworkImage(
                    imgLink,
                  ),
                ),
              );
            },
          );
        },
      ).toList(),
      options: CarouselOptions(
        height: 100,
        viewportFraction: 1.0,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 1),
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
        children: imageList.asMap().entries.map((entry) {
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
            Container(
              height: 100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: imagePaths1.map((imagePath) {
                  return InkWell(
                    onTap: () {
                    },
                    child: ClipOval(
                      child: Image.asset(imagePath, width: 100, height: 100, fit: BoxFit.cover),
                    ),
                  );
                }).toList(),
              ),
            ),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text("프로그램"),
                  Text("프로그램"),
                  Text("프로그램"),
                  Text("프로그램"),
                ],
              ),
            ),
            SizedBox(height: 20,),
            Container(
              height: 100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: imagePaths2.map((imagePath) {
                  return InkWell(
                    onTap: () {
                    },
                    child: ClipOval(
                      child: Image.asset(imagePath, width: 100, height: 100, fit: BoxFit.cover),
                    ),
                  );
                }).toList(),
              ),
            ),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text("프로그램"),
                  Text("프로그램"),
                  Text("프로그램"),
                  Text("프로그램"),
                ],
              ),
            ),
          ],
        ),
        Column(
          children: [
            Container(
              height: 100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: imagePaths3.map((imagePath) {
                  return InkWell(
                    onTap: () {
                    },
                    child: ClipOval(
                      child: Image.asset(imagePath, width: 100, height: 100, fit: BoxFit.cover),
                    ),
                  );
                }).toList(),
              ),
            ),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text("프로그램"),
                  Text("프로그램"),
                  Text("프로그램"),
                  Text("프로그램"),
                ],
              ),
            ),
            SizedBox(height: 10,),
            Container(
              height: 100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: imagePaths4.map((imagePath) {
                  return InkWell(
                    onTap: () {
                    },
                    child: ClipOval(
                      child: Image.asset(imagePath, width: 100, height: 100, fit: BoxFit.cover),
                    ),
                  );
                }).toList(),
              ),
            ),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text("프로그램"),
                  Text("프로그램"),
                  Text("프로그램"),
                  Text("프로그램"),
                ],
              ),
            ),
          ],
        ),
      ],
      options: CarouselOptions(
        height: 300,
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

  Widget _cntProduct() {
    return StreamBuilder(
      stream: productStream, // 이제 스트림을 한 번만 설정
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snap) {
        if (!snap.hasData) {
          return Transform.scale(
            scale: 0.1,
            child: CircularProgressIndicator(strokeWidth: 20,),
          );
        }
        return ListView(
          shrinkWrap: true,
          children: snap.data!.docs.map((DocumentSnapshot document) {
            Map<String, dynamic> data = document.data() as Map<String, dynamic>;
            return ListTile(
              leading: Image.asset(
                'dog1.PNG',
                width: 200,
                height: 300,
                fit: BoxFit.cover,
              ),
              title: Text(data['pDetail']),
              subtitle: Text("가격 : ${data['price']}"),
            );
          }).toList(),
        );
      },
    );
  }

  Widget sliderWidget3() {
    return CarouselSlider(
      carouselController: _controller,
      items: [
        Column(
          children: [
            Container(
              height: 100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: imagePaths1.map((imagePath) {
                  // return Image.asset(imagePath);
                  return Image.asset(imagePath);
                }).toList(),
              ),
            ),
          ],
        ),
        Column(
          children: [
            Container(
              height: 100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: imagePaths3.map((imagePath) {
                  return Image.asset(imagePath);
                }).toList(),
              ),
            ),
          ],
        ),
      ],
      options: CarouselOptions(
        height: 300,
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
}