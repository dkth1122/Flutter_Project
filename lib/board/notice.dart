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

  final _scrollController = ScrollController(); // 스크롤 컨트롤러 추가

  @override
  void dispose() {
    _scrollController.dispose(); // 스크롤 컨트롤러 해제
    super.dispose();
  }

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
      appBar: AppBar(title: Text("공지사항 등록"),backgroundColor: Color(0xFFFF8C42),),
      body: Container(
        padding: EdgeInsets.all(10),
        child: SingleChildScrollView( // SingleChildScrollView로 감싸서 스크롤 가능하도록 만듭니다.
          controller: _scrollController, // 스크롤 컨트롤러 추가
          child: Center(
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
                  style: TextStyle(fontSize: 20),
                  maxLines: 15,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _addNotice,
                  child: Text("게시물 추가"),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Color(0xFFFF8C42)),
                  ),
                ),
                SizedBox(height: 20),
                _listNotice()
              ],
            ),
          ),
        ),
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

        return ListView.builder(
          physics: NeverScrollableScrollPhysics(), // 스크롤 금지
          shrinkWrap: true,
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
