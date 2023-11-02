import 'package:flutter/foundation.dart';
import 'package:project_flutter/chat/chat.dart';

class ChatProvider extends ChangeNotifier {
  List<ChatMessage> messages = []; // 채팅 메시지 목록
  bool isRead = true; // 기본적으로 읽음 상태

  void addMessage(ChatMessage message) {
    messages.add(message);
    isRead = false; // 새 메시지가 도착하면 읽음 상태를 false로 설정
    notifyListeners();
  }

  void markAsRead() {
    isRead = true; // 메시지를 읽었을 때 읽음 상태를 true로 설정
    notifyListeners();
  }

  void setRead(bool read) {
    isRead = read; // 원하는 읽음 상태로 설정
    notifyListeners();
  }

  bool isMessageRead(DateTime messageTime) {
    if (messages.isEmpty) {
      return false; // 메시지 목록이 비어 있으면 읽음 상태가 아닌 것으로 처리
    }

    final latestMessageTime = messages.last.sendTime;
    return latestMessageTime.isAfter(messageTime);
  }

}
