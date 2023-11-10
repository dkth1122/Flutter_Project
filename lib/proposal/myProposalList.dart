import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_flutter/proposal/myProposal.dart';

import 'myProposalView.dart';

class MyProposalList extends StatefulWidget {
  final String userId;

  const MyProposalList({required this.userId, Key? key}) : super(key: key);

  @override
  State<MyProposalList> createState() => _MyProposalListState();
}

class _MyProposalListState extends State<MyProposalList> {
  Future<int> getCount(String title) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('accept')
        .where('aName', isEqualTo: title)
        .get();

    return snapshot.size;
  }

  Widget _customListTile({required String title,required String category, required content, required price, required String delYn}) {
    final Color tileBackgroundColor = delYn =='Y' ? Colors.grey[300]! : Colors.white;
    final Color titleColor = delYn =='Y' ? Colors.grey : Colors.black;
    final Color priceColor = delYn =='Y' ? Colors.grey : Colors.black;

    return InkWell(
      onTap: () {
        Navigator.push(context,  MaterialPageRoute(
          builder: (context) => MyProposalView(
            user: widget.userId,
            proposalTitle: title,
            proposalContent: content,
            proposalPrice: price,
            proposalDel: delYn,
          ),
        ));
      },
      child: Container(
        height: 140,
        margin: EdgeInsets.all(16),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: tileBackgroundColor, // 배경색 설정
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
                      title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: titleColor, // 타이틀 텍스트 색상 설정
                      ),
                    ),
                    SizedBox(height: 8,),
                    Text(
                      category,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey, // 타이틀 텍스트 색상 설정
                      ),
                    ),
                    SizedBox(height: 8,),
                    Text(
                      content,
                      style: TextStyle(
                        fontSize: 16,
                        color: titleColor, // 서브타이틀 텍스트 색상 설정
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
                    color: priceColor, // 가격 텍스트 색상 설정
                  ),
                  Text(
                    '${NumberFormat('#,###').format(price)}원',
                    style: TextStyle(
                      fontSize: 18,
                      color: priceColor, // 가격 텍스트 색상 설정
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


  Widget _listMyProposal() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("proposal")
          .where("user", isEqualTo: widget.userId)
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
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

            return _customListTile(
              title: data["title"],
              category: data["category"],
              content: data["content"],
              price: data["price"],
              delYn: data["title"],
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
          style: TextStyle(color: Color(0xff424242), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1.0,
        iconTheme: IconThemeData(color: Color(0xff424242),),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MyProjectProposal()));
              },
              child: Text("의뢰하기", style: TextStyle(color:Color(0xFFFF8C42) ),))
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _listMyProposal(),
          ],
        ),
      ),
    );
  }
}
