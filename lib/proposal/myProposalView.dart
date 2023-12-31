import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_flutter/subBottomBar.dart';
import 'package:provider/provider.dart';

import '../chat/chat.dart';
import '../join/login_email.dart';
import '../join/userModel.dart';

class MyProposalView extends StatefulWidget {
  final String user;
  final String proposalTitle;
  final String proposalContent;
  final int proposalPrice;
  final String proposalDel;


  const MyProposalView({
    required this.user,
    required this.proposalTitle,
    required this.proposalContent,
    required this.proposalPrice,
    required this.proposalDel,
  });

  @override
  State<MyProposalView> createState() => _MyProposalViewState();
}

class _MyProposalViewState extends State<MyProposalView> {
  get chatUser => null;
  bool _isDealEnded = false;


  void _toggleChat(String chatUser) async {
    UserModel userModel = Provider.of<UserModel>(context, listen: false);

    String user = userModel.isLogin ? userModel.userId! : "없음";
    if (!userModel.isLogin) {
      _showLoginAlert(context);
      return;
    }

    UserModel um = Provider.of<UserModel>(context, listen: false);

    // user1과 user2 중에서 큰 값을 선택하여 user1에 할당
    String user1 = chatUser.compareTo(um.userId.toString()) > 0 ? chatUser : um.userId.toString();
    String user2 = chatUser.compareTo(um.userId.toString()) > 0 ? um.userId.toString() : chatUser;

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

  void _showEndDealDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('거래 종료'),
          content: Text('정말로 거래를 종료하시겠습니까? 종료를 한다면 다시 되돌리지 못합니다.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // 닫기 버튼
              },
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () {
                _endDeal(); // 거래 종료 함수 호출
                Navigator.pop(context); // 닫기 버튼
              },
              child: Text('확인'),
            ),
          ],
        );
      },
    );
  }

  void _endDeal() {
    // Firestore에서 해당 proposal 업데이트
    FirebaseFirestore.instance
        .collection('proposal')
        .where('title', isEqualTo: widget.proposalTitle)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        FirebaseFirestore.instance
            .collection('proposal')
            .doc(doc.id)
            .update({'delYn': 'Y'});
      });
      setState(() {
        _isDealEnded = true;
      });
    }).catchError((error) {
      print('Error updating document: $error');
      // 에러 핸들링
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
         "프로젝트 상세보기",
          style: TextStyle(color: Color(0xff424242), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1.0,
        iconTheme: IconThemeData(color: Color(0xff424242),),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(onPressed: (){
            //공유하기 기능
          }, icon: Icon(Icons.share)),
        ],
      ),
      body: Container(
        margin: EdgeInsets.all(16),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white, // 배경색 설정
          borderRadius: BorderRadius.circular(10), // 보더 둥글게 설정
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3), // 그림자 효과
            ),
          ],
          border: Border.all(
            color: Color(0xFFFF8C42), // 보더 컬러 설정
          ),

        ),
        child: ListView(
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("프로젝트 제목",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      decoration: widget.proposalDel == 'Y' ? TextDecoration.lineThrough : null,
                      color: widget.proposalDel == 'Y'? Colors.grey : Colors.black,
                    ),),
                  SizedBox(height: 8,),
                  Text(
                    widget.proposalTitle,
                    style: TextStyle(
                      fontSize: 24,
                      decoration: widget.proposalDel == 'Y' ? TextDecoration.lineThrough : null,
                      color: widget.proposalDel == 'Y'? Colors.grey : Colors.black,
                    ),
                  ),
                  Divider(),
                  Text("설명",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      decoration: widget.proposalDel == 'Y' ? TextDecoration.lineThrough : null,
                      color: widget.proposalDel == 'Y'? Colors.grey : Colors.black,
                    ),),
                  SizedBox(height: 8,),
                  Text(
                    widget.proposalContent,
                    style: TextStyle(
                      fontSize: 24,
                      decoration: widget.proposalDel == 'Y' ? TextDecoration.lineThrough : null,
                      color: widget.proposalDel == 'Y'? Colors.grey : Colors.black,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text("예산",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      decoration: widget.proposalDel == 'Y' ? TextDecoration.lineThrough : null,
                      color: widget.proposalDel == 'Y'? Colors.grey : Colors.black,
                    ),),
                  SizedBox(height: 8),
                  Text(
                    '${NumberFormat('#,###').format(widget.proposalPrice)}원',
                    style: TextStyle(
                      fontSize: 24,
                      decoration: widget.proposalDel == 'Y' ? TextDecoration.lineThrough : null,
                      color: widget.proposalDel == 'Y' ? Colors.grey : Colors.black,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text('프로젝트 시작일과 종료일은 채팅으로 협의하세요~'),
                  TextButton(
                    onPressed: () {
                      if (widget.proposalDel != 'Y') {
                        _showEndDealDialog();
                      }
                    },
                    child: Text(
                      widget.proposalDel == 'Y' ? '거래 종료됨' : '거래종료하기',
                      style: TextStyle(
                        color: Colors.red[200],
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Divider(color :Colors.grey),
                  SizedBox(height: 10),
                  Center(
                    child: Text(
                      '제안한 전문가 목록',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildUserList(widget.proposalTitle),
                  SizedBox(height: 20), // 여기에 새로운 위젯 추가
                  // 다른 새로운 위젯 추가
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SubBottomBar(),
    );
  }

  Widget _buildUserList(String proposalTitle) {
    return FutureBuilder(
      future: FirebaseFirestore.instance
          .collection('accept')
          .where('aName', isEqualTo: proposalTitle)
          .get(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        if (snapshot.hasData && snapshot.data!.docs.length > 0) {
          return Column(
            children: [
              Text(
                '1:1문의를 원하시면 스와이프하세요!',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.red,
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  var uid = snapshot.data!.docs[index]['uId'];
                  return FutureBuilder(
                    future: FirebaseFirestore.instance
                        .collection('userList')
                        .where('userId', isEqualTo: uid)
                        .get(),
                    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> userSnapshot) {
                      if (userSnapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      }
                      if (userSnapshot.hasError) {
                        return Text('Error: ${userSnapshot.error}');
                      }
                      if (userSnapshot.hasData) {
                        var user = userSnapshot.data!.docs[0];
                        var uid = user['userId'];
                        return Dismissible(
                          key: UniqueKey(), // 고유한 키로 설정
                          background: Container(
                            color:Color(0xFFFF8C42), // 스와이프 배경 색상
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.only(left: 20),
                            child: Icon(
                              Icons.chat, // 삭제 아이콘 또는 원하는 내용으로 대체
                              color: Colors.white,
                            ),
                          ),

                          onDismissed: (direction) {
                            if (direction == DismissDirection.startToEnd) {
                              // 스와이프 방향이 오른쪽에서 왼쪽으로 이동할 때만 수행
                              setState(() {
                                _toggleChat(uid);

                              });
                            }
                          },
                          direction: DismissDirection.startToEnd, // 오른쪽에서 왼쪽으로 스와이프 비활성화
                          child: ListTile(
                            leading: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: NetworkImage(user['profileImageUrl']),
                                ),
                              ),
                            ),
                            title: Text(user['nick']),
                            subtitle: Text(user['userId']),
                            trailing: TextButton(
                              onPressed: () {
                                _toggleChat(uid);
                              },
                              child: Text("1:1문의하기>>", style: TextStyle(color: Color(0xFFFF8C42), fontWeight: FontWeight.bold),),
                            ),
                          ),
                        );
                      }
                      return SizedBox(); // Placeholder for future state
                    },
                  );
                },
              ),
            ],
          );
        }
        return SizedBox(); // Placeholder for future state
      },
    );
  }



}

