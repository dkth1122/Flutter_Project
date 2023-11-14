import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:project_flutter/board/noticeView.dart';
import 'package:project_flutter/board/myQuestion.dart';
import 'package:project_flutter/customer/question.dart';
import 'package:provider/provider.dart';

import '../board/faqMore.dart';
import '../board/faqView.dart';
import '../board/noticeMore.dart';
import '../firebase_options.dart';
import '../join/userModel.dart';
import '../subBottomBar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(UserCustomer());
}
class UserCustomer extends StatefulWidget {
  const UserCustomer({super.key});

  @override
  State<UserCustomer> createState() => _UserCustomerState();
}

class _UserCustomerState extends State<UserCustomer> {
  final Stream<QuerySnapshot> noticeStream = FirebaseFirestore.instance.collection("notice").orderBy("timestamp", descending: true).limit(3).snapshots();
  final Stream<QuerySnapshot> faqStream = FirebaseFirestore.instance.collection("faq").orderBy("timestamp", descending: true).limit(5).snapshots();
  String sessionId = "";
  @override
  Widget build(BuildContext context) {

    UserModel um = Provider.of<UserModel>(context, listen: false);

    if (um.isLogin) {
      sessionId = um.userId!;
    } else {
      sessionId = "";
    }


    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          '고객센터',
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
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(width: 10,),
                  Text("공지사항", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                  SizedBox(width: 10,),
                  TextButton(
                    onPressed: (){
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NoticeMore(),
                          )
                      );
                    },
                    child: Text("더보기")
                  )
                ],
              ),
              _notice(),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(width: 10,),
                  Text("FAQ", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                  SizedBox(width: 10,),
                  TextButton(
                      onPressed: (){
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FaqMore(),
                            )
                        );
                      },
                      child: Text("더보기")
                  )
                ],
              ),
              _faq(),
              Visibility(
                visible: sessionId != "",
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Question(),
                          ),
                        );
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(Color(0xFFFF8C42)), // 원하는 색상으로 변경
                      ),
                      child: Text("1:1 문의하기"),
                    ),
                    SizedBox(width: 10,),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MyQuestion(),
                          ),
                        );
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(Color(0xFFFF8C42)), // 원하는 색상으로 변경
                      ),
                      child: Text("내 문의 보기"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SubBottomBar(),
    );
  }
  Widget _notice() {
    return StreamBuilder(
      stream: noticeStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snap) {
        if (!snap.hasData) {
          return Transform.scale(
            scale: 0.1,
            child: CircularProgressIndicator(strokeWidth: 10,),
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
  Widget _faq() {
    return StreamBuilder(
      stream: faqStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snap) {
        if (!snap.hasData) {
          return Transform.scale(
            scale: 0.1,
            child: CircularProgressIndicator(strokeWidth: 10,),
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
