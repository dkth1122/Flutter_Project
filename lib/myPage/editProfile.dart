import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project_flutter/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../join/userModel.dart';

class EditProfile extends StatefulWidget {
  final Map<String, dynamic> data;
  EditProfile({required this.data});
  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  TextEditingController _email = TextEditingController();

  final ImagePicker _imagePicker = ImagePicker();
  XFile? _image;

  Padding buildTextField(String labelText, String hintText, String value) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 10, 30, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(labelText),
          ),
          TextField(
            controller: _email,
            decoration: InputDecoration(
              labelText: labelText,
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
              hintText: hintText,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> updateUserData() async {
    try {
      CollectionReference users = FirebaseFirestore.instance.collection("userList");
      QuerySnapshot snap = await users.where('userId', isEqualTo: widget.data['userId']).get();

      for (QueryDocumentSnapshot doc in snap.docs) {
        await users.doc(doc.id).update({'email': _email.text});

        setState(() {
          Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?; // 데이터를 Map으로 변환
          if (data != null) {
            _email.text = data['email'] ?? ''; // email 필드 가져오고, 널이면 빈 문자열 설정
          }

        });
        _email.clear();
      }
      // 업데이트 성공 시 사용자에게 성공 메시지 표시
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('업데이트 완료'),
            content: Text('이메일이 성공적으로 업데이트되었습니다.'),
            actions: [
              TextButton(
                child: Text('확인'),
                onPressed: () {
                  Navigator.of(context).pop(); // 알림 다이얼로그 닫기
                },
              ),
            ],
          );
        },
      );
    } catch (e) {
      // 업데이트 실패 시 사용자에게 실패 메시지 표시
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('업데이트 실패'),
            content: Text('이메일 업데이트 중 오류가 발생했습니다. 다시 시도해주세요.'),
            actions: [
              TextButton(
                child: Text('확인'),
                onPressed: () {
                  Navigator.of(context).pop(); // 알림 다이얼로그 닫기
                },
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> updateUserPassword(newPasswordController, currentPasswordController, Function(bool) setShowError) async {
    try {
      CollectionReference users = FirebaseFirestore.instance.collection("userList");
      QuerySnapshot snap = await users.where('userId', isEqualTo: widget.data['userId']).get();

      for (QueryDocumentSnapshot doc in snap.docs) {
        String currentPassword = currentPasswordController.text;
        String savedPassword = doc['pw'];
        if (currentPassword == savedPassword) {
          await users.doc(doc.id).update({'pw': newPasswordController.text});
          Navigator.pop(context);
        } else {
          setShowError(true);
        }
      }
    } catch (e) {
      // 오류 처리
    }
  }






  void _logOut() {
    // 사용자 데이터 초기화 (예: Provider를 사용하면 해당 Provider를 초기화)
    Provider.of<UserModel>(context, listen: false).logout();

    // 로그인 화면 또는 다른 원하는 화면으로 이동
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HomePage(), // 로그인 화면으로 이동하도록 변경
      ),
    );
  }

  void _showChangePasswordDialog() {
    TextEditingController currentPasswordController = TextEditingController();
    TextEditingController newPasswordController = TextEditingController();
    bool showError = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('비밀번호 변경'),
              content: Column(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  TextField(
                    controller: currentPasswordController,
                    decoration: InputDecoration(labelText: '현재 비밀번호'),
                    obscureText: true,
                  ),
                  if (showError)
                    Text(
                      '현재 비밀번호가 올바르지 않습니다.',
                      style: TextStyle(color: Colors.red),
                    ),
                  TextField(
                    controller: newPasswordController,
                    decoration: InputDecoration(labelText: '새로운 비밀번호'),
                    obscureText: true,
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('취소'),
                ),
                TextButton(
                  onPressed: () async {
                    await updateUserPassword(newPasswordController, currentPasswordController, (bool value) {
                      setState(() { // 이 부분이 추가된 부분
                        showError = value;
                      });
                    });
                  },
                  child: Text('저장'),
                ),
              ],
            );
          },
        );
      },
    );
  }








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
            icon: Icon(Icons.arrow_back, color: Colors.grey),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.save),
              onPressed: () async {
                updateUserData();

              }
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

            buildTextField('이메일',"바꿀 이메일을 입력하세요.", widget.data['email']),

            Divider(
              color: Colors.grey,
              thickness: 5.0,
            ),
            Expanded(
              child: ListView(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  ListTile(
                    title: Text('알림설정'),
                    onTap: () {
                      // 첫 번째 아이템이 클릭됐을 때 수행할 작업
                    },
                  ),
                  ListTile(
                    title: Text('비밀번호 변경'),
                    onTap: () {
                      _showChangePasswordDialog();
                    },
                  ),

                  ListTile(
                    title: Text('로그아웃'),
                    onTap: () {
                      _logOut();
                    },
                  ),
                  ListTile(
                    title: Text('회원탈퇴'),
                    onTap: () {
                      // 첫 번째 아이템이 클릭됐을 때 수행할 작업
                    },
                  ),
                ],
              ),
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
        vertical: 20,
      ),
      child: Column(
        children: [
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
                onPressed: () async{
                  XFile? image = await _imagePicker.pickImage(source: ImageSource.camera);
                  if (image != null) {
                    setState(() {
                      _image = image;
                    });
                  }
                },
                label: Text('Camera', style: TextStyle(fontSize: 20)),
              ),
              TextButton.icon(
                icon: Icon(Icons.photo_library, size: 40),
                onPressed: () async{
                  XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
                  if (image != null) {
                    setState(() {
                      _image = image;
                    });
                  }
                },
                label: Text('Gallery', style: TextStyle(fontSize: 20)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
