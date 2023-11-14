import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:project_flutter/subBottomBar.dart';
import 'package:provider/provider.dart';

import '../join/userModel.dart';
import '../product/productView.dart';
import '../search/searchPortfolioDetail.dart';

class MyLike extends StatefulWidget {
  const MyLike({super.key});

  @override
  State<MyLike> createState() => _MyLikeState();
}
class _MyLikeState extends State<MyLike> {
  List<String> optionsButton = ['전체','UX기획','웹','커머스','모바일','프로그램','트렌드','데이터','기타'];
  String selectedCategory = '전체';
  String sessionId = "";
  @override
  Widget build(BuildContext context) {
    UserModel um = Provider.of<UserModel>(context, listen: false);

    if (um.isLogin) {
      sessionId = um.userId!;
    } else {
      sessionId = "";
    }
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            '${selectedCategory} 찜 목록',
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
            IconButton(
              onPressed: (){
                _showFilterOptions(context, optionsButton);
              },
              icon: Icon(Icons.filter_list, color:Color(0xFFFF8C42)),
            )
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
            Container(
              padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: myJjimService()
            ),
            Container(
              padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: myJjimPortFolio()
            )
          ],
        ),
        bottomNavigationBar: SubBottomBar(),
      ),
    );
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
                  selectedCategory = option;
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        );
      },
    );
  }
  
  Widget myJjimService() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('like')
          .where('user', isEqualTo: sessionId)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> jjimSnap) {
        if (!jjimSnap.hasData) {
          return CircularProgressIndicator();
        }

        final List<DocumentSnapshot> jjimDocs = jjimSnap.data!.docs;

        return ListView.builder(
          itemCount: jjimDocs.length,
          itemBuilder: (context, index) {
            Map<String, dynamic> jjimData = jjimDocs[index].data() as Map<String, dynamic>;
            String pName = jjimData['pName'];

            return StreamBuilder(
              stream: selectedCategory == '전체'
                  ? FirebaseFirestore.instance
                  .collection('product')
                  .where('pName', isEqualTo: pName)
                  .snapshots()
                  : FirebaseFirestore.instance
                  .collection('product')
                  .where('pName', isEqualTo: pName)
                  .where('category', isEqualTo: selectedCategory)
                  .snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> productSnap) {
                if (!productSnap.hasData) {
                  return CircularProgressIndicator();
                }

                final List<DocumentSnapshot> productDocs = productSnap.data!.docs;

                if (productDocs.isNotEmpty) {
                  Map<String, dynamic> productData = productDocs.first.data() as Map<String, dynamic>;

                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductView(
                            productName: productData['pName'],
                            price: productData['price'].toString(), // 적절한 키를 사용하여 가격을 가져와야 합니다.
                            imageUrl: productData['iUrl'],
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
                                      productData['iUrl'],
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
                                        productData['pName'].length > 7
                                            ? '${productData['pName'].substring(0, 7)}...'
                                            : productData['pName'],
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                      Container(
                                        width: 110,
                                        child: Text(
                                          productData['pDetail'].length > 20
                                              ? '${productData['pDetail'].substring(0, 20)}...'
                                              : productData['pDetail'],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    onPressed: () async{
                                      if (sessionId.isNotEmpty) {
                                        final QuerySnapshot result = await FirebaseFirestore
                                            .instance
                                            .collection('like')
                                            .where('pName', isEqualTo: pName)
                                            .where('user', isEqualTo: sessionId)
                                            .get();

                                        if (result.docs.isNotEmpty) {
                                          final documentId = result.docs.first.id;
                                          FirebaseFirestore.instance.collection('like').doc(documentId).delete();

                                          final productQuery = await FirebaseFirestore.instance
                                              .collection('product')
                                              .where('pName', isEqualTo: productData['pName'])
                                              .get();

                                          if (productQuery.docs.isNotEmpty) {
                                            final productDocId = productQuery.docs.first.id;
                                            final currentLikeCount = productQuery.docs.first['likeCnt'] ?? 0;

                                            int newLikeCount;

                                            // 좋아요를 취소했을 때
                                            if (result.docs.isNotEmpty) {
                                              newLikeCount = currentLikeCount - 1;
                                            } else {
                                              newLikeCount = currentLikeCount + 1;
                                            }

                                            // "likeCnt" 업데이트
                                            FirebaseFirestore.instance
                                                .collection('product')
                                                .doc(productDocId)
                                                .set({
                                              'likeCnt': newLikeCount,
                                            }, SetOptions(merge: true));
                                          }



                                        }else{
                                          FirebaseFirestore.instance.collection('like').add({
                                            'user': sessionId,
                                            'pName' : productData['pName']
                                          });

                                          final productQuery = await FirebaseFirestore.instance
                                              .collection('product')
                                              .where('pName', isEqualTo: productData['pName'])
                                              .get();

                                          if (productQuery.docs.isNotEmpty) {
                                            final productDocId = productQuery.docs.first.id;
                                            final currentLikeCount = productQuery.docs.first['likeCnt'] ?? 0;

                                            // "likeCnt" 업데이트
                                            FirebaseFirestore.instance
                                                .collection('product')
                                                .doc(productDocId).update({
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
                                          .where('pName', isEqualTo:productData['pName'])
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

                                  Text(
                                    '카테고리: ${productData['category']}',
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
                } else {
                  // 해당 포트폴리오가 삭제되었거나 존재하지 않는 경우의 처리
                  return Container();
                }
              },
            );
          },
        );
      },
    );
  }
  Widget myJjimPortFolio() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('portfolioLike')
          .where('user', isEqualTo: sessionId)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> jjimSnap) {
        if (!jjimSnap.hasData) {
          return CircularProgressIndicator();
        }

        final List<DocumentSnapshot> jjimDocs = jjimSnap.data!.docs;

        return ListView.builder(
          itemCount: jjimDocs.length,
          itemBuilder: (context, index) {
            Map<String, dynamic> jjimData = jjimDocs[index].data() as Map<String, dynamic>;
            String uId = jjimData['portfoiloId'];
            String portfolioTitle = jjimData['title'];

            return StreamBuilder(
              stream: selectedCategory == '전체'
                  ? FirebaseFirestore.instance
                  .collection('expert')
                  .doc(uId)
                  .collection('portfolio')
                  .where('title', isEqualTo: portfolioTitle)
                  .snapshots()
                  : FirebaseFirestore.instance
                  .collection('expert')
                  .doc(uId)
                  .collection('portfolio')
                  .where('title', isEqualTo: portfolioTitle)
                  .where('category', isEqualTo: selectedCategory)
                  .snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> portfolioSnap) {
                if (!portfolioSnap.hasData) {
                  return CircularProgressIndicator();
                }

                final List<DocumentSnapshot> portfolioDocs = portfolioSnap.data!.docs;

                if (portfolioDocs.isNotEmpty) {
                  Map<String, dynamic> portfolioData = portfolioDocs.first.data() as Map<String, dynamic>;

                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SearchPortfolioDetail(
                            portfolioItem: portfolioData,
                            user: uId,
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
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    onPressed: () async{
                                      if (sessionId.isNotEmpty) {
                                        final QuerySnapshot result = await FirebaseFirestore
                                            .instance
                                            .collection('portfolioLike')
                                            .where('user', isEqualTo: sessionId)
                                            .where('portfoiloId', isEqualTo: uId)
                                            .where('title', isEqualTo:portfolioData['title'])
                                            .get();

                                        if (result.docs.isNotEmpty) {
                                          final documentId = result.docs.first.id;
                                          FirebaseFirestore.instance.collection('portfolioLike').doc(documentId).delete();

                                          final portfolioQuery = await FirebaseFirestore.instance
                                              .collection('expert')
                                              .doc(uId)
                                              .collection("portfolio")
                                              .where('title', isEqualTo: portfolioData['title'])
                                              .get();

                                          if (portfolioQuery.docs.isNotEmpty) {
                                            final productDocId = portfolioQuery.docs.first.id;
                                            final currentLikeCount = portfolioQuery.docs.first['likeCnt'] ?? 0;

                                            int newLikeCount;

                                            // 좋아요를 취소했을 때
                                            if (result.docs.isNotEmpty) {
                                              newLikeCount = currentLikeCount - 1;
                                            } else {
                                              newLikeCount = currentLikeCount + 1;
                                            }

                                            // "likeCnt" 업데이트
                                            FirebaseFirestore.instance
                                                .collection('expert')
                                                .doc(uId)
                                                .collection("portfolio")
                                                .doc(productDocId)
                                                .set({
                                              'likeCnt': newLikeCount,
                                            }, SetOptions(merge: true));
                                          }



                                        }else{
                                          FirebaseFirestore.instance.collection('portfolioLike').add({
                                            'user': sessionId,
                                            'portfoiloId': uId,
                                            'title' : portfolioData['title']
                                          });

                                          final portfolioQuery = await FirebaseFirestore.instance
                                              .collection('expert')
                                              .doc(uId)
                                              .collection("portfolio")
                                              .where('title', isEqualTo: portfolioData['title'])
                                              .get();

                                          if (portfolioQuery.docs.isNotEmpty) {
                                            final portfolioDocId = portfolioQuery.docs.first.id;
                                            final currentLikeCount = portfolioQuery.docs.first['likeCnt'] ?? 0;

                                            // "likeCnt" 업데이트
                                            FirebaseFirestore.instance
                                                .collection('expert')
                                                .doc(uId)
                                                .collection("portfolio")
                                                .doc(portfolioDocId).update({
                                              'likeCnt': currentLikeCount + 1, // 좋아요를 추가했으므로 증가
                                            });
                                          }
                                        }
                                      }
                                    },
                                    icon: sessionId.isNotEmpty
                                        ? StreamBuilder<QuerySnapshot>(
                                      stream: FirebaseFirestore.instance
                                          .collection('portfolioLike')
                                          .where('user', isEqualTo: sessionId)
                                          .where('portfoiloId', isEqualTo: uId)
                                          .where('title', isEqualTo:portfolioData['title'])
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
                } else {
                  // return Text('찜한 포트폴리오가 존재하지 않습니다.');
                  //위에 Text를 사용하기에는 like컬렉션에
                  // category값을 넣어야 하기 때문에 지금까지 넣은 데이터를 전부 수정해야함.
                  // 그러므로 그냥 container리턴
                  return Container();
                }
              },
            );
          },
        );
      },
    );
  }
}