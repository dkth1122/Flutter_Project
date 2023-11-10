import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:project_flutter/expert/myPortfolio.dart';
import 'package:provider/provider.dart';

import '../join/userModel.dart';

class EditPortfolio extends StatefulWidget {
  final String portfolioId;
  EditPortfolio({required this.portfolioId});

  @override
  _EditPortfolioState createState() => _EditPortfolioState();
}

class _EditPortfolioState extends State<EditPortfolio> {
  late String user;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  String selectedCategory = "UX기획";
  List<String> selectedHashtags = [];
  bool isThumbnailSelected = false;
  String? thumbImagePath;
  bool isImageSelected = false;
  List<String> imagePaths = [];
  DateTime? startDate;
  DateTime? endDate;
  String customer = "";
  String industry = "";
  String portfolioDescription = "";

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
    loadExistingPortfolio();
  }

  void loadExistingPortfolio() async {
    try {
      DocumentSnapshot portfolioDoc =
      await FirebaseFirestore.instance.collection('expert').doc(user).collection('portfolio').doc(widget.portfolioId).get();
      setState(() {
        titleController.text = portfolioDoc['title'];
        descriptionController.text = portfolioDoc['description'];
        selectedCategory = portfolioDoc['category'];
        thumbImagePath = portfolioDoc['thumbnailUrl'];
        imagePaths = List<String>.from(portfolioDoc['subImageUrls']);
        startDate = portfolioDoc['startDate'].toDate();
        endDate = portfolioDoc['endDate'].toDate();
        customer = portfolioDoc['customer'];
        industry = portfolioDoc['industry'];
        portfolioDescription = portfolioDoc['portfolioDescription'];
        selectedHashtags = List<String>.from(portfolioDoc['hashtags']);
      });
    } catch (e) {
      print('포트폴리오 불러오기 중 오류 발생: $e');
    }
  }

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

  void _showCategorySelection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                title: Text('UX기획'),
                onTap: () {
                  setState(() {
                    selectedCategory = 'UX기획';
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('개발'),
                onTap: () {
                  setState(() {
                    selectedCategory = '개발';
                  });
                  Navigator.pop(context);
                },
              ),
              // 나머지 카테고리들 추가
            ],
          ),
        );
      },
    );
  }

  bool _validateForm() {
    if (titleController.text.isEmpty || descriptionController.text.isEmpty) {
      return false;
    }
    return true;
  }

  Future<void> _updatePortfolio() async {
    try {
      await firestore.collection('expert').doc(user).collection('portfolio').doc(widget.portfolioId).update({
        'title': titleController.text,
        'description': descriptionController.text,
        'thumbnailUrl': thumbImagePath,
        'category': selectedCategory,
        'startDate': startDate,
        'endDate': endDate,
        'customer': customer,
        'industry': industry,
        'portfolioDescription': portfolioDescription,
        'hashtags': selectedHashtags,
        'subImageUrls': imagePaths,
      });
    } catch (e) {
      print('포트폴리오 업데이트 중 오류 발생: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('포트폴리오 수정'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () async {
              if (_validateForm()) {
                await _updatePortfolio();
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: ListView(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('썸네일 이미지 선택'),
                SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    _selectThumbnailImage(context);
                  },
                  child: Container(
                    width: double.infinity,
                    height: 200,
                    color: Colors.grey[300],
                    child: isThumbnailSelected
                        ? Image.file(File(thumbImagePath!))
                        : Icon(Icons.add, size: 50),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('기본 정보'),
                SizedBox(height: 10),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(labelText: '제목'),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(labelText: '설명'),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('시작일 및 종료일 선택'),
                SizedBox(height: 10),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _selectStartDate(context);
                      },
                      child: Text(startDate != null
                          ? DateFormat('yyyy-MM-dd').format(startDate!)
                          : '시작일 선택'),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        _selectEndDate(context);
                      },
                      child: Text(
                        endDate != null
                            ? DateFormat('yyyy-MM-dd').format(endDate!)
                            : '종료일 선택',
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('카테고리 선택'),
                SizedBox(height: 10),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _showCategorySelection(context);
                      },
                      child: Text(selectedCategory),
                    ),
                  ],
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('포트폴리오 설명'),
                SizedBox(height: 10),
                TextField(
                  controller: TextEditingController(text: portfolioDescription),
                  onChanged: (value) {
                    setState(() {
                      portfolioDescription = value;
                    });
                  },
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('해시태그 입력'),
                SizedBox(height: 10),
                TextField(
                  controller: TextEditingController(text: selectedHashtags.join(', ')),
                  onChanged: (value) {
                    setState(() {
                      selectedHashtags = value.split(',').map((e) => e.trim()).toList();
                    });
                  },
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('하위 이미지 선택'),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    _selectSubImage(context);
                  },
                  child: Text('하위 이미지 선택'),
                ),
                SizedBox(height: 10),
                Column(
                  children: [
                    for (String imagePath in imagePaths)
                      Stack(
                        children: [
                          Image.file(File(imagePath)),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                setState(() {
                                  imagePaths.remove(imagePath);
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
