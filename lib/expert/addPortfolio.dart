import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class PortfolioItem {
  String title;
  String description;
  String thumbnailUrl;
  String category;
  DateTime? startDate;
  DateTime? endDate;
  String customer;
  String industry;
  String portfolioDescription;
  List<String> hashtags; // 해시태그 목록

  PortfolioItem({
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.category,
    this.startDate,
    this.endDate,
    this.customer = "",
    this.industry = "",
    this.portfolioDescription = "",
    this.hashtags = const [], // 초기에 빈 목록으로 시작
  });
}

class AddPortfolio extends StatefulWidget {
  @override
  _AddPortfolioState createState() => _AddPortfolioState();
}

class _AddPortfolioState extends State<AddPortfolio> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController imageUrlController = TextEditingController();

  String selectedCategory = "UX 기획";
  List<String> selectedHashtags = []; // 선택한 해시태그 목록

  // 이미지 파일 경로를 저장하는 변수
  String? imagePath;


  DateTime? startDate;
  DateTime? endDate;
  String customer = "";
  String industry = "";
  String portfolioDescription = "";

  Map<String, List<String>> categoryHashtags = {
    "UX 기획": ["#기획∙스토리보드", "#기타 기획"],
    "웹": [
      "#홈페이지",
      "#홈페이지(웹빌더·CMS)",
      "#홈페이지(워드프레스)",
      "#홈페이지 수정·유지보수",
      "#랜딩페이지",
      "#UI개발·퍼블리싱",
      "#검색최적화·SEO",
      "#애널리틱스",
    ],
    "커머스": [
      "#쇼핑몰",
      "#쇼핑몰(웹빌더·CMS)",
      "#쇼핑몰(카페24)",
      "#쇼핑몰 수정·유지보수",
    ],
    "모바일": ["#앱", "#앱 수정·유지보수"],
    "프로그램": ["#업무용 프로그램(구독형)", "#PC·웹 프로그램", "#서버·클라우드", "#봇·챗봇"],
    "트렌드": ["#AI 애플리케이션", "#게임∙AR∙VR", "#노코드·로우코드", "#메타버스", "#블록체인·NFT"],
    "데이터": [
      "#데이터 구매·구축",
      "#데이터 마이닝·크롤링",
      "#데이터 전처리",
      "#데이터 라벨링",
      "#데이터 분석·시각화",
      "#머신러닝·딥러닝",
      "#데이터베이스",
    ],
    "기타": ["#하드웨어·임베디드", "#보안", "#QA·테스트", "#컴퓨터 기술지원", "#파일변환", "#기타"],
    "직무직군": [
      "#백엔드 개발자",
      "#풀스택 개발자",
      "#데브옵스·인프라 직군",
      "#데이터·ML·DL 직군",
    ],
  };

  // 이미지 선택 메서드
  void _selectThumbnailImage(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        imagePath = pickedFile.path;
      });
    }
  }

  List<PortfolioItem> portfolioItems = [];

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime picked = (await showDatePicker(
      context: context,
      initialDate: startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    ))!;
    if (picked != null && picked != startDate) {
      setState(() {
        startDate = picked;
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime picked = (await showDatePicker(
      context: context,
      initialDate: endDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    ))!;
    if (picked != null && picked != endDate) {
      setState(() {
        endDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            '포트폴리오 등록',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.orange,
        ),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: ListView(
            children: <Widget>[
              Text(
                '등록을 위해 아래 정보를 \n입력해주세요',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16.0),
              Text(
                "필수 정보",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: '제목',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12.0),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: '설명',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12.0),
              Text("썸네일 이미지 선택", style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 12.0),
              imagePath != null
                  ? Image.file(
                File(imagePath!),
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              )
                  : ElevatedButton(
                onPressed: () {
                  _selectThumbnailImage(context);
                },
                child: Text('이미지 선택'),
              ),

              TextField(
                controller: imageUrlController,
                decoration: InputDecoration(
                  labelText: '이미지 URL',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12.0),
              ListTile(
                title: Text(
                  "카테고리: $selectedCategory",
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  _showCategorySelection(context);
                },
              ),
              SizedBox(height: 12.0),
              Wrap(
                children: (categoryHashtags[selectedCategory] ?? []).map((hashtag) {
                  return ChoiceChip(
                    label: Text(hashtag),
                    selected: selectedHashtags.contains(hashtag),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          selectedHashtags.add(hashtag);
                        } else {
                          selectedHashtags.remove(hashtag);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              SizedBox(height: 12.0),
              Row(
                children: <Widget>[
                  TextButton(
                    onPressed: () {
                      _selectStartDate(context);
                    },
                    child: Text(
                      "시작: ${startDate != null ? DateFormat('yyyy-MM-dd').format(startDate!) : '날짜 선택'}",
                    ),
                  ),
                  Text("~"),
                  TextButton(
                    onPressed: () {
                      _selectEndDate(context);
                    },
                    child: Text(
                      "끝: ${endDate != null ? DateFormat('yyyy-MM-dd').format(endDate!) : '날짜 선택'}",
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.0),
              TextField(
                decoration: InputDecoration(
                  labelText: '고객사',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  customer = value;
                },
              ),
              SizedBox(height: 12.0),
              TextField(
                decoration: InputDecoration(
                  labelText: '업종',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  industry = value;
                },
              ),
              SizedBox(height: 12.0),
              TextField(
                decoration: InputDecoration(
                  labelText: '포트폴리오 설명',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  portfolioDescription = value;
                },
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    String title = titleController.text;
                    String description = descriptionController.text;
                    String thumbnailUrl = imageUrlController.text;

                    if (title.isNotEmpty && description.isNotEmpty && thumbnailUrl.isNotEmpty) {
                      portfolioItems.add(PortfolioItem(
                        title: title,
                        description: description,
                        thumbnailUrl: thumbnailUrl,
                        category: selectedCategory,
                        startDate: startDate,
                        endDate: endDate,
                        customer: customer,
                        industry: industry,
                        portfolioDescription: portfolioDescription,
                        hashtags: selectedHashtags, // 선택한 해시태그 목록 추가
                      ));
                      titleController.clear();
                      descriptionController.clear();
                      imageUrlController.clear();

                      startDate = null;
                      endDate = null;
                      customer = "";
                      industry = "";
                      portfolioDescription = "";
                      selectedHashtags.clear(); // 선택한 해시태그 목록 초기화
                    }
                  });
                },
                child: Text('포트폴리오 등록'),
              ),
              SizedBox(height: 16.0),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: portfolioItems.length,
                  itemBuilder: (context, index) {
                    PortfolioItem item = portfolioItems[index];
                    return Card(
                      elevation: 5,
                      margin: EdgeInsets.all(10),
                      child: ListTile(
                        leading: Image.network(item.thumbnailUrl, width: 100, height: 100, fit: BoxFit.cover),
                        title: Text(
                          item.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.description,
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              "카테고리: ${item.category}",
                              style: TextStyle(
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              "시작 날짜: ${item.startDate != null ? DateFormat('yyyy-MM-dd').format(item.startDate!) : '날짜 없음'}",
                              style: TextStyle(
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              "끝 날짜: ${item.endDate != null ? DateFormat('yyyy-MM-dd').format(item.endDate!) : '날짜 없음'}",
                              style: TextStyle(
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              "고객사: ${item.customer}",
                              style: TextStyle(
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              "업종: ${item.industry}",
                              style: TextStyle(
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              "포트폴리오 설명: ${item.portfolioDescription}",
                              style: TextStyle(
                                fontSize: 14,
                              ),
                            ),
                            Wrap(
                              children: item.hashtags.map((hashtag) {
                                return Chip(
                                  label: Text(hashtag),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
  }

  void _showCategorySelection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                title: Text("UX 기획"),
                onTap: () {
                  setState(() {
                    selectedCategory = "UX 기획";
                  });
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: Text("웹"),
                onTap: () {
                  setState(() {
                    selectedCategory = "웹";
                  });
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: Text("커머스"),
                onTap: () {
                  setState(() {
                    selectedCategory = "커머스";
                  });
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: Text("모바일"),
                onTap: () {
                  setState(() {
                    selectedCategory = "모바일";
                  });
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: Text("프로그램"),
                onTap: () {
                  setState(() {
                    selectedCategory = "프로그램";
                  });
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: Text("트렌드"),
                onTap: () {
                  setState(() {
                    selectedCategory = "트렌드";
                  });
                  Navigator.of(context).pop();
                },
              ),              ListTile(
                title: Text("데이터"),
                onTap: () {
                  setState(() {
                    selectedCategory = "데이터";
                  });
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: Text("기타"),
                onTap: () {
                  setState(() {
                    selectedCategory = "기타";
                  });
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: Text("직무직군"),
                onTap: () {
                  setState(() {
                    selectedCategory = "직무직군";
                  });
                  Navigator.of(context).pop();
                },
              ),
              // 다른 카테고리 항목 추가
            ],
          ),
        );
      },
    );
  }
}
