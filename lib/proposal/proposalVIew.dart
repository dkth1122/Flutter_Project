import 'package:flutter/material.dart';

class ProposalView extends StatefulWidget {
  final String proposalTitle;
  final String proposalContent;
  final int proposalPrice;
  final String proposer;

  const ProposalView({
    required this.proposalTitle,
    required this.proposalContent,
    required this.proposalPrice,
    required this.proposer,
  });

  @override
  State<ProposalView> createState() => _ProposalViewState();
}

class _ProposalViewState extends State<ProposalView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.proposalTitle,
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
            icon: Icon(Icons.share),
            onPressed: () {
              // 공유 기능 추가
            },
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
