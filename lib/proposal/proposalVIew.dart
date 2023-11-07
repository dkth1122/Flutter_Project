import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProposalView extends StatefulWidget {
  final String userId;
  final String proposalTitle;
  final String proposalContent;
  final int proposalPrice;
  final String proposer;
  final String documentId; // 추가된 부분: 문서 ID를 받아오기 위한 변수


  const ProposalView({
    required this.userId,
    required this.proposalTitle,
    required this.proposalContent,
    required this.proposalPrice,
    required this.proposer,
    required this.documentId,
  });

  @override
  State<ProposalView> createState() => _ProposalViewState();
}

class _ProposalViewState extends State<ProposalView> {
  bool isAccepted = false;


  @override
  void initState() {
    super.initState();
    _checkAcceptStatus(); // 위에서 정의한 함수를 initState에서 호출하여 초기 상태를 확인합니다.
  }

  void _checkAcceptStatus() {
    FirebaseFirestore.instance.collection("userList")
        .where("userId", isEqualTo: widget.userId)
        .get()
        .then((querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        final userDoc = querySnapshot.docs.first;
        userDoc.reference.collection("accept")
            .where("docId", isEqualTo: widget.documentId)
            .get()
            .then((acceptQuerySnapshot) {
          setState(() {
            isAccepted = acceptQuerySnapshot.docs.isNotEmpty;
          });
        });
      }
    });
  }


  void _addAccept() {
    if (isAccepted) {
      return; // 이미 클릭한 상태면 아무것도 하지 않음
    }

    FirebaseFirestore.instance.collection("userList")
        .where("userId", isEqualTo: widget.userId)
        .get()
        .then((querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        final userDoc = querySnapshot.docs.first;
        userDoc.reference.collection("accept").doc(widget.documentId).set({
          "docId": widget.documentId,
        }, SetOptions(merge: true)); // SetOptions를 사용하여 덮어쓰지 않도록 설정
      }
    });


    setState(() {
      isAccepted = true;
    });

    // "proposal" 컬렉션의 "accept" 필드를 증가시킴
    FirebaseFirestore.instance.collection("proposal").doc(widget.documentId).update({"accept": FieldValue.increment(1)});
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.proposer}의 프로젝트',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor:Color(0xFF4E598C),
        elevation: 1.0,
        iconTheme: IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            onPressed: _addAccept,//userList의 새 컬렉션 값 증가
            icon: isAccepted ? Icon(Icons.check_box) : Icon(Icons.check_box_outlined),
          ),
        ],
      ),
      body: ListView(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '프로젝트 제목',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.proposalTitle,
                  style: TextStyle(fontSize: 16),
                ),
                Divider(),
                Text(
                  '프로젝트 설명',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.proposalContent,
                  style: TextStyle(fontSize: 16),
                ),
                Divider(),
                Text(
                  '예산',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${widget.proposalPrice}원',
                  style: TextStyle(fontSize: 16),
                ),
                Divider(),
                Text(
                  '의뢰인',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.proposer,
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
