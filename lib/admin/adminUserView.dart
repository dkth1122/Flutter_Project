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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text('회원 번호 : ${user.userId}'),
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
                            bReason = value;
                          },
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: Text('확인'),
                            onPressed: () {
                              Navigator.of(context).pop();
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
            ),
            Text('삭제여부: ${user.delYn}'),
          ],
        ),
      ),
    );
  }
}