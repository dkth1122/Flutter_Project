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
            onPressed: _addFaq,
            child: Text("게시물 추가"),
          ),
          SizedBox(height: 20),
          _listFaq()
        ],

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
                        builder: (context) => FaqView(document: doc),
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
