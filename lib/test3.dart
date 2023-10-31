import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Test3 extends StatefulWidget {
  const Test3({Key? key});

  @override
  State<Test3> createState() => _Test3State();
}

class _Test3State extends State<Test3> {
  String imageUrl = ''; // 이미지 다운로드 URL을 저장하는 변수

  @override
  void initState() {
    super.initState();
    // 이미지 다운로드 URL을 Firestore에서 가져옵니다.
    // 이 URL은 이전에 업로드한 이미지의 URL이어야 합니다.
    getImageUrl();
  }

  Future<void> getImageUrl() async {
    try {
      // Firestore에서 이미지 다운로드 URL 가져오기 (예를 들어, 'images' 컬렉션)
      final snapshot = await FirebaseFirestore.instance
          .collection('images')
          .doc('your_document_id') // 해당 문서의 ID 사용
          .get();

      if (snapshot.exists) {
        setState(() {
          imageUrl = snapshot.data()?['url'] ?? '';
        });
      } else {
        print('문서가 존재하지 않습니다.');
      }
    } catch (e) {
      print('이미지 URL을 가져오는 중에 오류 발생: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('이미지 불러오기 예제'),
      ),
      body: Center(
        child: imageUrl.isNotEmpty
            ? Image.network(imageUrl) // 이미지를 표시
            : Text('이미지를 불러올 수 없습니다.'),
      ),
    );
  }
}