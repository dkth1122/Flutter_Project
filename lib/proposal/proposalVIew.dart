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
    _checkAcceptStatus();
    _incrementAcceptCount();
  }

  void _incrementAcceptCount() {
    FirebaseFirestore.instance
        .collection('proposal')
        .where('title', isEqualTo: widget.proposalTitle)
        .get()
        .then((QuerySnapshot snapshot) {
      snapshot.docs.forEach((document) {
        final currentCount = document['cnt'] as int;
        document.reference.update({'cnt': currentCount + 1});
      });

      setState(() {
        // UI 업데이트
      });
    });
  }

  void _checkAcceptStatus() {
    FirebaseFirestore.instance
        .collection("accept")
        .where("uId", isEqualTo: widget.userId)
        .where("aName", isEqualTo: widget.proposalTitle)
        .get()
        .then((querySnapshot) {
      setState(() {
        isAccepted = querySnapshot.docs.isNotEmpty;
      });
    });
  }

  void _addAccept() {
    if (isAccepted) {
      FirebaseFirestore.instance
          .collection('accept')
          .where('uId', isEqualTo: widget.userId)
          .where('aName', isEqualTo: widget.proposalTitle)
          .get()
          .then((QuerySnapshot snapshot) {
        for (QueryDocumentSnapshot doc in snapshot.docs) {
          doc.reference.delete().then((value) {
            print("Document successfully deleted!");
          }).catchError((error) {
            print("Error removing document: $error");
          });
        }
      })
          .catchError((error) {
        print("Error getting documents: $error");
      });
    } else {
      FirebaseFirestore.instance.collection('accept').add({
        'uId': widget.userId,
        'aName': widget.proposalTitle,
        'proposer': widget.proposer,
      })
          .then((value) {
        print("Accept document added with ID: ${value.id}");
      })
          .catchError((error) {
        print("Error adding Accept document: $error");
      });
    }

    setState(() {
      isAccepted = !isAccepted;
    });

    int incrementValue = isAccepted ? 1 : -1;
    FirebaseFirestore.instance.collection("proposal").doc(widget.documentId).update({"accept": FieldValue.increment(incrementValue)});
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
            onPressed: _addAccept,
            icon: isAccepted
                ? Icon(Icons.check_box)
                : Icon(Icons.check_box_outlined),
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
