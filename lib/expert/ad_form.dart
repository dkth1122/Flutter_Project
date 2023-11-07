import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'ad_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../join/userModel.dart';

class AdForm extends StatefulWidget {
  @override
  _AdFormState createState() => _AdFormState();
}

class _AdFormState extends State<AdForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  int selectedBudget = 99000; // 선택된 예산 값
  DateTime _startDate = DateTime.now();
  DateTime fixedEndDate30 = DateTime.now().add(Duration(days: 30)); // 30일 뒤로 설정
  String user = '';

  double discountRate = 0.0;

  @override
  void initState() {
    super.initState();
    UserModel um = Provider.of<UserModel>(context, listen: false);
    if (um.isLogin) {
      user = um.userId!;
    } else {
      user = '없음';
      print('로그인X');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('광고 신청'),
        backgroundColor: Color(0xFF4E598C), // 앱 바의 배경색
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: '제목',
                    fillColor: Colors.white, // 입력 필드의 배경색
                    filled: true,
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return '제목을 입력하세요';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: '설명',
                    fillColor: Colors.white, // 입력 필드의 배경색
                    filled: true,
                  ),
                ),
              ),
              Text('예산: $selectedBudget 원', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFFFF9C784)),),
              Text('시작일: 신청 시작 당일', style: TextStyle(color: Color(0xFFFCAF58)),),
              Text('종료일: 시작일로부터 정확히 30일 뒤', style: TextStyle(color: Color(0xFFFCAF58)),),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedBudget = 99000;
                        _startDate = DateTime.now();
                        fixedEndDate30 = DateTime.now().add(Duration(days: 30));
                      });
                    },
                    child: Text('30일 - 99,000원', style: TextStyle(color: Colors.white),),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Color(0xFF4E598C)), // 버튼의 배경색
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedBudget = 282150;
                        _startDate = DateTime.now();
                        fixedEndDate30 = DateTime.now().add(Duration(days: 90));
                      });
                    },
                    child: Text('90일 - 282,150 (5% 할인)', style: TextStyle(color: Colors.white),),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Color(0xFF4E598C)), // 버튼의 배경색
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedBudget = 1084050;
                        _startDate = DateTime.now();
                        fixedEndDate30 = DateTime.now().add(Duration(days: 365));
                      });
                    },
                    child: Text('365일 - 1,084,050원 (10% 할인)', style: TextStyle(color: Colors.white),),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Color(0xFF4E598C)), // 버튼의 배경색
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final newAd = Ad(
                      id: UniqueKey().toString(),
                      title: _titleController.text,
                      description: _descriptionController.text,
                      budget: selectedBudget,
                      startDate: _startDate,
                      endDate: fixedEndDate30,
                      userId: user,
                    );

                    saveAdToFirestore(newAd);
                  }
                },
                child: Text('신청', style: TextStyle(color: Colors.white),),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Color(0xFF4E598C)), // 버튼의 배경색
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> saveAdToFirestore(Ad newAd) async {
    try {
      await FirebaseFirestore.instance.collection('ads').add({
        'title': newAd.title,
        'description': newAd.description,
        'budget': newAd.budget,
        'startDate': newAd.startDate,
        'endDate': newAd.endDate,
        'userId': newAd.userId,
      });

      showSnackbar('저장 완료', context);
    } catch (e) {
      print('Firestore에 데이터를 저장하는 동안 오류가 발생했습니다: $e');
    }
  }

  void showSnackbar(String message, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }
}

