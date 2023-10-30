import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../firebase_options.dart';
import '../join/userModel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(Search());
}


class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final TextEditingController _latelySearch = TextEditingController();


  void _addSearch() async {
    if (_latelySearch.text.isNotEmpty) {
      String user = "";
      UserModel um = Provider.of<UserModel>(context, listen: false);
      if (um.isLogin) {
        user = um.userId!;
        print(user);
      } else {
        user = "없음";
        print("로그인 안됨");
      }
      if (user != "") {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('userList')
            .where('userId', isEqualTo: user)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          DocumentReference userDocRef = querySnapshot.docs.first.reference;

          // 'userList' 컬렉션 내의 'latelySearch' 컬렉션에 데이터 추가
          await userDocRef.collection('latelySearch').add({
            'latelySearch': _latelySearch.text,
            'timestamp': FieldValue.serverTimestamp(),

          });
          _latelySearch.clear();
        }
      }
    } else {
      print('검색어를 입력하세요.');
    }
  }


  @override
  Widget build(BuildContext context) {
    String user = "";
    UserModel um = Provider.of<UserModel>(context, listen: false);
    if (um.isLogin) {
      user = um.userId!;
      print(user);
    } else {
      user = "없음";
      print("로그인 안됨");
    }
    return Scaffold(
      appBar: AppBar(title: Text("검색"),),
      body: Column(
        children: [
          TextField(
            controller: _latelySearch,
          ),
          ElevatedButton(
            onPressed: _addSearch,
            child: Text("검색"),
          ),
          if (um.isLogin) // Display only if user is logged in
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text("최근 검색어", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
              ],
            ),
          SizedBox(height: 10,),
          _listSearch(),
          Text(user)
        ],
      ),
    );
  }

  Widget _listSearch() {
    UserModel um = Provider.of<UserModel>(context, listen: false);
    if (um.isLogin) {
      String user = um.userId!;
      print(user);
      final PageController controller =
      PageController(initialPage: 4, viewportFraction: 0.3);
      return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('userList')
            .where('userId', isEqualTo: user)
            .limit(1)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snap) {
          if (!snap.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          if (snap.data!.docs.isNotEmpty) {
            String docId = snap.data!.docs.first.id;
            return StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('userList')
                  .doc(docId)
                  .collection('latelySearch')
                  .orderBy("timestamp", descending: true)
                  .snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> latelySearchSnap) {

                return Container(
                  height: 50, // 높이를 50으로 고정
                  child: ListView.builder(
                    controller: controller,
                    itemCount: latelySearchSnap.data!.docs.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      DocumentSnapshot doc = latelySearchSnap.data!.docs[index];
                      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

                      return Container(
                        margin: EdgeInsets.symmetric(horizontal: 5.0),
                        color: Color.fromRGBO(225, 225, 225, 0.7019607843137254),
                        child: Row(
                          children: [
                            TextButton(
                              child: Text('${data['latelySearch']}', style: TextStyle(color: Colors.black, fontSize: 14),),
                              onPressed: (){
                                setState(() {
                                  _latelySearch.text = data['latelySearch'];
                                });
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.clear), // 'X' 아이콘 사용
                              color: Colors.grey, // 아이콘 색상 설정
                              onPressed: () {},
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            );
          } else {
            return Container();
          }
        },
      );
    } else {
      return Container();
    }
  }
}
