import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../join/userModel.dart';

class ChatResponsePage extends StatefulWidget {
  final String roomId;

  ChatResponsePage({required this.roomId});

  @override
  _ChatResponsePageState createState() => _ChatResponsePageState(roomId: roomId);
}

class _ChatResponsePageState extends State<ChatResponsePage> {
  final String roomId;
  _ChatResponsePageState({required this.roomId});

  String? selectedResponse;
  List<String> possibleResponses = [
    '전문가 지금 응답 가능한가요?',
    '전문가가 야간 응답이 가능한가요?',
    '전문가는 휴가 중인가요?',
  ];

  bool isNightResponseEnabled = false;
  bool isOnVacation = false;
  bool isResponseEnabled = false;
  DateTime vacationStartDate = DateTime.now();
  DateTime vacationEndDate = DateTime.now();

  List<ChatMessage> messages = [];
  String user = "";
  String otherUser = "";
  bool flg = false;

  @override
  void initState() {
    super.initState();

    UserModel um = Provider.of<UserModel>(context, listen: false);
    if (um.isLogin) {
      user = um.userId!;
    } else {
      user = "없음";
      print("로그인 안됨");
    }

    _parseRoomId(roomId);
    print("상대 유저 ======> $otherUser");
  }

  void _parseRoomId(String roomId) {
    List<String> users = roomId.split("_");

    if (users.length == 2) {
      String user1 = users[0];
      String user2 = users[1];

      if (user1 != user) {
        otherUser = user1;
      } else if (user2 != user) {
        otherUser = user2;
      }
      _fetchMessageResponse(otherUser);
    }
  }

  Future<void> _fetchMessageResponse(String otherUser) async {
    final firestore = FirebaseFirestore.instance;
    final documentSnapshot = await firestore.collection("messageResponse").doc(otherUser).get();

    if (documentSnapshot != null && documentSnapshot.exists) {
      final data = documentSnapshot.data() as Map<String, dynamic>;

      isNightResponseEnabled = data['isNightResponseEnabled'];
      isOnVacation = data['isOnVacation'];
      isResponseEnabled = data['isResponseEnabled'];
      vacationStartDate = (data['vacationStartDate'] as Timestamp).toDate();
      vacationEndDate = (data['vacationEndDate'] as Timestamp).toDate();

      setState(() {
        flg = false;
      });
      print("flg 지금 ============> $flg");
    } else {
      setState(() {
        flg = true;
      });
      print("flg 지금 ============> $flg");
      print("문서가 Firestore에 존재하지 않습니다.");
    }

    _updateResponse();
  }

  void _updateResponse() {
    if (selectedResponse != null) {
      _addMessage("사용자", selectedResponse!);
    }

    String userQuestion = selectedResponse ?? "";
    String botResponse = getResponseForQuestion(userQuestion);
    _addMessage("챗봇", botResponse);
  }

  String getResponseForQuestion(String question) {
    if (question.contains("야간 응답")) {
      if (isNightResponseEnabled) {
        return "전문가는 현재 23:00~08:00(KST) 동안 야간 응답이 가능합니다.";
      } else {
        return "전문가는 현재 야간 응답이 불가능 합니다.";
      }
    } else if (question.contains("휴가 중")) {
      if (isOnVacation) {
        return "전문가는 ${_formatDate(vacationStartDate)}부터 ${_formatDate(vacationEndDate)}까지 휴가 중입니다.";
      } else {
        return "현재 전문가는 휴가 중이 아닙니다.";
      }
    } else if (question.contains("응답 가능")) {
      if (isResponseEnabled) {
        return "전문가는 현재 30분 내로 응답 가능합니다.";
      } else {
        return "전문가는 현재 30분 내로 응답할 수 없습니다.";
      }
    }
    return "안녕하세요! 무엇을 도와드릴까요?";
  }

  void _addMessage(String sender, String text) {
    final newMessage = ChatMessage(sender: sender, text: text);
    setState(() {
      messages.add(newMessage);
    });
  }

  String _formatDate(DateTime date) {
    return '${date.year}년 ${date.month}월 ${date.day}일';
  }

  Widget _buildNoResponseMessage() {
    return Center(
      child: Text(
        '해당 전문가는 메시지 응답 설정을 하지 않았습니다.',
        style: TextStyle(fontSize: 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('메시지 응답 페이지'),
        backgroundColor: Color(0xFFFCAF58),
      ),
      body: Column(
        children: [
          SizedBox(height: 20,),
          Expanded(
            child: flg
                ? _buildNoResponseMessage()
                : ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return message.sender == "챗봇"
                    ? _buildBotMessage(message.text)
                    : _buildUserMessage(message.text);
              },
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: flg
                ? []
                : possibleResponses.map((response) {
              return ResponseButton(
                response: response,
                isSelected: response == selectedResponse,
                onPressed: () {
                  setState(() {
                    selectedResponse = response;
                    _processUserResponse(response);
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _processUserResponse(String selectedResponse) {
    _updateResponse();
  }

  Widget _buildBotMessage(String text) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Color(0xFFFF8C42),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Text(
              text,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserMessage(String text) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            padding: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Color(0xFF4E598C),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
            ),
            child: Text(
              text,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class ResponseButton extends StatelessWidget {
  final String response;
  final bool isSelected;
  final VoidCallback onPressed;

  ResponseButton({
    required this.response,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(
          isSelected ? Color(0xFFFF9C784) : Colors.grey,
        ),
      ),
      child: Text(
        response,
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}

class ChatMessage {
  final String sender;
  final String text;

  ChatMessage({required this.sender, required this.text});
}
