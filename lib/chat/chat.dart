import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:project_flutter/firebase_options.dart';
import '../firebase_options.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const Chat());
}


class Chat extends StatefulWidget {
  const Chat({Key? key}) : super(key: key);

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  String newMessage = "";
  late TextEditingController messageController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Map<String, dynamic>> messages = [];

  @override
  void initState() {
    super.initState();
    messageController = TextEditingController();
    initializeFirebase();
  }

  void initializeFirebase() async {
    await Firebase.initializeApp();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Chat App'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return ListTile(
                  title: Text(message['text']),
                  subtitle: Text(message['displayName']),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    onChanged: (text) {
                      setState(() {
                        newMessage = text;
                      });
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    handleOnSubmit();
                  },
                  child: Text('전송'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void handleOnSubmit() {
    if (newMessage.trim().isNotEmpty) {
      FirebaseFirestore.instance.collection('messages').add({
        'text': newMessage.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'displayName': 'User', // Change to current user's display name
      });

      messageController.clear();
    }
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }
}
