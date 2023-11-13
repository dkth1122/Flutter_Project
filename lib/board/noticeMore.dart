import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../join/userModel.dart';
import 'notice.dart';
import 'noticeView.dart';

class NoticeMore extends StatefulWidget {
  const NoticeMore({super.key});

  @override
  State<NoticeMore> createState() => _NoticeMoreState();
}

class _NoticeMoreState extends State<NoticeMore> {
  String sessionId = "";
  final Stream<QuerySnapshot> noticeStream = FirebaseFirestore.instance.collection("notice").orderBy("timestamp", descending: true).snapshots();
  @override
  Widget build(BuildContext context) {
    UserModel um = Provider.of<UserModel>(context, listen: false);

    if (um.isLogin) {
      sessionId = um.userId!;
    } else {
      sessionId = "";
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          '공지사항',
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
        child: Container(
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(width: 10,),
                  Text("공지사항", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                ],
              ),
              _notice(),
              SizedBox(height: 10,),
              Visibility(
                visible: sessionId == "admin",
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Notice()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Color(0xFFFF8C42),
                  ),
                  child: Text('공지사항 등록하기'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _notice() {
    return StreamBuilder(
      stream: noticeStream,
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
              onTap: (){
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NoticeView(document: doc),
                    )
                );
              },
            );
          },
        );
      },
    );
  }
}
