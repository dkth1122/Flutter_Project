import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:project_flutter/proposal/myProposal.dart';

import 'myProposalView.dart';

class MyProposalList extends StatefulWidget {
  final String userId;
  const MyProposalList({required this.userId, Key? key}) : super(key: key);

  @override
  State<MyProposalList> createState() => _MyProposalListState();
}

class _MyProposalListState extends State<MyProposalList> {

  Widget _listMyProposal() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("proposal")
          .where("user", isEqualTo: widget.userId)
          // .orderBy("sendTime", descending: true)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snap) {
        if (!snap.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        return ListView.builder(
          shrinkWrap: true,
          itemCount: snap.data!.docs.length,
          itemBuilder: (context, index) {
            DocumentSnapshot doc = snap.data!.docs[index];
            Map<String, dynamic> data =
            doc.data() as Map<String, dynamic>;
            return ListTile(
                title: Text(data["title"]),
              subtitle: Text(data["content"]),
              trailing: Text(data["price"].toString()),
              onTap: (){
                  Navigator.push(context,  MaterialPageRoute(
                      builder: (context) => MyProposalView(
                        user : widget.userId,
                        proposalTitle: data["title"],
                        proposalContent: data["content"],
                        proposalPrice: data["price"],
                      ),
                    ),
                  );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "내가 의뢰한 프로젝트",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFFFCAF58),
        elevation: 1.0,
        iconTheme: IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
              onPressed:(){
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context)=>MyProjectProposal()));
              },
              child: Text("의뢰하기"))
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _listMyProposal()
          ],
        ),
      ),
    );
  }
}
