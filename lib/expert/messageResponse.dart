import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../join/userModel.dart';
import '../subBottomBar.dart';

class MessageResponse extends StatefulWidget {
  @override
  _MessageResponsenState createState() => _MessageResponsenState();
}

class _MessageResponsenState extends State<MessageResponse> {
  bool isResponseEnabled = true;
  bool isNightResponseEnabled = true;
  bool isOnVacation = false;
  DateTime? vacationStartDate = DateTime.now();
  DateTime? vacationEndDate = DateTime.now();

  String user = "";

  @override
  void initState() {
    super.initState();
    UserModel um = Provider.of<UserModel>(context, listen: false);
    if (um.isLogin) {
      user = um.userId!;
      // Firestore에서 설정 정보 가져오기
      getSettingsFromFirestore();
    } else {
      user = "없음";
      print("로그인 안됨");
    }
  }

  // Firestore에서 설정 정보 가져오기
  Future<void> getSettingsFromFirestore() async {
    final userSettingsRef = FirebaseFirestore.instance.collection('messageResponse').doc(user);

    final doc = await userSettingsRef.get();
    if (doc.exists) {
      setState(() {
        isResponseEnabled = doc['isResponseEnabled'];
        isNightResponseEnabled = doc['isNightResponseEnabled'];
        isOnVacation = doc['isOnVacation'];
        vacationStartDate = doc['vacationStartDate'].toDate();
        vacationEndDate = doc['vacationEndDate'].toDate();
      });
    }
  }

  void toggleSetting(String setting) {
    setState(() {
      if (setting == '30분 이내 응답 가능') {
        isResponseEnabled = !isResponseEnabled;
      } else if (setting == '야간 응답') {
        isNightResponseEnabled = !isNightResponseEnabled;
      } else if (setting == '휴가 중') {
        isOnVacation = !isOnVacation;
      }
    });
  }

  Future<void> selectDate(BuildContext context, String type) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (pickedDate != null) {
      setState(() {
        if (type == '시작일') {
          vacationStartDate = pickedDate;
        } else if (type == '종료일') {
          vacationEndDate = pickedDate;
        }
      });
    }
  }

  int calculateVacationDays() {
    if (vacationStartDate != null && vacationEndDate != null) {
      return vacationEndDate!.difference(vacationStartDate!).inDays;
    }
    return 0;
  }

  // Firestore에 설정 정보 저장
  Future<void> saveSettingsToFirestore() async {
    final userSettingsRef = FirebaseFirestore.instance.collection('messageResponse').doc(user);

    await userSettingsRef.set({
      'isResponseEnabled': isResponseEnabled,
      'isNightResponseEnabled': isNightResponseEnabled,
      'isOnVacation': isOnVacation,
      'vacationStartDate': vacationStartDate, // 휴가 시작 날짜 저장
      'vacationEndDate': vacationEndDate,     // 휴가 종료 날짜 저장
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('설정이 저장되었습니다.')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white10,
        elevation: 0,
        title: Text(
          '메시지 응답 설정',
          style: TextStyle(
            color: Color(0xff424242),
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Color(0xff424242),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  ListTile(
                    title: Text(
                      '시작일: ${DateFormat('yyyy-MM-dd').format(vacationStartDate ?? DateTime.now())}',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xff424242)),
                    ),
                    trailing: IconButton(
                      onPressed: () => selectDate(context, '시작일'),
                      icon: Icon(Icons.calendar_month, color: Color(0xFFFF8C42),),
                    ),
                  ),
                  ListTile(
                    title: Text(
                      '종료일: ${DateFormat('yyyy-MM-dd').format(vacationEndDate ?? DateTime.now())}',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xff424242)),
                    ),
                    trailing: IconButton(
                      onPressed: () => selectDate(context, '종료일'),
                      icon: Icon(Icons.calendar_month, color: Color(0xFFFF8C42),),
                    ),
                  ),
                  Text(
                    '휴가 일수: ${calculateVacationDays()}일',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  buildSwitch('휴가 중', isOnVacation),
                ],
              ),
            ),
            Divider(
              color: Colors.grey,
              height: 1.0,
            ),
            ListTile(
              title: Text(
                '지금 상담 가능',
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xff424242)),
              ),
              subtitle: Text('의뢰인의 문의 메시지에 최대 30분 이내로 응답 가능'),
              trailing: buildSwitch('30분 이내 응답 가능', isResponseEnabled),
            ),
            Divider(
              color: Colors.grey,
              height: 1.0,
            ),
            SizedBox(height: 10,),
            ListTile(
              title: Text(
                '야간 응답 가능',
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xff424242)),
              ),
              subtitle: Text('23:00~08:00(KST)까지 의뢰인의 문의 메시지에 응답 가능'),
              trailing: buildSwitch('야간 응답', isNightResponseEnabled),
            ),
            SizedBox(height: 30,),
            ElevatedButton(
                onPressed: (){
                  saveSettingsToFirestore();
                },
                style: ElevatedButton.styleFrom(
                  primary: Color(0xFFFF8C42), // 버튼의 배경색 설정
                  padding: EdgeInsets.fromLTRB(30, 15, 30, 15)
                ),
                child: Text('등록하기', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),)
            )
          ],
        ),
      ),
      bottomNavigationBar: SubBottomBar(),
    );
  }

  Widget buildSwitch(String label, bool value) {
    return Switch(
      value: value,
      onChanged: (bool newValue) {
        toggleSetting(label);
      },
      activeColor: Color(0xFFFF8C42),
    );
  }
}
