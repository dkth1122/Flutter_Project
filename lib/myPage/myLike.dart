
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../join/userModel.dart';
import '../product/productView.dart';
import 'myLikePortfolio.dart';

class MyLikeList extends StatefulWidget {
  const MyLikeList({super.key});

  @override
  State<MyLikeList> createState() => _MyLikeListListState();
}

class _MyLikeListListState extends State<MyLikeList> {

  late UserModel userModel;
  List<Map<String, dynamic>> likeData = [];
  List<int> productPrices = [];
  List<String> productUrls = []; // 이미지 URL을 저장하는 목록
  String selectedFilter = "전체";
  List<String> optionsButton1 = [
    '전체',
    'UX기획',
    '웹',
    '커머스',
    '모바일',
    '프로그램',
    '트렌드',
    '데이터',
    '기타',];


  @override
  void initState() {
    super.initState();
    userModel = Provider.of<UserModel>(context, listen: false);
    LikeData();
  }
  void _showFilterOptions(BuildContext context, List<String> options) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return ListView(
          children: options.map((option) {
            return ListTile(
              title: Text(option),
              onTap: () {
                setState(() {
                  selectedFilter = option;
                });
                Navigator.pop(context);
                LikeData();
              },
            );
          }).toList(),
        );
      },
    );
  }

  Future<void> LikeData() async {
    Query query = FirebaseFirestore.instance.collection("like").where("user", isEqualTo: userModel.userId);

    if (selectedFilter != "전체") {
      // 선택한 필터에 따라 필터링
      query = query.where("category", isEqualTo: selectedFilter);
    }
    QuerySnapshot querySnapshot = await query.get();

    if (querySnapshot.docs.isNotEmpty) {
      List<Map<String, dynamic>> data = querySnapshot.docs.map((doc) {
        return doc.data() as Map<String, dynamic>;
      }).toList();

      List<int> prices = [];
      List<String> urls = [];

      for (Map<String, dynamic> data in data) {
        Map<String, dynamic> productInfo = await getProductInfo(data['pName']);
        int price = productInfo['price'] as int;
        String iUrl = productInfo['iUrl'] as String;
        prices.add(price);
        urls.add(iUrl);
      }

      setState(() {
        likeData = data;
        productPrices = prices;
        productUrls = urls;
      });
    }
  }

  Future<Map<String, dynamic>> getProductInfo(String pName) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("product")
        .where("pName", isEqualTo: pName)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      Map<String, dynamic> productData =
      querySnapshot.docs[0].data() as Map<String, dynamic>;
      int price = productData['price'] as int;
      String iUrl = productData['iUrl'] as String;
      return {'price': price, 'iUrl': iUrl};
    }

    return {'price': 0, 'iUrl': ''};
  }


  Color appBarColor = Color(0xFF4E598C);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: 'Pretendard',
      ),
      home: DefaultTabController(
        length: 2, // 탭의 수 (여기서는 2개)
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              '찜 목록',
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
            actions: [
              TextButton(
                child: Text(
                  "필터",
                  style: TextStyle(fontSize: 17, color:Color(0xff424242),fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  _showFilterOptions(context, optionsButton1);
                },
              ),
            ],
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
              ServiceListView(productPrices, productUrls, likeData),
              PortfolioView()
            ],
          ),
        ),
      ),


    );
  }
}

class ServiceListView extends StatelessWidget {
  final List<int> productPrices;
  final List<String> productUrls;
  final List<Map<String, dynamic>> likeData;

  ServiceListView(this.productPrices, this.productUrls, this.likeData);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: productPrices.length,
      itemBuilder: (context, index) {
        int price = productPrices[index];
        String iUrl = productUrls[index];
        String pName = likeData[index]['pName'];
        return ListTile(
          leading:Image.network(
              iUrl, width: 100,),
          title: Text(pName),
          subtitle:Text(' $price 원'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductView(
                  productName: pName,
                  price: price.toString(),
                  imageUrl: iUrl,
                ),
              ),
            );
          }
        );
      },
    );
  }
}

class PortfolioView  extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(10),
        child: myLikePortfolio()
      ),
    );
  }
}

class PortfolioList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("포트폴리오 목록이 비어 있습니다."),
    );
  }
}

class ServiceList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("서비스 목록이 비어 있습니다."),
    );
  }
}

