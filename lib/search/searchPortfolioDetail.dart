import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SearchPortfolioDetail extends StatefulWidget {
  final Map<String, dynamic> portfolioItem;
  final String user;

  SearchPortfolioDetail({required this.portfolioItem, required this.user});

  @override
  State<SearchPortfolioDetail> createState() => _SearchPortfolioDetailState();
}

class _SearchPortfolioDetailState extends State<SearchPortfolioDetail> {
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.transparent,
            expandedHeight: 300,
            floating: false,
            pinned: false,
            flexibleSpace: FlexibleSpaceBar(
              background: GestureDetector(
                onTap: () {

                },
                child: Image.network(
                  widget.portfolioItem['thumbnailUrl'],
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
                    Text('카테고리 > ${widget.portfolioItem['category']}', style: TextStyle(fontSize: 16)),
                    SizedBox(height: 10),
                    Text(
                      widget.portfolioItem['title'] ?? '제목 없음',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Wrap(
                      children: [
                        Text(
                          '${widget.portfolioItem['hashtags']?.join(', ') ?? '없음'}',
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
                      widget.portfolioItem['portfolioDescription'] ?? '설명 없음',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 20),
                    Text(
                      "참여 기간",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      '참여기간 : ${DateFormat('yyyy-MM-dd').format(widget.portfolioItem['startDate'].toDate())}'
                          '~ ${DateFormat('yyyy-MM-dd').format(widget.portfolioItem['endDate'].toDate())}',
                    ),
                  ],
                ),
              )
            ])
          ),
          SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 10.0,
            ),
            delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                if (widget.portfolioItem['subImageUrls'] != null && index < widget.portfolioItem['subImageUrls'].length) {
                  String imageUrl = widget.portfolioItem['subImageUrls'][index];
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
              childCount: (widget.portfolioItem['subImageUrls'] ?? []).length,
            ),
          ),
        ],
      ),
    );
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
}


