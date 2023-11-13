import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:project_flutter/search/searchPortfolioDetail.dart';

class Test extends StatefulWidget {
  const Test({super.key});

  @override
  State<Test> createState() => _TestState();
}

class _TestState extends State<Test> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          children: [
            _cntPortFolio(),
          ],
        ),
      ),
    );
  }

  Widget _cntPortFolio() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collectionGroup("portfolio").snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        // 데이터를 가져오고 ListView.builder를 사용하여 목록을 만듭니다.
        var portfolios = snapshot.data!.docs;
        portfolios.sort((a, b) => (a['cnt'] as int).compareTo(b['cnt'] as int));

        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: portfolios.length,
          itemBuilder: (context, index) {
            var portfolio = portfolios[index].data() as Map<String, dynamic>;
            // 여기에서 가져온 데이터를 사용하여 원하는 작업을 수행하세요.
            // 예를 들어, 포트폴리오 정보를 표시하거나 다른 위젯을 만들 수 있습니다.
            return ListTile(
              title: Text(portfolio['title']),
              subtitle: Text('Count: ${portfolio['cnt']}'),
              onTap: () {
              },
            );
          },
        );
      },
    );
  }

  Widget _categoryPortfolioList(String sendText) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('expert').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        final List<DocumentSnapshot> experts = snapshot.data!.docs;

        return ListView.builder(
          physics: NeverScrollableScrollPhysics(), // 스크롤 금지
          shrinkWrap: true,
          itemCount: experts.length,
          itemBuilder: (context, index) {
            final expertData = experts[index].data() as Map<String, dynamic>;
            final userId = expertData['userId'].toString();

            return StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('expert')
                  .doc(userId)
                  .collection('portfolio')
                  .where("category", isEqualTo: sendText)
                  .snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                final List<DocumentSnapshot> portfolioDocs = snapshot.data!.docs;

                return ListView.builder(
                    physics: NeverScrollableScrollPhysics(), // 스크롤 금지
                    shrinkWrap: true,
                    itemCount: portfolioDocs.length,
                    itemBuilder: (context, index){
                      Map<String, dynamic> data = portfolioDocs[index].data() as Map<String, dynamic>;
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SearchPortfolioDetail(
                                portfolioItem: data,
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
                          ],
                        ),
                      );
                    }
                );
              },
            );
          },
        );
      },
    );
  }
}
