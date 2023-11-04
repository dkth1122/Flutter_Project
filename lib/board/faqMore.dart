import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'faqView.dart';
import 'noticeView.dart';

class FaqMore extends StatefulWidget {
  const FaqMore({super.key});

  @override
  State<FaqMore> createState() => _FaqMoreState();
}

class _FaqMoreState extends State<FaqMore> {
  final Stream<QuerySnapshot> faqStream = FirebaseFirestore.instance.collection("faq").snapshots();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("FAQ"),backgroundColor: Color(0xFFFF8C42),),
      body: SingleChildScrollView(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                Row(
                  children: [
                    Text("FAQ", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                  ],
                ),
                SizedBox(height: 10,),
                _faq()
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget _faq() {
    return StreamBuilder(
      stream: faqStream,
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
