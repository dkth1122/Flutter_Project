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
                  Container(
                    width: 250,
                    child: Text(
                      '제목 : ${data['title']}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('${DateFormat('yyyy-MM-dd').format(data['timestamp'].toDate())}'),
                      Text('${DateFormat('HH:mm:ss').format(data['timestamp'].toDate())}'),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 10,),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '내용 : ${data['content']}',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                      maxLines: null, // 텍스트가 여러 줄로 나뉘지 않도록 설정합니다.
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
            return Stack(
              children: [
                ListTile(
                  title: Text(commentData['comments']),
                  subtitle: Text('작성일 : ${DateFormat('yyyy-MM-dd HH:mm:ss').format(commentData['timestamp'].toDate())}'),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: IconButton(
                    icon: Icon(Icons.clear), // X 아이콘
                    onPressed: () {
                      FirebaseFirestore.instance
                          .collection("question")
                          .doc(widget.document.id)
                          .collection("comments")
                          .get()
                          .then((querySnapshot) {
                        querySnapshot.docs.forEach((doc) {
                          doc.reference.delete();
                        });
                        print("댓글 컬렉션 삭제 성공");
                      });
                    },
                  ),
                ),
              ],
            );

          },
        );
      },
    );
  }

}
