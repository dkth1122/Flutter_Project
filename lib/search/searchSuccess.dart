import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../firebase_options.dart';
import '../productView.dart';

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
      body: Column(
        children: [
          Text("검색어 : $searchText"),
          Expanded(child: searchListProduct())
        ],
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
        })
            .toList();

        return ListView.builder(
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
                leading: Image.asset('assets/cat1.jpeg'),
                title: Text(data['pName']),
                subtitle: Text('내용 : ${data['pDetail']}'),
                trailing: Text('${(data['price'])}원'),
              ),
            );
          },
        );
      },
    );
  }
}
