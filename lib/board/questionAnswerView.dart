import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class QuestionAnswerView extends StatefulWidget {
  final DocumentSnapshot document;
  QuestionAnswerView({required this.document});

  @override
  State<QuestionAnswerView> createState() => _QuestionAnswerViewState();
}

class _QuestionAnswerViewState extends State<QuestionAnswerView> {

  final TextEditingController _comment = TextEditingController();

  void _addComment() async{
    if(_comment.text.isNotEmpty){
      FirebaseFirestore fs = FirebaseFirestore.instance;
      CollectionReference commnets = fs
          .collection("question")
          .doc(widget.document.id)
          .collection('comments');
      await commnets.add({
        'comments' : _comment.text,
        'timestamp': FieldValue.serverTimestamp(),

      });
      _comment.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> data = widget.document.data() as Map<String, dynamic>;
    return Scaffold(
      appBar: AppBar(title: Text("${data['user']}문의 답변하기"),),
      body: Column(
        children: [
          Text('작성일 : ${data['timestamp'].toDate().toString()}'),
          Text(
            '제목 : ${data['title']}',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text( '내용 : ${data['content']}',
            style: TextStyle(
              fontSize: 18,
            ),
          ),
          TextField(
            controller: _comment,
            decoration: InputDecoration(
              labelText: "댓글 입력",
              border: OutlineInputBorder(),
            ),
          ),

          ElevatedButton(
              onPressed: _addComment,
              child: Text("댓글달기")
          ),
          Expanded(child: _listComments())
        ],
      ),
    );
  }
  Widget _listComments() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("question")
          .doc(widget.document.id)
          .collection("comments")
          .orderBy("timestamp", descending: true)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snap) {
        if (!snap.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        return ListView.builder(
          itemCount: snap.data!.docs.length,
          itemBuilder: (context, index) {
            DocumentSnapshot doc = snap.data!.docs[index];
            Map<String, dynamic> commentData = doc.data() as Map<String, dynamic>;
            if (commentData['comments'] == null || commentData['timestamp'] == null) {
              return Container();
            }
            return ListTile(
              title: Text(commentData['comments']),
              subtitle: Text('작성일: ${commentData['timestamp'].toDate().toString()}'),
            );
          },
        );
      },
    );
  }

}
