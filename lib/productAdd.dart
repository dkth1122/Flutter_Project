import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:project_flutter/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(ProductAdd());
}

class ProductAdd extends StatefulWidget {
  @override
  State<ProductAdd> createState() => _ProductAddState();
}

class _ProductAddState extends State<ProductAdd> {
  String newProduct = "";
  String newProductDetail = "";
  String newAuthor = "";
  late TextEditingController productController;
  late TextEditingController detailController;
  late TextEditingController authorController;
  List<Map<String, dynamic>> product = [];

  @override
  void initState() {
    super.initState();
    productController = TextEditingController();
    detailController = TextEditingController();
    authorController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Chat App'),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  TextField(
                    controller: productController,
                    onChanged: (text) {
                      setState(() {
                        newProduct = text;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: '상품명',
                    ),
                  ),
                  TextField(
                    controller: detailController,
                    onChanged: (text) {
                      setState(() {
                        newProductDetail = text;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: '상세 내용',
                    ),
                  ),
                  TextField(
                    controller: authorController,
                    onChanged: (text) {
                      setState(() {
                        newAuthor = text;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: '작성자',
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      handleOnSubmit();
                    },
                    child: Text('등록'),
                  ),
                ],
              ),
            ),
            Expanded(child: _productList()),
          ],
        ),
      ),
    );
  }

  Widget _productList() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection("product").snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        if (snap.hasError) {
          return Text('Error: ${snap.error}');
        }

        if (snap.data != null) {
          return ListView(
            children: snap.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
              document.data() as Map<String, dynamic>;
              return ListTile(
                title: Text(data['product_name']),
                subtitle: Text("작성일 : ${data['sendTime'].toDate().toString()}"),
              );
            }).toList(),
          );
        } else {
          return Text('No data available.');
        }
      },
    );
  }

  void handleOnSubmit() {
    if (newProduct.trim().isNotEmpty) {
      FirebaseFirestore.instance.collection('product').add({
        'product_name': newProduct.trim(),
        'product_detail': newProductDetail.trim(),
        'author': newAuthor.trim(),
        'sendTime': FieldValue.serverTimestamp(),
        'user': 'User', // Change to current user's display name
      });

      productController.clear();
      detailController.clear();
      authorController.clear();
    }
  }

  @override
  void dispose() {
    productController.dispose();
    detailController.dispose();
    authorController.dispose();
    super.dispose();
  }
}
