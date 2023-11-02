import 'package:flutter/foundation.dart';

import 'chat.dart';

class ChatProvider extends ChangeNotifier {
  List<ChatMessage> messages = []; // 채팅 메시지 목록
  bool isRead = false; // 읽음 상태

  void addMessage(ChatMessage message) {
    messages.add(message);
    isRead = false; // 새 메시지가 도착하면 읽음 상태를 false로 설정
    notifyListeners();
  }

  void markAsRead() {
    isRead = true; // 메시지를 읽었을 때 읽음 상태를 true로 설정
    notifyListeners();
  }
}
