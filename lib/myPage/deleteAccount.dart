import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DeleteAccount extends StatefulWidget {
  final Map<String, dynamic> data;
  DeleteAccount({required this.data});

  @override
  State<DeleteAccount> createState() => _DeleteAccountState();
}

class _DeleteAccountState extends State<DeleteAccount> {
  String? selectedReason;
  String otherReason = ""; // 기타사유를 저장할 변수


  void deleteAccount() async {
    try {
      CollectionReference users = FirebaseFirestore.instance.collection("userList");
      QuerySnapshot snap = await users.where('userId', isEqualTo: widget.data['userId']).get();

      for (QueryDocumentSnapshot doc in snap.docs) {
        await users.doc(doc.id).update({'delYn': 'Y'});

      }

      // 업데이트 성공
      print('Firebase Firestore에서 "delYn" 업데이트 완료');
    } catch (e) {
      // 에러 처리
      print('Firebase Firestore에서 "delYn" 업데이트 중 에러 발생: $e');
    }
  }

  List<String> reasons = [
    "다른 플랫폼 이용 중",
    "이용하고 싶은 서비스가 없음.",
    "비매너 회원을 만났음.",
    "혜택이 적음",
    "서비스 이용에 불만족",
    "개인 정보 보호 우려",
    "다른 이유",
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Color(0xFF4E598C),
        hintColor: Color(0xFFFCAF58),
        fontFamily: 'Pretendard',
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.black, fontSize: 16),
        ),
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: TextStyle(
            color: Colors.black, // 레이블 텍스트의 색상
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF4E598C), width: 2.0),
            borderRadius: BorderRadius.circular(10.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF4E598C), width: 2.0),
            borderRadius: BorderRadius.circular(10.0),
          ),
          hintStyle: TextStyle(
            color: Color(0xFFFF8C42),
          ),
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            "회원 탈퇴",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: Color(0xFFFCAF58), // 배경색 변경
          elevation: 1.0,
          iconTheme: IconThemeData(color: Colors.white),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "픽서포유를 떠나는 이유를 선택해주세요:",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                Column(
                  children: reasons
                      .map(
                        (reason) => RadioListTile<String>(
                      title: Text(reason),
                      value: reason,
                      groupValue: selectedReason,
                      onChanged: (String? value) {
                        setState(() {
                          selectedReason = value;
                        });
                      },
                      activeColor: Color(0xFF4E598C),
                      tileColor: Color(0xFFFF9C784),
                    ),
                  )
                      .toList(),
                ),
                SizedBox(height: 24),
                Text(
                  "기타 이유를 입력해주세요:",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                TextField(
                  onChanged: (value) {
                    setState(() {
                      otherReason = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: "기타 이유를 입력하세요",
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF4E598C), width: 2.0),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF4E598C), width: 2.0),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                SizedBox(height: 24),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (selectedReason != null || otherReason.isNotEmpty) {
                        String finalReason = selectedReason ?? "기타 이유: $otherReason";
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text("선택한 이유"),
                              content: Text(
                                finalReason,
                                style: TextStyle(fontFamily: 'Pretendard', fontSize: 16),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(); // 선택한 이유 다이얼로그 닫기
                                    // 탈퇴 여부 확인 다이얼로그 표시
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: Text("정말로 탈퇴하시겠어요?"),
                                          content: Text(
                                            "사용하신 계정은 회원탈퇴 후 복구가 불가합니다.",
                                            style: TextStyle(fontFamily: 'Pretendard', fontSize: 16),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: Text("취소"),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                deleteAccount();
                                                Navigator.of(context).pop(); // 탈퇴 확인 다이얼로그 닫기
                                                // 회원 계정이 탈퇴되었습니다. 다이얼로그 표시
                                                showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return AlertDialog(
                                                      title: Text("회원 계정 탈퇴"),
                                                      content: Text(
                                                        "회원 계정이 성공적으로 탈퇴되었습니다.",
                                                        style: TextStyle(fontFamily: 'Pretendard', fontSize: 16),
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.of(context).pop();
                                                            Navigator.of(context).popUntil((route) => route.isFirst);
                                                          },
                                                          child: Text("홈페이지로 이동"),
                                                        )

                                                      ],
                                                    );
                                                  },
                                                );
                                              },
                                              child: Text("확인"),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  child: Text("확인"),
                                ),
                              ],
                            );
                          },
                        );
                      } else {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text("경고"),
                              content: Text(
                                "이유를 선택 또는 입력해주세요.",
                                style: TextStyle(fontFamily: 'Pretendard', fontSize: 16),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text("확인"),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Color(0xFF4E598C)),
                    ),
                    child: Text(
                      "완료",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  )

                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
