import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminUserView {
  final String userId;
  final String uId;
  final String name;
  final String nick;
  final String email;
  final String birth;
  final String cdatetime;
  final String banYn;
  final String delYn;
  final String status;


  AdminUserView(
      this.userId,
      this.uId,
      this.name,
      this.nick,
      this.email,
      this.birth,
      this.cdatetime,
      this.banYn,
      this.delYn,
      this.status,
      );
}

class AdminUserViewPage extends StatelessWidget {
  final AdminUserView user;

  AdminUserViewPage({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('사용자 상세 정보'),
        backgroundColor: Color(0xFF4E598C),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                '고객 정보',
                style: TextStyle(
                  fontSize: 30,
                ),
              ),
              Text('아이디 : ${user.uId}'),
              Text('이름 : ${user.name} (${user.nick})'),
              Text('이메일 : ${user.email}'),
              Text('생일 : ${user.birth}'),
              Text('가입일 : ${user.cdatetime}'),
              ElevatedButton(
                child: Text(user.banYn == 'N' ? '정지' : '해제'),
                onPressed: () {
                  if (user.banYn == 'N') {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        String bReason = '';
                        return AlertDialog(
                          title: Text('정지 사유 입력'),
                          content: TextField(
                            onChanged: (value) {
                              bReason = value.trim();
                            },
                          ),
                          actions: <Widget>[
                            TextButton(
                              child: Text('확인'),
                              onPressed: () {
                                Navigator.of(context).pop();
                                if (bReason.isEmpty) {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text('정지 사유 입력'),
                                        content: Text('정지 사유를 입력하세요.'),
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
                                } else {
                                  String updatedBanYn = 'Y';
                                  Timestamp currentTime = Timestamp.now();

                                  FirebaseFirestore.instance
                                      .collection('userList')
                                      .doc(user.userId)
                                      .update({'banYn': updatedBanYn});

                                  FirebaseFirestore.instance.collection('ban').add({
                                    'uId': user.uId,
                                    'bdate': currentTime,
                                    'bReason': bReason,
                                  });

                                  Navigator.of(context).pop();
                                }
                              },
                            ),
                            TextButton(
                              child: Text('취소'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  } else {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('밴이 해제되었습니다.'),
                          actions: <Widget>[
                            TextButton(
                              child: Text('확인'),
                              onPressed: () {
                                Navigator.of(context).pop();
                                String updatedBanYn = 'N';

                                FirebaseFirestore.instance
                                    .collection('userList')
                                    .doc(user.userId)
                                    .update({'banYn': updatedBanYn});

                                FirebaseFirestore.instance
                                    .collection('ban')
                                    .where('uId', isEqualTo: user.uId)
                                    .get()
                                    .then((snapshot) {
                                  for (DocumentSnapshot doc in snapshot.docs) {
                                    doc.reference.delete();
                                  }
                                });

                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Color(0xFFFCAF58)),
                ),
              ),
              Divider(color :Colors.grey),
              Text(
                '쿠폰 정보',
                style: TextStyle(
                  fontSize: 30,
                ),
              ),
              FutureBuilder<QuerySnapshot?>(
                future: FirebaseFirestore.instance
                    .collection('coupon')
                    .where('userId', isEqualTo: user.uId)
                    .get(),
                builder: (BuildContext context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else {
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      if (snapshot.data != null) {
                        List<String> coupons = [];
                        snapshot.data!.docs.forEach((couponDoc) {
                          final couponData = couponDoc.data() as Map<String, dynamic>?;
                          if (couponData != null) {
                            coupons.add(couponData['couponInfo'].toString());
                          }
                        });

                        return Column(
                          children: snapshot.data!.docs.map((couponDoc) {
                            final couponData = couponDoc.data() as Map<String, dynamic>;
                            final cName = couponData['cName'];
                            final discount = couponData['discount'];
                            return Text('쿠폰: $cName($discount%)');
                          }).toList(),
                        );

                      } else {
                        return Text('No Data'); // 데이터가 없는 경우 처리
                      }
                    }
                  }
                },
              ),

              ElevatedButton(
                onPressed: () {
                  String addCName = ''; // 초기화
                  int addDiscount = 10; // 기본 할인율을 10으로 설정

                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return StatefulBuilder(
                        builder: (BuildContext context, StateSetter setState) {
                          return AlertDialog(
                            title: Text('쿠폰 추가'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextField(
                                  onChanged: (value) {
                                    setState(() {
                                      addCName = value.trim(); // 트림 적용
                                    });
                                  },
                                  decoration: InputDecoration(labelText: '쿠폰 이름'),
                                ),
                                DropdownButton<int>(
                                  value: addDiscount,
                                  items: [10, 20, 30, 40, 50].map((discount) {
                                    return DropdownMenuItem<int>(
                                      value: discount,
                                      child: Text('$discount%'),
                                    );
                                  }).toList(),
                                  onChanged: (int? value) {
                                    if (value != null) {
                                      setState(() {
                                        addDiscount = value;
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),
                            actions: <Widget>[
                              TextButton(
                                child: Text('추가'),
                                onPressed: () {
                                  if (addCName == null || addCName.isEmpty) {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text('쿠폰 이름 입력'),
                                          content: Text('쿠폰 이름을 입력하세요.'),
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
                                  } else {
                                    // Firestore에 새로운 쿠폰 추가 로직
                                    FirebaseFirestore.instance.collection('coupon').add({
                                      'cName': addCName,
                                      'discount': addDiscount,
                                      'userId': user.uId,
                                    });
                                    Navigator.of(context).pop();
                                    Navigator.of(context).pop();
                                  }
                                },
                              ),
                              TextButton(
                                child: Text('취소'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  );
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Color(0xFFFCAF58)),
                ),
                child: Text('쿠폰 추가'),
              ),
              Divider(color :Colors.grey),
              Text(
                '문의 정보',
                style: TextStyle(
                  fontSize: 30,
                ),
              ),
              Divider(color :Colors.grey),
              Text('탈퇴 여부: ${user.delYn}'),
            ],
          ),
        ),
      ),
    );
  }
}