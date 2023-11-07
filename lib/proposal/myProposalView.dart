import 'package:flutter/material.dart';

class MyProposalView extends StatefulWidget {
  final String user;
  final String proposalTitle;
  final String proposalContent;
  final int proposalPrice;


  const MyProposalView({
    required this.user,
    required this.proposalTitle,
    required this.proposalContent,
    required this.proposalPrice,
  });

  @override
  State<MyProposalView> createState() => _MyProposalViewState();
}

class _MyProposalViewState extends State<MyProposalView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.proposalTitle,
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
          IconButton(onPressed: (){
            //공유하기 기능
          }, icon: Icon(Icons.share)),
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
                  '제목: ${widget.proposalTitle}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Divider(),
                Text(
                  '설명: ${widget.proposalContent}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text('예산: ${widget.proposalPrice.toString()}원'),
                Text('프로젝트 시작일과 종료일은 채팅으로 협의하세요~'),
                // 다른 프로젝트 세부 정보 추가
              ],
            ),
          ),
        ],
      ),
    );
  }
}
