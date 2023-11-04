import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'noticeView.dart';

class NoticeMore extends StatefulWidget {
  const NoticeMore({super.key});

  @override
  State<NoticeMore> createState() => _NoticeMoreState();
}

class _NoticeMoreState extends State<NoticeMore> {
  final Stream<QuerySnapshot> noticeStream = FirebaseFirestore.instance.collection("notice").snapshots();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("공지사항"),backgroundColor: Color(0xFFFF8C42),),
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
              _notice()
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
