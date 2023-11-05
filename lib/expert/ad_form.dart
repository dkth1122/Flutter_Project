import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'ad_model.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Authentication 추가
import 'package:provider/provider.dart'; // Provider 추가
import '../join/userModel.dart'; // 사용자 모델 파일 임포트

class AdForm extends StatefulWidget {
  @override
  _AdFormState createState() => _AdFormState();
}

class _AdFormState extends State<AdForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();
  String user = ''; // 사용자 정보 추가

  @override
  void initState() {
    super.initState();
    UserModel um = Provider.of<UserModel>(context, listen: false);
    if (um.isLogin) {
      user = um.userId!;
      print(user);
    } else {
      user = '없음';
      print('로그인 안됨');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('광고 신청'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(labelText: '제목'),
              validator: (value) {
                if (value!.isEmpty) {
                  return '제목을 입력하세요';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: '설명'),
            ),
            TextFormField(
              controller: _budgetController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: '예산'),
              validator: (value) {
                if (value!.isEmpty) {
                  return '예산을 입력하세요';
                }
                return null;
              },
            ),
            Text('시작일: $_startDate'),
            ElevatedButton(
              onPressed: () {
                showDatePicker(
                  context: context,
                  initialDate: _startDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2030),
                ).then((newDate) {
                  if (newDate != null) {
                    setState(() {
                      _startDate = newDate;
                    });
                  }
                });
              },
              child: Text('시작일 선택'),
            ),
            Text('종료일: $_endDate'),
            ElevatedButton(
              onPressed: () {
                showDatePicker(
                  context: context,
                  initialDate: _endDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2030),
                ).then((newDate) {
                  if (newDate != null) {
                    setState(() {
                      _endDate = newDate;
                    });
                  }
                });
              },
              child: Text('종료일 선택'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final newAd = Ad(
                    id: UniqueKey().toString(),
                    title: _titleController.text,
                    description: _descriptionController.text,
                    budget: double.parse(_budgetController.text),
                    startDate: _startDate,
                    endDate: _endDate,
                    userId: user, // 사용자 정보 추가
                  );

                  saveAdToFirestore(newAd);
                }
              },
              child: Text('신청'),
            ),
          ],
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
