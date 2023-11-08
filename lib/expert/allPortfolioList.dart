import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../join/userModel.dart';
import '../search/searchPortfolioDetail.dart';

class AllPortfolioList extends StatefulWidget {
  const AllPortfolioList({super.key});

  @override
  State<AllPortfolioList> createState() => _AllPortfolioListState();
}

class _AllPortfolioListState extends State<AllPortfolioList> {

  String sessionId = "";
  @override
  Widget build(BuildContext context) {
    UserModel um = Provider.of<UserModel>(context, listen: false);

    if (um.isLogin) {
      sessionId = um.userId!;
    } else {
      sessionId = "";
    }
    return Scaffold(
      appBar: AppBar(title: Text("포트폴리오 리스트"),),
      body: SingleChildScrollView(
        child: Column(
          children: [
            searchListPortFolio()
          ],

        ),
      ),
    );
  }
  Widget searchListPortFolio() {
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
            String uId = expertData['userId'];

            return StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("expert")
                  .doc(uId)
                  .collection("portfolio")
                  .snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> portfolioSnap) {
                if (!portfolioSnap.hasData) {
                  return CircularProgressIndicator();
                }

                final List<DocumentSnapshot> portfolioDocs = portfolioSnap.data!.docs;

                final filteredPortfolios = List.from(portfolioDocs);

                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: filteredPortfolios.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> portfolioData = filteredPortfolios[index].data() as Map<String, dynamic>;
                    return InkWell(
                        onTap: () {
                          Map<String, dynamic> selectedPortfolioData = filteredPortfolios[index].data() as Map<String, dynamic>;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SearchPortfolioDetail(
                                portfolioItem: selectedPortfolioData,
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
                                            print(sessionId);
                                            print(uId);

                                            if (result.docs.isNotEmpty) {
                                              final documentId = result.docs.first.id;
                                              FirebaseFirestore.instance.collection('portfolioLike').doc(documentId).delete();

                                              final portfolioQuery = await FirebaseFirestore.instance
                                                  .collection('expert')
                                                  .doc(uId)
                                                  .collection("portfolio")
                                                  .where('title', isEqualTo: portfolioData['title'])
                                                  .get();
                                              print(portfolioQuery);

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
                        )
                      // Text("Portfolio Title: ${portfolioData['title']}")
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
