import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../subBottomBar.dart';

class ProposalView extends StatefulWidget {
  final String userId;
  final String proposalTitle;
  final String proposalContent;
  final int proposalPrice;
  final String proposer;
  final String documentId;

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

      setState(() {});
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
      }).catchError((error) {
        print("Error getting documents: $error");
      });
    } else {
      FirebaseFirestore.instance.collection('accept').add({
        'uId': widget.userId,
        'aName': widget.proposalTitle,
        'proposer': widget.proposer,
      }).then((value) {
        print("Accept document added with ID: ${value.id}");
      }).catchError((error) {
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
          style: TextStyle(color: Color(0xff424242), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 1.0,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Color(0xff424242)),
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
      body: Container(
        width: double.infinity, // 폭을 최대로 확장
        padding: EdgeInsets.all(16),
        margin: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '프로젝트 제목',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xff424242),
              ),
            ),
            Text(
              widget.proposalTitle,
              style: TextStyle(
                fontSize: 16,
                color: Color(0xff424242),
              ),
            ),
            SizedBox(height: 16),
            Text(
              '프로젝트 설명',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xff424242),
              ),
            ),
            Text(
              widget.proposalContent,
              style: TextStyle(
                fontSize: 16,
                color: Color(0xff424242),
              ),
            ),
            SizedBox(height: 16),
            Text(
              '예산',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xff424242),
              ),
            ),
            Text(
              '${NumberFormat('#,###').format(widget.proposalPrice).toString()}원',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xff424242),
              ),
            ),
            SizedBox(height: 16),
            Text(
              '의뢰인',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xff424242),
              ),
            ),
            Text(
              widget.proposer,
              style: TextStyle(
                fontSize: 16,
                color: Color(0xff424242),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SubBottomBar(),
    );
  }
}
