import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FaqUpdate extends StatefulWidget {
  final DocumentSnapshot document;
  FaqUpdate({required this.document,});

  @override
  State<FaqUpdate> createState() => _FaqUpdateState();
}

class _FaqUpdateState extends State<FaqUpdate> {
  @override
  Widget build(BuildContext context) {
    final TextEditingController _title = TextEditingController();
    final TextEditingController _content = TextEditingController();

    Map<String, dynamic> data = widget.document.data() as Map<String, dynamic>;
    _title.text = data['title'];
    _content.text = data['content'];

    void _updateFaq(DocumentSnapshot doc) async {
      await doc.reference.update({
        'title': _title.text,
        'content': _content.text,
      });
      Navigator.of(context).pop();
    }

    return Scaffold(
      appBar: AppBar(title: Text("공지사항 업데이트"),),
      body: Container(
        child: Column(
          children: [
            TextField(
              controller: _title,
            ),
            TextFormField(
              controller: _content,
              maxLines: 15,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _updateFaq(widget.document);
                  },
                  child: Text("수정하기"),
                ),
                SizedBox(width: 10,),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("취소하기"),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
