import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:project_flutter/myPage/userData.dart';

class EditProfile extends StatefulWidget {
  final Map<String, dynamic> data;
  EditProfile({required this.data});
  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            "계정 설정",
            style: TextStyle(color: Colors.grey),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 1.0,
          iconTheme: IconThemeData(color: Colors.grey),
          leading: IconButton(
            icon: Icon(Icons.arrow_back,color: Colors.grey,),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.info_outline_rounded),
              onPressed: () {
                // 오른쪽 아이콘을 눌렀을 때 수행할 작업을 여기에 추가합니다.
              },
            ),
          ],
        ),

        body: Column(
          children: [
            Stack(
              alignment: Alignment.bottomRight, // 카메라 버튼을 오른쪽 하단에 배치
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: CircleAvatar(
                    radius: 70,
                    backgroundImage: AssetImage('assets/profile.png'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(1.0), // 카메라 버튼과 CircleAvatar 사이의 간격을 조절
                    child: InkWell(
                      onTap: () {
                        // 클릭시 모달 팝업을 띄워준다.
                        showModalBottomSheet(context: context, builder: ((builder) => bottomSheet()));
                      },
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.grey,
                        size: 40,
                      ),
                    )
                ),
              ],
            ),



            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: '아이디',
                  labelStyle: TextStyle(
                    color: Color(0xff328772),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xff328772), width: 2.0),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xfff48752), width: 2.0),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  hintText: widget.data['userId'],
                ),),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: '닉네임',
                  labelStyle: TextStyle(
                    color: Color(0xff328772),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xff328772), width: 2.0),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xfff48752), width: 2.0),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  hintText: widget.data['nick'],
                ),),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: '이메일',
                  labelStyle: TextStyle(
                    color: Color(0xff328772),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xff328772), width: 2.0),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xfff48752), width: 2.0),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  hintText: widget.data['email'],
                ),),
            ),


          ],


          ),

        ),
      );
  }

  Widget bottomSheet() {
    return Container(
        height: 100,
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20
        ),
        child: Column(
          children: <Widget>[
            Text(
              'Choose Profile photo',
              style: TextStyle(
                fontSize: 20,
              ),
            ),
            SizedBox(height: 20,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                TextButton.icon(
                  icon: Icon(Icons.camera, size: 40),
                  onPressed: () {
                    // takePhoto(ImageSource.camera);
                  },
                  label: Text('Camera', style: TextStyle(fontSize: 20)),
                ),
                TextButton.icon(
                  icon: Icon(Icons.photo_library, size: 40),
                  onPressed: () {
                    // takePhoto(ImageSource.gallery);
                  },
                  label: Text('Gallery', style: TextStyle(fontSize: 20)),
                ),
              ],
            )

          ],
        )
    );
  }
}