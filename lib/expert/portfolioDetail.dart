import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class PortfolioDetailPage extends StatefulWidget {
  final portfolioItem;
  final user;

  PortfolioDetailPage({required this.portfolioItem, required this.user});

  @override
  _PortfolioDetailPageState createState() => _PortfolioDetailPageState();
}

class _PortfolioDetailPageState extends State<PortfolioDetailPage> {
  DocumentSnapshot? portfolioDoc;

  @override
  void initState() {
    super.initState();
    fetchPortfolioDetails();
  }

  Future<void> fetchPortfolioDetails() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('expert')
          .doc(widget.user)
          .collection('portfolio')
          .doc(widget.portfolioItem.id)
          .get();
      setState(() {
        portfolioDoc = doc;
      });
    } catch (e) {
      print('포트폴리오 디테일 가져오기 오류: $e');
    }
  }

  _showImageDialog(String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Container(
            height: 500,
            width: 500,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: (){
                Navigator.of(context).pop();
              },
              child: Text("닫기")
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (portfolioDoc == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    Map<String, dynamic>? data = portfolioDoc!.data() as Map<String, dynamic>?;

    if (data == null) {
      return Center(
        child: Text('포트폴리오 데이터를 찾을 수 없습니다.'),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            backgroundColor: Colors.transparent,
            expandedHeight: 300,
            floating: false,
            pinned: false,
            flexibleSpace: FlexibleSpaceBar(
              background: GestureDetector(
                onTap: () {
                  _showImageDialog(data['thumbnailUrl'] ?? '');
                },
                child: Image.network(
                  data['thumbnailUrl'] ?? '',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 10),
                    Text('작성자 : ${widget.user}', style: TextStyle(fontSize: 18)),
                    SizedBox(height: 10),
                    Text('카테고리 > ${data['category']}', style: TextStyle(fontSize: 16)),
                    SizedBox(height: 10),
                    Text(
                      data['title'] ?? '제목 없음',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Wrap(
                      children: [
                        Text(
                          '${data['hashtags']?.join(', ') ?? '없음'}',
                          style: TextStyle(color: Colors.blue, fontSize: 16),
                        ),
                      ],
                    ),

                    SizedBox(height: 10),
                    Divider(
                      height: 20,
                      color: Colors.grey,
                      thickness: 2,
                    ),
                    SizedBox(height: 10),
                    Text(
                      "프로젝트 설명",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      data['portfolioDescription'] ?? '설명 없음',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 20),
                    Text(
                      "참여 기간",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      '참여기간 : ${DateFormat('yyyy-MM-dd').format(data['startDate'].toDate())}'
                          '~ ${DateFormat('yyyy-MM-dd').format(data['endDate'].toDate())}',
                    ),
                  ],
                ),
              ),
            ]),
          ),
          SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 10.0,
            ),
            delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                if (data['subImageUrls'] != null && index < data['subImageUrls'].length) {
                  String imageUrl = data['subImageUrls'][index];
                  return GestureDetector(
                    onTap: () {
                      _showImageDialog(imageUrl);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(imageUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  );
                } else {
                  return Container();
                }
              },
              childCount: (data['subImageUrls'] ?? []).length,
            ),
          ),
        ],
      ),
    );
  }
}