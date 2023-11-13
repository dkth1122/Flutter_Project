import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NoticeUpdate extends StatefulWidget {
  final DocumentSnapshot document;
  NoticeUpdate({required this.document,});

  @override
  State<NoticeUpdate> createState() => _NoticeUpdateState();
}

class _NoticeUpdateState extends State<NoticeUpdate> {
  @override
  Widget build(BuildContext context) {
    final TextEditingController _title = TextEditingController();
    final TextEditingController _content = TextEditingController();

    Map<String, dynamic> data = widget.document.data() as Map<String, dynamic>;
    _title.text = data['title'];
    _content.text = data['content'];

    void _updateNotice(DocumentSnapshot doc) async {
      await doc.reference.update({
        'title': _title.text,
        'content': _content.text,
      });
      Navigator.of(context).pop();
    }
    final _scrollController = ScrollController(); // 스크롤 컨트롤러 추가


    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          '공지사항 수정하기',
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
      body: Container(
        padding: EdgeInsets.all(10),
        child: SingleChildScrollView(
          controller: _scrollController, // 스크롤 컨트롤러 추가
          child: Column(
            children: [
              Row(
                children: [
                  Text("제목", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                ],
              ),
              SizedBox(height: 10,),
              TextField(
                controller: _title,
              ),
              SizedBox(height: 10,),
              Row(
                children: [
                  Text("내용", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                ],
              ),
              SizedBox(height: 10,),
              TextFormField(
                controller: _content,
                maxLines: 15,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _updateNotice(widget.document);
                    },
                    child: Text("수정하기"),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Color(0xFFFF8C42)),
                    ),
                  ),
                  SizedBox(width: 10,),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("취소하기"),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Color(0xFFFF8C42)),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10,),
            ],
          ),
        ),
      ),
    );
  }
}
