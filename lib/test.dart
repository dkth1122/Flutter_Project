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

}
