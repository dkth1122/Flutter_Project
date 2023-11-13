import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_flutter/subBottomBar.dart';
import 'package:provider/provider.dart';

import '../chat/chat.dart';
import '../join/login_email.dart';
import '../join/userModel.dart';

class SearchPortfolioDetail extends StatefulWidget {
  final Map<String, dynamic> portfolioItem;
  final String user;

  SearchPortfolioDetail({required this.portfolioItem, required this.user});

  @override
  State<SearchPortfolioDetail> createState() => _SearchPortfolioDetailState();
}

class _SearchPortfolioDetailState extends State<SearchPortfolioDetail> {

  String sessionId = "";
  String chatUser = "";

  @override
  void initState() {
    super.initState();
    updatePortfolioCollection(widget.user);
  }

  @override
  Widget build(BuildContext context) {
    UserModel um = Provider.of<UserModel>(context, listen: false);

    if (um.isLogin) {
      sessionId = um.userId!;
    } else {
      sessionId = "";
    }
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.transparent,
            expandedHeight: 300,
            floating: false,
            pinned: false,
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context); // 뒤로가기 버튼 눌렀을 때 처리
              },
              color: const Color(0xFFFF8C42), // 뒤로가기 아이콘의 색상
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: GestureDetector(
                onTap: () {
                  // 이미지 클릭 시 추가 동작 수행
                },
                child: Image.network(
                  widget.portfolioItem['thumbnailUrl'],
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('작성자 : ${widget.user}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('조회수 : ${widget.portfolioItem['cnt']}', style: TextStyle(fontSize: 14)),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('카테고리 > ${widget.portfolioItem['category']}', style: TextStyle(fontSize: 16)),
                        IconButton(
                          onPressed: () async{
                            if (sessionId.isNotEmpty){
                              final QuerySnapshot result = await FirebaseFirestore
                                  .instance
                                  .collection('portfolioLike')
                                  .where('user', isEqualTo: sessionId)
                                  .where('portfoiloId', isEqualTo: widget.user)
                                  .where('title', isEqualTo:widget.portfolioItem['title'])
                                  .get();

                              if (result.docs.isNotEmpty){
                                final documentId = result.docs.first.id;
                                FirebaseFirestore.instance.collection('portfolioLike').doc(documentId).delete();

                                final portfolioQuery = await FirebaseFirestore.instance
                                    .collection('expert')
                                    .doc(widget.user)
                                    .collection("portfolio")
                                    .where('title', isEqualTo: widget.portfolioItem['title'])
                                    .get();

                                if (portfolioQuery.docs.isNotEmpty){
                                  final productDocId = portfolioQuery.docs.first.id;
                                  final currentLikeCount = portfolioQuery.docs.first['likeCnt'] ?? 0;

                                  int newLikeCount;

                                  // 좋아요를 취소했을 때
                                  if (result.docs.isNotEmpty) {
                                    newLikeCount = currentLikeCount - 1;
                                  } else {
                                    newLikeCount = currentLikeCount + 1;
                                  }
                                  // "likeCnt" 업데이트
                                  FirebaseFirestore.instance
                                      .collection('expert')
                                      .doc(widget.user)
                                      .collection("portfolio")
                                      .doc(productDocId)
                                      .set({
                                    'likeCnt': newLikeCount,
                                  }, SetOptions(merge: true));
                                }
                              }else{
                                FirebaseFirestore.instance.collection('portfolioLike').add({
                                  'user': sessionId,
                                  'portfoiloId': widget.user,
                                  'title' : widget.portfolioItem['title']
                                });
                                final portfolioQuery = await FirebaseFirestore.instance
                                    .collection('expert')
                                    .doc(widget.user)
                                    .collection("portfolio")
                                    .where('title', isEqualTo: widget.portfolioItem['title'])
                                    .get();
                                if (portfolioQuery.docs.isNotEmpty) {
                                  final portfolioDocId = portfolioQuery.docs.first.id;
                                  final currentLikeCount = portfolioQuery.docs.first['likeCnt'] ?? 0;

                                  // "likeCnt" 업데이트
                                  FirebaseFirestore.instance
                                      .collection('expert')
                                      .doc(widget.user)
                                      .collection("portfolio")
                                      .doc(portfolioDocId).update({
                                    'likeCnt': currentLikeCount + 1, // 좋아요를 추가했으므로 증가
                                  });
                                }
                              }
                            }
                          },
                          icon: sessionId.isNotEmpty
                            ? StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('portfolioLike')
                                .where('user', isEqualTo: sessionId)
                                .where('portfoiloId', isEqualTo: widget.user)
                                .where('title', isEqualTo:widget.portfolioItem['title'])
                                .snapshots(),
                            builder: (context, snapshot){
                              if (snapshot.hasData) {
                                if (snapshot.data!.docs.isNotEmpty) {
                                  return Icon(
                                    Icons.favorite,
                                    color: Colors.red,
                                    size: 30,
                                  );
                                }
                              }
                              return Icon(
                                Icons.favorite_border,
                                color: Colors.red,
                                size: 30,

                              );
                            },
                          )
                              :Container(),
                        )
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          (widget.portfolioItem['title']?.length ?? 0) > 15
                              ? widget.portfolioItem['title']!.substring(0, 15) + '\n' + widget.portfolioItem['title']!.substring(15)
                              : widget.portfolioItem['title'] ?? '제목 없음',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: (){
                            _toggleChat();
                          },
                          child: Text("1:1 문의하기"),
                          style: ElevatedButton.styleFrom(
                            primary: Color(0xFFFF8C42), // 직접 색상 지정
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 10),
                    Wrap(
                      children: [
                        Text(
                          '${widget.portfolioItem['hashtags']?.join(', ') ?? '없음'}',
                          style: TextStyle(color: Color(0xFFFF8C42), fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Divider(
                      height: 20,
                      color: Color(0xFFFF8C42),
                      thickness: 2,
                    ),
                    SizedBox(height: 10),
                    Text(
                      "설명",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      widget.portfolioItem['description'] ?? '설명 없음',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 20),
                    Text(
                      "참여 기간",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      '참여기간 : ${DateFormat('yyyy-MM-dd').format(widget.portfolioItem['startDate'].toDate())}'
                          '~ ${DateFormat('yyyy-MM-dd').format(widget.portfolioItem['endDate'].toDate())}',
                    ),
                    SizedBox(height: 20),
                    Text(
                      "고객사",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text('${widget.portfolioItem['customer']}', style: TextStyle(fontSize: 16)),
                    SizedBox(height: 20),
                    Text(
                      "업종",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text('${widget.portfolioItem['industry']}', style: TextStyle(fontSize: 16)),
                    SizedBox(height: 20),
                    Text(
                      "프로젝트 설명",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      widget.portfolioItem['portfolioDescription'] ?? '설명 없음',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 20),

                  ],
                ),
              )
            ]),
          ),
          SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1,
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 10.0,
            ),
            delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                if (widget.portfolioItem['subImageUrls'] != null && index < widget.portfolioItem['subImageUrls'].length) {
                  String imageUrl = widget.portfolioItem['subImageUrls'][index];
                  return GestureDetector(
                    onTap: () {
                      _showImageDialog(imageUrl);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(imageUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  );
                } else {
                  return Container();
                }
              },
              childCount: (widget.portfolioItem['subImageUrls'] ?? []).length,
            ),
          ),
        ],
      ),
      bottomNavigationBar: SubBottomBar(),
    );
  }

  _showImageDialog(String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Container(
            height: 500,
            width: 500,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("닫기"),
            )
          ],
        );
      },
    );
  }

  void updatePortfolioCollection(String user) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    String documentId = user;

    try {
      var querySnapshot = await firestore
          .collection('expert')
          .doc(documentId)
          .collection('portfolio')
          .where('title', isEqualTo: widget.portfolioItem['title'])
          .get();

      var doc = querySnapshot.docs.first;
      String title = doc['title'];

      if (title == widget.portfolioItem['title']) {
        int currentCount = doc['cnt'] ?? 0;
        int updatedCount = currentCount + 1;

        await doc.reference.update({
          'cnt': updatedCount,
        });

        // 갱신된 데이터를 활용하여 화면을 업데이트
        setState(() {
          widget.portfolioItem['cnt'] = updatedCount;
        });
      }
    } catch (e) {
      print('Error updating portfolio collection: $e');
    }
  }




  void _showLoginAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('알림'),
          content: Text('로그인 후 이용 가능한 서비스입니다.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('확인'),
            ),
          ],
        );
      },
    ).then((value) {
      if (value != null && value is bool && value) {
        // 로그인 페이지로 이동하는 코드 작성
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      }
    });
  }

  void _toggleChat() async {
    UserModel userModel = Provider.of<UserModel>(context, listen: false);
    if (!userModel.isLogin) {
      _showLoginAlert(context);
      return;
    }

    UserModel um = Provider.of<UserModel>(context, listen: false);


    if(widget.user == um.userId.toString()){
      // 본인에게 채팅을 보낼 때 스낵바를 표시
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("본인에게는 채팅을 보낼 수 없습니다."),
      ));
      return;
    }

    // user1과 user2 중에서 큰 값을 선택하여 user1에 할당
    String user1 = chatUser.compareTo(um.userId.toString()) > 0 ? chatUser : um.userId.toString();
    String user2 = chatUser.compareTo(um.userId.toString()) > 0 ? um.userId.toString() : widget.user;

    // Firestore 데이터베이스에 채팅방을 생성하는 함수
    Future<void> createChatRoom(String roomId, String user1, String user2) async {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      CollectionReference chatRoomsCollection = firestore.collection("chat");
      String roomId = '$user1' + '_' + '$user2';

      // 채팅방 ID를 사용하여 Firestore에 채팅방을 추가
      await chatRoomsCollection.doc(roomId).set({
        'user1': user1,
        'user2': user2,
        'roomId' : roomId, // 채팅방 생성 일시
      });
    }

    // 두 사용자 간의 채팅방 ID 확인 및 생성
    String getOrCreateChatRoomId(String user1, String user2) {
      String chatRoomId = '$user1' + '_' + '$user2';
      // Firestore에서 채팅방 ID를 확인하고, 존재하지 않으면 생성
      bool chatRoomExists = false; // Firestore에서 채팅방 존재 여부 확인하는 로직;
      if (!chatRoomExists) {
        // 채팅방이 없다면 생성
        createChatRoom(chatRoomId, user1, user2);
      }
      return chatRoomId;
    }

    void _showPurchaseAlert(BuildContext context) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('알림'),
            content: Text('로그인 후 이용 가능한 서비스입니다.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('확인'),
              ),
            ],
          );
        },
      );
    }

    //채팅방으로 이동
    void moveToChatRoom(BuildContext context, String chatRoomId) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => ChatApp(roomId: chatRoomId),
      ));
    }

    //메소드 실행
    String chatRoomId = getOrCreateChatRoomId(user1, user2);
    moveToChatRoom(context, chatRoomId);
  }


}
