import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:project_flutter/search/searchPortfolioDetail.dart';

class Test extends StatefulWidget {
  const Test({Key? key});

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
      stream: FirebaseFirestore.instance.collectionGroup("portfolio").limit(4).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        // 데이터를 가져오고 ListView.builder를 사용하여 목록을 만듭니다.
        var portfolios = snapshot.data!.docs;

        // sort 함수를 사용하여 cnt를 기준으로 정렬
        portfolios.sort((a, b) => (b['cnt'] as int).compareTo(a['cnt'] as int));

        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: portfolios.length,
          itemBuilder: (context, index) {
            var portfolio = portfolios[index].data() as Map<String, dynamic>;
            return ListTile(
              title: Text(portfolio['title']),
              subtitle: Text('Count: ${portfolio['cnt']}'),
              onTap: () {
                // 클릭했을 때 추가 작업 수행
                var portfolioId = portfolios[index].id; // "portfolio" 문서의 ID 가져오기
                var parentCollectionId = portfolios[index].reference.parent!.id; // 상위 컬렉션의 ID 가져오기

                // 이제 portfolioId 및 parentCollectionId를 사용하여 필요한 작업을 수행할 수 있습니다.
                print("Portfolio ID: $portfolioId");
                print("Parent Collection ID: $parentCollectionId");
              },

            );
          },
        );
      },
    );
  }
}
