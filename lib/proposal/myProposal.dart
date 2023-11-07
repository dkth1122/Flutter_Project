import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../join/userModel.dart';

class MyProjectProposal extends StatefulWidget {
  const MyProjectProposal({super.key});

  @override
  State<MyProjectProposal> createState() => _MyProjectProposalState();
}

class _MyProjectProposalState extends State<MyProjectProposal> {

  final TextEditingController _title = TextEditingController();
  final TextEditingController _content = TextEditingController();
  final TextEditingController _price = TextEditingController();
  String? _selectedCategory;
  final List<String> categories = [    'UX기획',    '웹',    '커머스',    '모바일',    '프로그램',    '트렌드',    '데이터',    '기타',  ];
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

  void _addProposal() async {
    if (_title.text.isNotEmpty &&
        _content.text.isNotEmpty &&
        _price.text.isNotEmpty &&
        _selectedCategory != null) {
      CollectionReference proposal =
      FirebaseFirestore.instance.collection('proposal');

      await proposal.add({
        'title': _title.text,
        'content': _content.text,
        'price': int.parse(_price.text),
        'category': _selectedCategory,
        'user': user,
        'sendTime': FieldValue.serverTimestamp(),
        'accept' : 0,//제안을 좋다고 표시한 횟수
        'cnt': 0,//조회수
      });

      _title.clear();
      _content.clear();
      _price.clear();
    } else {
      print("내용을 입력해주세요.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "프로젝트 의뢰(제안)",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFFFCAF58),
        elevation: 1.0,
        iconTheme: IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
              onPressed:_addProposal,
              child: Text("의뢰하기"))
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),
              TextField(
                controller: _title,
                decoration: InputDecoration(labelText: "프로젝트 제목"),
              ),
              SizedBox(height: 20),

              TextFormField(
                controller: _content,
                decoration: InputDecoration(
                  labelText: '제안 설명',
                  hintText: '10자 이상 입력하세요.',
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _price,
                decoration: InputDecoration(labelText: "제안가격"),
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
                            content: Text('가격은 10000원 이상, 100,000,000원 미만으로 입력해주세요.'),
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
            ],
          ),
        ),
      ),

    );
  }
}


