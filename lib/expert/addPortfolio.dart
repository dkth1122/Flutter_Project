import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:project_flutter/expert/myPortfolio.dart';
import 'package:provider/provider.dart';

import '../join/userModel.dart';
import '../subBottomBar.dart';

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

  late String user;

  // Firestore 인스턴스 생성
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    UserModel um = Provider.of<UserModel>(context, listen: false);
    if (um.isLogin) {
      user = um.userId!;
      print(user);
    } else {
      user = "없음";
      print("로그인 안됨");
    }
  }

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController imageUrlController = TextEditingController();

  String selectedCategory = "UX기획";
  List<String> selectedHashtags = []; // 선택한 해시태그 목록

  // 이미지 선택 상태 변수
  bool isThumbnailSelected = false;
  bool isImageSelected = false;

  // 이미지 파일 경로를 저장하는 변수
  String? thumbImagePath;
  List<String> imagePaths = [];


  DateTime? startDate;
  DateTime? endDate;
  String customer = "";
  String industry = "";
  String portfolioDescription = "";

  Map<String, List<String>> categoryHashtags = {
    "UX기획": ["#기획∙스토리보드", "#기타 기획"],
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
        thumbImagePath = pickedFile.path;
        isThumbnailSelected = true;
      });
    }
  }
  void _addUser() async {
    CollectionReference userId = FirebaseFirestore.instance.collection('expert');
    await userId.doc(user).set({
      'userId' : user
    });
  }


  // 이미지 선택 메서드
  void _selectSubImage(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        imagePaths.add(pickedFile.path);
        isImageSelected = true;
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

  // 썸네일 이미지 업로드
  Future<String> uploadThumbnailImage(File imageFile, String userId) async {
    String fileName = 'portfolio/thumbnail/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';
    Reference ref = FirebaseStorage.instance.ref().child(fileName);
    await ref.putFile(imageFile);
    String downloadURL = await ref.getDownloadURL();
    return downloadURL;
  }

// 서브 이미지 업로드
  Future<String> uploadSubImage(File imageFile, String userId) async {
    String fileName = 'portfolio/subImg/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';
    Reference ref = FirebaseStorage.instance.ref().child(fileName);
    await ref.putFile(imageFile);
    String downloadURL = await ref.getDownloadURL();
    return downloadURL;
  }

  //title 중복 검사용
  Future<bool> isTitleUnique(String title, String userId) async {
    final expertCollection = firestore.collection('expert');
    final expertDoc = expertCollection.doc(userId);
    final portfolioCollection = expertDoc.collection('portfolio');

    final querySnapshot = await portfolioCollection.where('title', isEqualTo: title).get();

    return querySnapshot.docs.isEmpty;
  }


  //포트폴리오 등록
  Future<void> addPortfolioToFirestore(PortfolioItem item, String userId) async {
    try {
      // Firestore 컬렉션 및 서브컬렉션 참조 생성
      CollectionReference expertCollection = firestore.collection('expert');
      DocumentReference expertDoc = expertCollection.doc(userId);
      CollectionReference portfolioCollection = expertDoc.collection('portfolio');

      // 이미지 업로드 및 URL 가져오기
      String thumbnailUrl = await uploadThumbnailImage(File(thumbImagePath!), userId);
      List<String> subImageUrls = [];
      for (String imagePath in imagePaths) {
        String imageUrl = await uploadSubImage(File(imagePath), userId);
        subImageUrls.add(imageUrl);
      }

      // PortfolioItem을 Firestore에 추가
      await portfolioCollection.add({
        'title': item.title,
        'description': item.description,
        'thumbnailUrl': thumbnailUrl, // 썸네일 이미지 URL
        'subImageUrls': subImageUrls, // 서브 이미지 URL 목록
        'category': item.category,
        'startDate': item.startDate,
        'endDate': item.endDate,
        'customer': item.customer,//고객사
        'industry': item.industry,//업종
        'portfolioDescription': item.portfolioDescription,//포트폴리오 설명
        'hashtags': item.hashtags,
        'likeCnt' : 0,
        'cnt' : 0

      });

      // 데이터 추가 성공
      print('포트폴리오가 Firestore에 추가되었습니다.');
    } catch (e) {
      // 데이터 추가 실패
      print('포트폴리오 추가 중 오류 발생: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          '포트폴리오 등록',
          style: TextStyle(
            color: Color(0xff424242),
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Color(0xFFFF8C42),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
        body: Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: ListView(
            children: <Widget>[
              SizedBox(height: 10,),
              SizedBox(height: 16.0),
              Text(
                "필수 정보",
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xff424242)),
              ),
              SizedBox(height: 16.0),
              Text(
                "제목",
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xff424242)
                ),
              ),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12.0),
              Text(
                "내용",
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xff424242)
                ),
              ),
              TextFormField(
                controller: descriptionController,
                maxLines: 15,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12.0),
              Text("썸네일 이미지 선택", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xff424242))),
              SizedBox(height: 12.0),
              thumbImagePath != null
                  ? Column(
                children: [
                  Image.file(
                    File(thumbImagePath!),
                    width: 300,
                    height: 300,
                    fit: BoxFit.cover,
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        thumbImagePath = null;
                        isThumbnailSelected = false;
                      });
                    },
                    icon: Icon(Icons.clear), // "x" 아이콘 추가
                    label: Text('선택 취소',style: TextStyle(fontWeight: FontWeight.bold,color: Color(0xff424242)),),
                  ),
                ],
              )
                  : ElevatedButton(
                onPressed: () {
                  _selectThumbnailImage(context);
                },
                child: Text('이미지 선택', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                style: ElevatedButton.styleFrom(
                  primary: Color(0xFFFF8C42),
                ),
              ),
              // 이미지 선택 부분
              Text("서브 이미지 선택", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xff424242))),
              SizedBox(height: 12.0),
              ElevatedButton(
                onPressed: () {
                  _selectSubImage(context);
                },
                child: Text('이미지 선택', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),),
                style: ElevatedButton.styleFrom(
                  primary: Color(0xFFFF8C42),
                ),
              ),

              Column(
                children: [
                  if (imagePaths.isNotEmpty) ...imagePaths.asMap().entries.map((entry) {
                    final index = entry.key;
                    final imagePath = entry.value;
                    return Row(
                      children: [
                        Image.file(
                          File(imagePath),
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              // 해당 인덱스의 이미지를 삭제
                              imagePaths.removeAt(index);
                              if (imagePaths.isEmpty) {
                                isImageSelected = false;
                              }
                            });
                          },
                          icon: Icon(Icons.clear), // "x" 아이콘 추가
                        ),
                      ],
                    );
                  }),
                ],
              ),
              SizedBox(height: 12.0),
              Row(
                children: [
                  InkWell(
                    onTap: (){
                      _showCategorySelection(context);
                    },
                    child: Text(
                      "카테고리: $selectedCategory",
                      style: TextStyle(
                        color: Color(0xFFFF8C42),
                        fontWeight: FontWeight.bold,
                        fontSize: 16
                      ),
                    ),
                  )
                ],
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
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFFF8C42)),
                    ),
                  ),
                  Text("~",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFFF8C42)),
                  ),
                  TextButton(
                    onPressed: () {
                      _selectEndDate(context);
                    },
                    child: Text(
                      "끝: ${endDate != null ? DateFormat('yyyy-MM-dd').format(endDate!) : '날짜 선택'}",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFFF8C42)),
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
                onPressed: () async {
                  String errorMessage = "";

                  if (titleController.text.isEmpty) {
                    errorMessage = "제목을 입력하세요.";
                  } else if (descriptionController.text.isEmpty) {
                    errorMessage = "내용을 입력하세요.";
                  } else if (thumbImagePath == null) {
                    errorMessage = "썸네일 이미지를 선택하세요.";
                  } else if (imagePaths.isEmpty) {
                    errorMessage = "서브 이미지를 선택하세요.";
                  } else if (selectedCategory.isEmpty) {
                    errorMessage = "카테고리를 선택하세요.";
                  } else if (startDate == null || endDate == null) {
                    errorMessage = "시작 날짜와 끝난 날짜를 선택하세요.";
                  } else if (customer.isEmpty) {
                    errorMessage = "고객사를 입력하세요.";
                  } else if (industry.isEmpty) {
                    errorMessage = "업종을 입력하세요.";
                  } else if (portfolioDescription.isEmpty) {
                    errorMessage = "포트폴리오 설명을 입력하세요.";
                  }

                  if (errorMessage.isNotEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(errorMessage),
                      ),
                    );
                    return;
                  }

                  if (user != "없음") {
                    // 제목이 중복되지 않는지 확인
                    final isUnique = await isTitleUnique(titleController.text, user);

                    if (isUnique) {
                      _addUser();
                      final portfolioItem = PortfolioItem(
                        title: titleController.text,
                        description: descriptionController.text,
                        thumbnailUrl: thumbImagePath!,
                        category: selectedCategory,
                        startDate: startDate,
                        endDate: endDate,
                        customer: customer,
                        industry: industry,
                        portfolioDescription: portfolioDescription,
                        hashtags: selectedHashtags,
                      );

                      //포트폴리오 등록
                      addPortfolioToFirestore(portfolioItem, user);

                      setState(() {
                        portfolioItems.add(portfolioItem);
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('포트폴리오가 등록되었습니다.'),
                        ),
                      );
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => Portfolio()));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('이미 사용 중인 제목입니다. 다른 제목을 선택하세요.'),
                        ),
                      );
                    }
                  } else {
                    // 사용자가 로그인하지 않은 경우의 처리
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('로그인이 필요한 서비스입니다.'),
                      ),
                    );
                  }
                },
                child: Text('포트폴리오 등록', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  primary: Color(0xFFFF8C42),
                ),
              ),
              SizedBox(height: 16.0),
              //미리보기 오류 발생
              /*ListView.builder(
                  shrinkWrap: true,
                  itemCount: portfolioItems.  length,
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
                ),*/
            ],
          ),
        ),
      bottomNavigationBar: SubBottomBar(),
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
                title: Text("UX기획"),
                onTap: () {
                  setState(() {
                    selectedCategory = "UX기획";
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

