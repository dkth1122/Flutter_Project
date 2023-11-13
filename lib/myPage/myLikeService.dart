import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../join/userModel.dart';
import '../product/productView.dart';

class myLikeService extends StatefulWidget {
  const myLikeService({super.key});

  @override
  State<myLikeService> createState() => _myLikeServiceState();
}

class _myLikeServiceState extends State<myLikeService> {
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
      body: myJjimService(),
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
              stream: FirebaseFirestore.instance
                  .collection('product')
                  .where('pName', isEqualTo: pName)
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
                  return Text('찜한 포트폴리오가 존재하지 않습니다.');
                }
              },
            );
          },
        );
      },
    );
  }
}

