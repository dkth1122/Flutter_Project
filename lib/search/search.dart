import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:project_flutter/search/searchSuccess.dart';
import 'package:provider/provider.dart';
import '../category/categoryProduct.dart';
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

  //추천 검색어 시작
  final TextEditingController _latelySearch = TextEditingController();
  List<String> searchKeywords = ["워드프레스","홈페이지","홈페이지 제작","카페24","크롤링","블로그","매크로","아임웹","애드센스","상세 패이지",];
  TextEditingController textFieldController = TextEditingController();
  void handleContainerTap(String keyword) {
    setState(() {
      _latelySearch.text = keyword;
    });
  }
  //추천 검색어 끝
  //카테고리
  List<String> imageCartegory = ['assets/category_ux.png','assets/category_web.png','assets/category_shop.png','assets/category_mobile.png','assets/category_program.png','assets/category_trend.png','assets/category_data.png','assets/category_rest.png',];
  List<String> categoryKeywords = ["UX기획", "웹", "커머스", "모바일","프로그램", "트렌드", "데이터", "기타"];


  void _addSearch() async {
    if (_latelySearch.text.isNotEmpty) {
      String user = "";
      UserModel um = Provider.of<UserModel>(context, listen: false);
      if (um.isLogin) {
        user = um.userId!;
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
    } else {
      print("로그인 안됨");
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          '검색',
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
      body: Container(
        padding: EdgeInsets.all(10),
        child: ListView(
          children: [
            SizedBox(height: 10,),
            TextField(
              controller: _latelySearch,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(10, 5, 5, 5),
                hintText: "검색어를 입력하세요",
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
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
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("경고"),
                            content: Text("검색어를 입력하세요."),
                            actions: <Widget>[
                              TextButton(
                                child: Text("확인"),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                ),

              ),
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
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("경고"),
                        content: Text("검색어를 입력하세요."),
                        actions: <Widget>[
                          TextButton(
                            child: Text("확인"),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: Text("검색"),
              style: ButtonStyle(
                minimumSize: MaterialStateProperty.all(Size(50, 35)),
                backgroundColor:MaterialStateProperty.all<Color>(Color(0xFFFCAF58)),
              ),
            ),
            if (um.isLogin)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                    child: Text(
                      "최근 검색어",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    )
                  ),
                  TextButton(
                    onPressed: (){
                      _deleteAllSearch();
                    },
                    child: Text("전체삭제")
                  )
                ],
              ),
            SizedBox(height: 20,),
            _listSearch(),
            SizedBox(height: 20,),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width: 10,),
                Text("추천 검색어", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
              ],
            ),
            SizedBox(height: 20,),
            recommend(),
            SizedBox(height: 20,),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width: 10,),
                Text("카테고리", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
              ],
            ),
            SizedBox(height: 20,),
            cartegory(),
            SizedBox(height: 20,),
          ],
        ),
      ),
    );
  }
  Widget _listSearch() {
    UserModel um = Provider.of<UserModel>(context, listen: false);
    if (um.isLogin) {
      String user = um.userId!;
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

  Widget recommend() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          children: searchKeywords.map((keyword) {
            return GestureDetector(
              onTap: () {
                handleContainerTap(keyword);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchSuccess(searchText: _latelySearch.text),
                  ),
                );
                _addSearch();
              },
              child: Container(
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  border: Border.all(
                    color: Colors.grey,
                    width: 0.6,
                  ),
                ),
                child: Text(keyword),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }


  Widget cartegory() {
    return Column(
      children: [
        Wrap(
          children: categoryKeywords.asMap().entries.map((entry) {
            final index = entry.key;
            final keyword = categoryKeywords[index];
            final imagePath = imageCartegory[index]; // 이미지 경로 가져오기

            return GestureDetector(
              onTap: () {
                // 클릭할 때 검색어 전달
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CategoryProduct(sendText: keyword), // 해당 검색어를 전달
                  ),
                );
              },
              child: Column(
                children: [
                  InkWell(
                    child: Container(
                      width: 80, // 넓이 80
                      height: 80, // 높이 80
                      padding: EdgeInsets.all(10),
                      margin: EdgeInsets.all(6),
                      child: Image.asset(imagePath), // 이미지 표시
                    ),
                  ),
                  Text(keyword) // 검색 키워드 출력
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
