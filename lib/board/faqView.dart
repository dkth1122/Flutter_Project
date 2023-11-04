import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../join/userModel.dart';
import 'faqUpdate.dart';

class FaqView extends StatefulWidget {
  final DocumentSnapshot document;
  FaqView({required this.document});


  @override
  State<FaqView> createState() => _FaqViewState();
}

class _FaqViewState extends State<FaqView> {
  String sessionId = "";

  @override
  Widget build(BuildContext context) {
    UserModel um = Provider.of<UserModel>(context, listen: false);

    if (um.isLogin) {
      sessionId = um.userId!;
    } else {
      sessionId = "";
    }

    Map<String, dynamic> data = widget.document.data() as Map<String, dynamic>;
    return Scaffold(
      appBar: AppBar(title: Text("FAQ View"),backgroundColor: Color(0xFFFF8C42),),
      body: Container(
        padding: EdgeInsets.all(10),
        child: ListView(
          children: [
            Text(
              '${data['title']}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10,),
            Text('작성일 : ${data['timestamp'].toDate().toString()}'),
            SizedBox(height: 10,),
            Text( '내용 : ${data['content']}',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            SizedBox(height: 10,),
            Visibility(
              visible: sessionId == "admin",
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FaqUpdate(document: widget.document),
                        ),
                      );
                    },
                    child: Text("FAQ 수정하기"),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Color(0xFFFF8C42)),
                    ),
                  ),
                  SizedBox(width: 10,),
                  ElevatedButton(
                    onPressed: (){
                      _showDeleteDialog(widget.document);
                    },
                    child: Text("FAQ 삭제하기"),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Color(0xFFFF8C42)), // 원하는 색상으로 변경
                    ),
                  ),
                ],
              ),
            )

          ],
        ),
      ),
    );
  }
  Future<void> _showDeleteDialog(DocumentSnapshot doc) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('삭제'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                Text('이 글을 삭제하시겠습니까?'),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('취소'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              onPressed: () {
                doc.reference.delete();
                int count = 0;
                Navigator.popUntil(context, (route) {
                  if (count == 2) {
                    return true;
                  }
                  count++;
                  return false;
                });
              },
              child: Text("삭제"),
            ),
          ],
        );
      },
    );
  }
}
