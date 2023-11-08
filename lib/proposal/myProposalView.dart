import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MyProposalView extends StatefulWidget {
  final String user;
  final String proposalTitle;
  final String proposalContent;
  final int proposalPrice;


  const MyProposalView({
    required this.user,
    required this.proposalTitle,
    required this.proposalContent,
    required this.proposalPrice,
  });

  @override
  State<MyProposalView> createState() => _MyProposalViewState();
}

class _MyProposalViewState extends State<MyProposalView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.proposalTitle,
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
          IconButton(onPressed: (){
            //공유하기 기능
          }, icon: Icon(Icons.share)),
        ],
      ),
      body: ListView(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '제목: ${widget.proposalTitle}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Divider(),
                Text(
                  '설명: ${widget.proposalContent}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text('예산: ${widget.proposalPrice.toString()}원'),
                Text('프로젝트 시작일과 종료일은 채팅으로 협의하세요~'),
                Divider(color :Colors.grey),
                Text(
                  '제안한 전문가 목록',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildUserList(widget.proposalTitle),
                SizedBox(height: 20), // 여기에 새로운 위젯 추가
                // 다른 새로운 위젯 추가
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserList(String proposalTitle) {
    return FutureBuilder(
      future: FirebaseFirestore.instance
          .collection('accept')
          .where('aName', isEqualTo: proposalTitle)
          .get(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        if (snapshot.hasData) {
          return ListView.builder(
            shrinkWrap: true,
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var uid = snapshot.data!.docs[index]['uId'];
              return FutureBuilder(
                future: FirebaseFirestore.instance
                    .collection('userList')
                    .where('userId', isEqualTo: uid)
                    .get(),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }
                  if (userSnapshot.hasError) {
                    return Text('Error: ${userSnapshot.error}');
                  }
                  if (userSnapshot.hasData) {
                    var user = userSnapshot.data!.docs[0];
                    return ListTile(
                      leading: Container(
                        width: 50, // 원하는 가로 크기
                        height: 50, // 원하는 세로 크기
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle, // 사각형 모양으로 설정
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: NetworkImage(user['profileImageUrl']),
                          ),
                        ),
                      ),
                      title: Text(user['nick']),
                      subtitle: Text(user['userId']),
                      trailing: TextButton(
                        onPressed: () {
                          // 1:1 문의하기 기능
                        },
                        child: Text('1:1 문의하기'),
                      ),
                    );
                  }
                  return SizedBox(); // Placeholder for future state
                },
              );
            },
          );
        }
        return SizedBox(); // Placeholder for future state
      },
    );
  }

}
