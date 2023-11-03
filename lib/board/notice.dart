import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../firebase_options.dart';
import 'noticeView.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(Notice());
}

class Notice extends StatefulWidget {
  const Notice({super.key});

  @override
  State<Notice> createState() => _NoticeState();
}

class _NoticeState extends State<Notice> {
  final TextEditingController _title = TextEditingController();
  final TextEditingController _content = TextEditingController();


  void _addNotice() async {
    if (_title.text.isNotEmpty && _content.text.isNotEmpty) {
      CollectionReference notice = FirebaseFirestore.instance.collection('notice');

      await notice.add({
        'title': _title.text,
        'content': _content.text,
        'timestamp': FieldValue.serverTimestamp(),
      });

      _title.clear();
      _content.clear();
    } else {
      print("제목 또는 내용을 입력해주세요.");
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("공지사항 등록"),),
      body: Column(
        children: [
          TextField(
            controller: _title,
            decoration: InputDecoration(labelText: "제목"),
          ),
          SizedBox(height: 10),
          TextField(
            controller: _content,
            decoration: InputDecoration(labelText: "내용"),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _addNotice,
            child: Text("게시물 추가"),
          ),
          SizedBox(height: 20),
          _listNotice()
        ],

      ),
    );
  }
  Widget _listNotice() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection("notice").orderBy("timestamp", descending: true).snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snap) {
        if (!snap.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        return Expanded(
          child: ListView.builder(
            itemCount: snap.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot doc = snap.data!.docs[index];
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

              return ListTile(
                title: Text('${index + 1}. ${data['title']}'),
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
          ),
        );
      },
    );
  }
}
