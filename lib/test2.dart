import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class Test2 extends StatefulWidget {
  const Test2({Key? key}) : super(key: key);

  @override
  _Test2State createState() => _Test2State();
}

class _Test2State extends State<Test2> {
  final ImagePicker _picker = ImagePicker();
  String imageUrl = "";

  Future<void> uploadImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    File imageFile = File(image.path);

    try {
      // Firebase Storage에 이미지 업로드
      final Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('images/${DateTime.now()}.png');
      await storageRef.putFile(imageFile);

      // 이미지의 다운로드 URL을 얻기
      imageUrl = await storageRef.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('images')
          .add({'url': imageUrl});

      // 업로드 성공
      print('이미지 업로드 완료: $imageUrl');

      // 이미지가 업로드된 후 상태를 갱신하여 이미지를 표시
      setState(() {});
    } catch (e) {
      // 업로드 실패
      print('이미지 업로드 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('이미지 업로드 예제'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            imageUrl.isNotEmpty
                ? Image.network(imageUrl)
                : Text('이미지가 없습니다.'),
            ElevatedButton(
              onPressed: uploadImage,
              child: Text('이미지 업로드'),
            ),
          ],
        ),
      ),
    );
  }
}