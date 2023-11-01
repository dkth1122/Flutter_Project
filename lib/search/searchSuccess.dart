import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../firebase_options.dart';
import '../product/productView.dart';

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
      appBar: AppBar(title: Text("검색성공"),),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20,),
            Text("검색어 : $searchText", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
            SizedBox(height: 20,),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width: 10,),
                Text("상품 리스트", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
              ],
            ),
            SizedBox(height: 20,),
            searchListProduct(),
            SizedBox(height: 20,),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width: 10,),
                Text("포트폴리오 리스트", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
              ],
            ),
            Text("포트폴리오 상세정보는 다이어로그로 되어있어서 불러오기가 어려움 ㅠ 현재 하드코딩 되어있어서 완성되면 가져오자"),
            SizedBox(height: 20,),
            searchListPortFolio(),
          ],
        ),
      ),
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
              child: ListTile(
                leading: Image.network(
                  data['iUrl'],
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
                title: Text(data['pName']),
                subtitle: Text(
                  data['pDetail'].length > 15
                      ? '${data['pDetail'].substring(0, 15)}...'
                      : data['pDetail'],
                ),
                trailing: Text('${(data['price'])}원'),
              ),
            );
          },
        );
      },
    );
  }
  Widget searchListPortFolio() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collectionGroup("portfolio").snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snap) {
        if (!snap.hasData) {
          return CircularProgressIndicator();
        }

        final List<DocumentSnapshot> filteredDocs = snap.data!.docs
            .where((document) {
          Map<String, dynamic> data = document.data() as Map<String, dynamic>;
          String title = data['title'];
          String description = data['description'];
          return title.contains(widget.searchText) || description.contains(widget.searchText);
        }).toList();

        if (filteredDocs.isEmpty) {
          // 포트폴리오 데이터가 없을 때 "포트폴리오 리스트"를 숨깁니다.
          return SizedBox.shrink();
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: filteredDocs.length,
          itemBuilder: (context, index) {
            Map<String, dynamic> data = filteredDocs[index].data() as Map<String, dynamic>;

            return InkWell(
              onTap: () {
              },
              child: ListTile(
                leading: Image.network(
                  data['thumbnailUrl'],
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
                title: Text(data['title']),
                subtitle: Text(
                  data['description'].length > 15
                      ? '${data['description'].substring(0, 15)}...'
                      : data['description'],
                ),
              ),
            );
          },
        );
      },
    );
  }

}
