import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../firebase_options.dart';
import '../join/userModel.dart';
import 'myQuestionView.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyQuestion());
}


class MyQuestion extends StatefulWidget {
  const MyQuestion({super.key});

  @override
  State<MyQuestion> createState() => _MyQuestionState();
}

class _MyQuestionState extends State<MyQuestion> {

  String sessionId = "";

  @override
  Widget build(BuildContext context) {
    UserModel um = Provider.of<UserModel>(context, listen: false);

    if (um.isLogin) {
      sessionId = um.userId!;
      print(sessionId);
    } else {
      sessionId = "";
    }
    return Scaffold(
      appBar: AppBar(title: Text("내 문의"),),
      body: ListView(
        children: [
          _myQuestion()
        ],
      ),
    );
  }
  Widget _myQuestion() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection("question")
          .where('user', isEqualTo: sessionId)
          .snapshots(),
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
              title: Text('${index + 1}. ${data['title']}'),
              subtitle: Text('작성일 : ${data['timestamp'].toDate().toString()}'),
              onTap: (){
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MyQuestionView(document: doc),
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
