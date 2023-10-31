import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:project_flutter/search/searchSuccess.dart';
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

  void _deleteAllSearch() async {
    UserModel um = Provider.of<UserModel>(context, listen: false);
    if (um.isLogin) {
      String user = um.userId!;
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('userList')
          .where('userId', isEqualTo: user)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        String docId = querySnapshot.docs.first.id;
        QuerySnapshot latelySearchSnapshot = await FirebaseFirestore.instance
            .collection('userList')
            .doc(docId)
            .collection('latelySearch')
            .get();

        for (DocumentSnapshot doc in latelySearchSnapshot.docs) {
          await doc.reference.delete();
        }
      }
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
      print("로그인 안됨");
    }
    return Scaffold(
      appBar: AppBar(title: Text("검색"),),
      body: Column(
        children: [
          TextField(
            controller: _latelySearch,
            autofocus: true,
          ),
          ElevatedButton(
            onPressed: () {
              if (_latelySearch.text.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchSuccess(searchText: _latelySearch.text),
                  ),
                );
                _addSearch();
              } else {
                // 빈 값일 때 처리할 내용 추가 (예: 경고 또는 아무 작업 없음)
              }
            },
            child: Text("검색"),
          ),
          if (um.isLogin) // Display only if user is logged in
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("최근 검색어", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                TextButton(
                  onPressed: (){
                    _deleteAllSearch();
                  },
                  child: Text("전체삭제")
                )
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
          if (!snap.hasData || snap.data == null) {
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
                if (latelySearchSnap.data != null && latelySearchSnap.data!.docs.isNotEmpty) {
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
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SearchSuccess(searchText: _latelySearch.text),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.clear), // 'X' 아이콘 사용
                                color: Colors.grey, // 아이콘 색상 설정
                                onPressed: (){
                                  doc.reference.delete();
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                } else {
                  return Container(); // .docs가 null이거나 비어있는 경우
                }
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
