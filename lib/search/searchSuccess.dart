import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_flutter/search/searchPortfolioDetail.dart';
import '../expert/portfolioDetail.dart';
import '../firebase_options.dart';
import '../product/productView.dart';
import '../subBottomBar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(SearchSuccess(searchText: '',));
}

class SearchSuccess extends StatefulWidget {
  final String searchText;

  SearchSuccess({required this.searchText});

  @override
  State<SearchSuccess> createState() => _SearchSuccessState();
}

class _SearchSuccessState extends State<SearchSuccess> {
  @override
  Widget build(BuildContext context) {
    String searchText = widget.searchText;
    return Scaffold(
      appBar: AppBar(title: Text("검색성공"),backgroundColor: Color(0xFFFCAF58),),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20,),
            Text("검색어: $searchText", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
            SizedBox(height: 20,),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width: 10,),
                Text("상품 리스트", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
              ],
            ),
            Container(
              padding: EdgeInsets.all(10),
              child: searchListProduct()
            ),
            SizedBox(height: 20,),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width: 10,),
                Text("포트폴리오 리스트", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
              ],
            ),
            SizedBox(height: 20,),
            Container(
              padding: EdgeInsets.all(10),
              child: searchListPortFolio(searchText)
            ),
          ],
        ),
      ),
      bottomNavigationBar: SubBottomBar(),
    );
  }

  Widget searchListProduct() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("product")
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snap) {
        if (!snap.hasData) {
          return CircularProgressIndicator();
        }

        final List<DocumentSnapshot> filteredDocs = snap.data!.docs
            .where((document) {
          Map<String, dynamic> data = document.data() as Map<String, dynamic>;
          String pDetail = data['pDetail'];
          String pName = data['pName'];
          return pDetail.contains(widget.searchText) || pName.contains(widget.searchText);
        }).toList();

        if (filteredDocs.isEmpty) {
          // 상품 리스트가 없을 때 '상품 리스트 없음'을 출력합니다.
          return Text('상품 리스트 없음');
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
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
                              '가격: ${data['price'].toString()}',
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

  Widget searchListPortFolio(String searchText) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection("expert").snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> expertSnap) {
        if (!expertSnap.hasData) {
          return CircularProgressIndicator();
        }

        final List<DocumentSnapshot> expertDocs = expertSnap.data!.docs;

        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: expertDocs.length,
          itemBuilder: (context, index) {
            Map<String, dynamic> expertData = expertDocs[index].data() as Map<String, dynamic>;
            String userId = expertData['userId'];

            return StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("expert")
                  .doc(userId)
                  .collection("portfolio")
                  .snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> portfolioSnap) {
                if (!portfolioSnap.hasData) {
                  return CircularProgressIndicator();
                }

                final List<DocumentSnapshot> portfolioDocs = portfolioSnap.data!.docs;

                // 검색어로 필터링된 포트폴리오만 추출
                final filteredPortfolios = portfolioDocs.where((portfolioDoc) {
                  Map<String, dynamic> portfolioData = portfolioDoc.data() as Map<String, dynamic>;
                  String title = portfolioData['title'];
                  String description = portfolioData['description'];
                  return title.contains(searchText) || description.contains(searchText);
                }).toList();

                if (index == 1 && filteredPortfolios.isEmpty) {
                  return Center(
                    child: Text('검색어가 없습니다'),
                  );
                }

                // 검색 결과가 있을 때만 표시
                if (filteredPortfolios.isNotEmpty) {
                  return Column(
                    children: filteredPortfolios.map((portfolioData) {
                      return InkWell(
                        onTap: () {
                          Map<String, dynamic> selectedPortfolioData = portfolioData.data() as Map<String, dynamic>;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SearchPortfolioDetail(
                                portfolioItem: selectedPortfolioData,
                                user: userId,
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
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10.0),
                                        child: Image.network(
                                          portfolioData['thumbnailUrl'],
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
                                            portfolioData['title'].length > 7
                                                ? '${portfolioData['title'].substring(0, 7)}...'
                                                : portfolioData['title'],
                                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                          ),
                                          Container(
                                            width: 110,
                                            child: Text(
                                              portfolioData['portfolioDescription'].length > 20
                                                  ? '${portfolioData['portfolioDescription'].substring(0, 20)}...'
                                                  : portfolioData['portfolioDescription'],
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
                                        '카테고리: ${portfolioData['category']}',
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
                } else {
                  return Container(); // 검색 결과가 없을 때는 아무 것도 표시하지 않음
                }
              },
            );
          },
        );
      },
    );
  }






}
