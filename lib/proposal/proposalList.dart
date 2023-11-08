import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:project_flutter/proposal/proposalVIew.dart';
import 'package:provider/provider.dart';

import '../join/userModel.dart';

class ProposalList extends StatefulWidget {
  const ProposalList({super.key});

  @override
  State<ProposalList> createState() => _ProposalListState();
}

class _ProposalListState extends State<ProposalList> {
  bool isAccepted = false;


  Widget _buildInfoBox(String value, String label) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Color(0xFFEFEFEF), // 박스 배경색
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Divider(
            color: Colors.grey, // 선 색상
            thickness: 1, // 선의 두께
          ),
          Text(
            label,
            style: TextStyle(
              fontStyle: FontStyle.italic,
              color: Colors.grey, // 라벨 텍스트 색상
            ),
          ),
        ],
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
          shrinkWrap: true,
          itemCount: snap.data!.docs.length,
          itemBuilder: (context, index) {
            DocumentSnapshot doc = snap.data!.docs[index];
            Map<String, dynamic> data =
            doc.data() as Map<String, dynamic>;
            String documentId = doc.id;
            return ListTile(
              tileColor: Color(0xFFEFEFEF), // 타일 배경색 설정
              contentPadding: EdgeInsets.all(16),
              title: Text(data["title"], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              subtitle:
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8), // 간격 조절을 위한 SizedBox 추가
                  Text(
                    data["category"],
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 8), // 간격 조절을 위한 SizedBox 추가
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildInfoBox('${data["price"]}원', '예산'),
                      _buildInfoBox('${data["accept"]}개', '받은 제안'),
                      _buildInfoBox('${data["cnt"]}개', '조회수'),
                    ],
                  ),
                ],
              ),
              trailing: IconButton(
                onPressed: () {
                },
                icon:Icon(Icons.check_box),
              ),
              onTap: (){
                Navigator.push(context,  MaterialPageRoute(
                  builder: (context) => ProposalView(
                    proposalTitle: data["title"],
                    proposalContent: data["content"],
                    proposalPrice: data["price"],
                    proposer: data["user"],
                    documentId: documentId,
                    userId : userId!
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
          "프로젝트리스트",
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
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _listProposal()
          ],
        ),
      ),
    );

  }
}
