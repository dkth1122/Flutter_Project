import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project_flutter/join/userModel.dart';
import 'package:provider/provider.dart';

import '../firebase_options.dart';

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
  final ImagePicker _picker = ImagePicker();
  String imageUrl = "";
  final TextEditingController _cnt = TextEditingController();
  String user = "";

  @override
  void initState() {
    super.initState();
    UserModel um = Provider.of<UserModel>(context, listen: false);

    if (um.isLogin) {
      // 사용자가 로그인한 경우
      user = um.userId!;
      print(user);
    } else {
      // 사용자가 로그인하지 않은 경우
      user = "없음";
      print("로그인 안됨");
    }
  }

  String? _selectedCategory;

  final List<String> categories = [    'UX기획',    '웹',    '커머스',    '모바일',    '프로그램',    '트렌드',    '데이터',    '기타',  ];

  void _addProduct() async {
    if (_pName.text.isNotEmpty &&
        _pDetail.text.isNotEmpty &&
        _price.text.isNotEmpty &&
        _selectedCategory != null) {
      CollectionReference product =
      FirebaseFirestore.instance.collection('product');

      await product.add({
        'pName': _pName.text,
        'pDetail': _pDetail.text,
        'price': int.parse(_price.text),
        'iUrl': imageUrl,
        'category': _selectedCategory,
        'cnt': 0,
        'user': user,
        'sendTime': FieldValue.serverTimestamp(),
        'likeCnt' : 0
      });

      _pName.clear();
      _pDetail.clear();
      _price.clear();
      imageUrl = "";
      _cnt.clear();
    } else {
      print("내용을 입력해주세요.");
    }
  }

  Future<void> uploadImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    File imageFile = File(image.path);

    try {
      // Firebase Storage에 이미지 업로드
      final Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('images/${DateTime.now()}.png');
      await storageRef.putFile(imageFile);

      // 이미지의 다운로드 URL을 얻기
      imageUrl = await storageRef.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('images')
          .add({'url': imageUrl});

      // 업로드 성공
      print('이미지 업로드 완료: $imageUrl');

      // 이미지가 업로드된 후 상태를 갱신하여 이미지를 표시
      setState(() {});
    } catch (e) {
      // 업로드 실패
      print('이미지 업로드 실패: $e');
    }
  }

  Widget _listProduct() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("product")
          .orderBy("sendTime", descending: true)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snap) {
        if (!snap.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        return ListView.builder(
          shrinkWrap: true,
          itemCount: snap.data!.docs.length,
          itemBuilder: (context, index) {
            DocumentSnapshot doc = snap.data!.docs[index];
            Map<String, dynamic> data =
            doc.data() as Map<String, dynamic>;
            // 아이템 빌더 코드...
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "상품등록",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF4E598C),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  RegExp numeric = RegExp(r'^[0-9]*$');
                  if (!numeric.hasMatch(value)) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('숫자 입력'),
                          content: Text('숫자만 입력할 수 있습니다.'),
                          actions: <Widget>[
                            TextButton(
                              child: Text('확인'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                    _price.clear();
                  } else {
                    int price = int.parse(value);
                    if (price < 0 || price > 100000000) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('금액 설정'),
                            content: Text('가격은 1원 이상, 100,000,000원 미만으로 입력해주세요.'),
                            actions: <Widget>[
                              TextButton(
                                child: Text('확인'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                      _price.clear();
                    }
                  }
                },
              ),
            SizedBox(height: 20),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    imageUrl.isNotEmpty
                        ? Image.network(
                      imageUrl,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    )
                        : Text('이미지가 없습니다.'),
                    ElevatedButton(
                      onPressed: uploadImage,
                      child: Text('이미지 업로드'),
                      style: ElevatedButton.styleFrom(
                        primary: Color(0xFFFCAF58),
                      ),
                    ),
                  ],
                ),
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
              Center(
                child: ElevatedButton(
                  onPressed: _addProduct,
                  child: Text("상품 추가"),
                  style: ElevatedButton.styleFrom(
                    primary: Color(0xFFFCAF58),
                  ),
                ),
              ),
              SizedBox(height: 20),
              _listProduct(),
            ],
          ),
        ),
      ),
    );
  }
}
