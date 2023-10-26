import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _pName = TextEditingController();
  final TextEditingController _pDetail = TextEditingController();
  final TextEditingController _price = TextEditingController();
  final TextEditingController _iUrl = TextEditingController();
  final TextEditingController _cnt = TextEditingController();
  final TextEditingController _user = TextEditingController();

  String? _selectedCategory;

  final List<String> categories = ['UX기획','웹','커머스','모바일','프로그램','트렌드','데이터','기타',];

  void _addProduct() async {
    if (_pName.text.isNotEmpty &&
        _pDetail.text.isNotEmpty &&
        _price.text.isNotEmpty &&
        _iUrl.text.isNotEmpty &&
        _selectedCategory != null) {
      CollectionReference product =
      FirebaseFirestore.instance.collection('product');

      await product.add({
        'pName': _pName.text,
        'pDetail': _pDetail.text,
        'price': int.parse(_price.text),
        'iUrl': _iUrl.text,
        'category': _selectedCategory,
        'cnt': 0,
        'user': _user.text,
        'sendTime': FieldValue.serverTimestamp(),
      });

      _pName.clear();
      _pDetail.clear();
      _price.clear();
      _iUrl.clear();
      _cnt.clear();
    } else {
      print("내용을 입력해주세요.");
    }
  }

  Widget _listProduct() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("product")
          .orderBy("timestamp", descending: true)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snap) {
        if (!snap.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        return Expanded(
          child: ListView.builder(
            itemCount: snap.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot doc = snap.data!.docs[index];
              Map<String, dynamic> data =
              doc.data() as Map<String, dynamic>;

              return ListTile(
                title: Text('${index + 1}. ${data['title']}'),
                onTap: () {},
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("상품등록")),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: [
            SizedBox(height: 10),
            TextField(
              controller: _pName,
              decoration: InputDecoration(labelText: "상품명"),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _pDetail,
              decoration: InputDecoration(labelText: "상품 설명"),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _price,
              decoration: InputDecoration(labelText: "가격"),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _iUrl,
              decoration: InputDecoration(labelText: "상품 이미지"),
            ),
            SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              items: categories.map((String category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (String? value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
              decoration: InputDecoration(labelText: "카테고리"),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _user,
              decoration: InputDecoration(labelText: "등록자"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addProduct,
              child: Text("상품 추가"),
            ),
            SizedBox(height: 20),
            _listProduct(),
          ],
        ),
      ),
    );
  }
}
