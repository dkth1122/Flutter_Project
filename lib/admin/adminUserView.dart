import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../board/questionAnswerView.dart';

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
  late Stream<QuerySnapshot> questionStream;

  AdminUserViewPage({required this.user}) {
    questionStream = FirebaseFirestore.instance
        .collection("question")
        .where('user', isEqualTo: user.uId)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "사용자 상세 정보",
          style: TextStyle(
            color: Color(0xff424242),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Color(0xff424242),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildUserInfo(),
                SizedBox(height: 20),
                _buildBanButton(),
                SizedBox(height: 20),
                _buildCouponInfo(),
                SizedBox(height: 20),
                _buildCouponButton(context),
                SizedBox(height: 20),
                _buildQuestionInfo(context),
                SizedBox(height: 20),
                Text('탈퇴 여부: ${user.delYn}'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfo() {
    return Card(
      elevation: 4,
      child: Container(
        width: 500,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '고객 정보',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text('아이디: ${user.uId}'),
              Text('이름: ${user.name} (${user.nick})'),
              Text('이메일: ${user.email}'),
              Text('생일: ${user.birth}'),
              Text('가입일: ${user.cdatetime}'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBanButton() {
    return ElevatedButton(
      onPressed: () {
        // TODO: Implement ban/unban logic
      },
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(Color(0xFFFCAF58)),
      ),
      child: Text(user.banYn == 'N' ? '정지' : '해제'),
    );
  }

  Widget _buildCouponInfo() {
    return Card(
      elevation: 4,
      child: Container(
        width: 500,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '쿠폰 정보',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
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
                        return Column(
                          children: snapshot.data!.docs.map((couponDoc) {
                            final couponData =
                            couponDoc.data() as Map<String, dynamic>;
                            final cName = couponData['cName'];
                            final discount = couponData['discount'];
                            return Text('$cName($discount%)');
                          }).toList(),
                        );
                      } else {
                        return Text('No Data'); // 데이터가 없는 경우 처리
                      }
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCouponButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        // TODO: Implement coupon add logic
      },
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(Color(0xFFFCAF58)),
      ),
      child: Text('쿠폰 추가'),
    );
  }

  Widget _buildQuestionInfo(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '문의 정보',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            _questionAnswer(),
          ],
        ),
      ),
    );
  }

  Widget _questionAnswer() {
    return StreamBuilder(
      stream: questionStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snap) {
        if (!snap.hasData) {
          return Transform.scale(
            scale: 0.1,
            child: CircularProgressIndicator(strokeWidth: 20,),
          );
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: snap.data!.docs.length,
          itemBuilder: (context, index) {
            DocumentSnapshot doc = snap.data!.docs[index];
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

            return ListTile(
              title: Text('${data['title']}'),
              subtitle: Text("작성자 : ${data['user']}"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuestionAnswerView(document: doc),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}