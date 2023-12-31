import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_flutter/proposal/proposalVIew.dart';
import 'package:project_flutter/subBottomBar.dart';
import 'package:provider/provider.dart';

import '../join/userModel.dart';

class ProposalList extends StatefulWidget {
  const ProposalList({super.key});

  @override
  State<ProposalList> createState() => _ProposalListState();
}

class _ProposalListState extends State<ProposalList> {
  bool isAccepted = false;


  Widget _buildInfoBox(title, content, price, user, documentId, userId) {
    return InkWell(
      onTap: (){
        Navigator.push(context,  MaterialPageRoute(
          builder: (context) => ProposalView(
              proposalTitle: title,
              proposalContent: content,
              proposalPrice: price,
              proposer: user,
              documentId: documentId,
              userId : userId!
          ),
        ),
        );
      },
      child: Container(
        height: 120,
        margin: EdgeInsets.fromLTRB(10, 5, 10, 5),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white, // 배경색 설정
          borderRadius: BorderRadius.circular(10), // 보더 둥글게 설정
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3), // 그림자 효과
            ),
          ],
          border: Border.all(
            color: Color(0xFFFF8C42), // 보더 컬러 설정
          ),

        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title.length > 10
                          ? '${title.substring(0, 10)}...'
                          : title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff424242),
                      ),
                    ),
                    SizedBox(height: 8,),
                    Text(
                      content.length > 25
                          ? '${content.substring(0, 25)}...'
                          : content,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.arrow_drop_down,
                    size: 24,
                    color: Color(0xff424242),
                  ),
                  Text(
                    '${NumberFormat('#,###').format(price).toString()}원',
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xff424242),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _listProposal() {
    UserModel userModel = Provider.of<UserModel>(context, listen: false);
    final userId = userModel.userId;

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("proposal")
          .where("delYn", isEqualTo: 'N')
          .where("user", isNotEqualTo: userModel.userId)
          .orderBy("user")
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
            Map<String, dynamic> data =
            doc.data() as Map<String, dynamic>;
            String documentId = doc.id;
            return _buildInfoBox(data['title'], data['content'], data['price'],data['user'],documentId,userId);
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
          "프로젝트리스트",
          style: TextStyle(color:Color(0xff424242), fontWeight: FontWeight.bold),
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
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 5,),
            _listProposal(),
            SizedBox(height: 5,),
          ],
        ),
      ),
      bottomNavigationBar: SubBottomBar(),
    );

  }
}
