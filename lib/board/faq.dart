import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../firebase_options.dart';
import 'faqView.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(Faq());
}

class Faq extends StatefulWidget {
  const Faq({super.key});

  @override
  State<Faq> createState() => _FaqState();
}

class _FaqState extends State<Faq> {
  final TextEditingController _title = TextEditingController();
  final TextEditingController _content = TextEditingController();


  void _addFaq() async {
    if (_title.text.isNotEmpty && _content.text.isNotEmpty) {
      CollectionReference faq = FirebaseFirestore.instance.collection('faq');

      await faq.add({
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
      appBar: AppBar(title: Text("FAQ 등록"),backgroundColor: Color(0xFFFF8C42),),
      body: Container(
        padding: EdgeInsets.all(10),
        child: SingleChildScrollView(
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
                maxLines: 10,
                decoration: InputDecoration(
                  border: OutlineInputBorder(), // 테두리 스타일 지정
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addFaq,
                child: Text("게시물 추가"),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Color(0xFFFF8C42)), // 원하는 색상으로 변경
                ),
              ),
              SizedBox(height: 20),
              _listFaq()
            ],

          ),
        ),
      ),
    );
  }
  Widget _listFaq() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection("faq").orderBy("timestamp", descending: true).snapshots(),
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
                      builder: (context) => FaqView(document: doc),
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
