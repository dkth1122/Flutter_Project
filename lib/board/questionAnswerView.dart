import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          '${data['user']} 문의 답변하기',
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
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '제목 : ${data['title']}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('작성일 : ${DateFormat('yyyy-MM-dd').format(data['timestamp'].toDate())}'),
                      Text('시간 : ${DateFormat('HH:mm:ss').format(data['timestamp'].toDate())}'),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 10,),
              Row(
                children: [
                  Text( '내용 : ${data['content']}',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 50,),
              Row(
                children: [
                  Text("답변 작성",
                    style: TextStyle(
                    fontSize: 18,),
                  ),
                ],
              ),
              SizedBox(height: 10,),
              TextFormField(
                controller: _comment,
                style: TextStyle(fontSize: 20),
                maxLines: 10,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10,),

              ElevatedButton(
                  onPressed: _addComment,
                  child: Text("답변달기"),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Color(0xFFFF8C42)), // 원하는 색상으로 변경
                ),
              ),
              SizedBox(height: 10,),
              _listComments()
            ],
          ),
        ),
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
          physics: NeverScrollableScrollPhysics(), // 스크롤 금지
          shrinkWrap: true,
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
