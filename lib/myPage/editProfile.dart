import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project_flutter/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project_flutter/myPage/alertControl.dart';
import 'package:project_flutter/subBottomBar.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../join/userModel.dart';
import 'deleteAccount.dart';

class EditProfile extends StatefulWidget {
  final Map<String, dynamic> data;
  EditProfile({required this.data});
  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  TextEditingController _email = TextEditingController();
  String labelText = ''; // 초기 labelText 값
  String emailValidationMessage = '';//이메일 유효성메시지


  final ImagePicker _imagePicker = ImagePicker();
  File? _image;

  Padding buildTextField(String labelText, String hintText, String value) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 10, 30, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),),
          ),
          TextField(
            onChanged: (email) {
              String emailText = _email.text;
              if (!isEmailValid(emailText)) {
                setState(() {
                  emailValidationMessage = '유효하지 않은 이메일 형식입니다.';
                });
              } else {
                isEmailAlreadyRegistered(emailText).then((isDuplicate) {
                  if (isDuplicate) {
                    setState(() {
                      emailValidationMessage = '중복된 이메일 주소입니다.';
                    });
                  } else {
                    setState(() {
                      emailValidationMessage = '사용 가능한 이메일 주소입니다.';
                    });
                  }
                });
              }
            },
            controller: _email,
            decoration: InputDecoration(
              labelText: labelText,
              hintText: hintText,
            ),
          ),
          Text(
            emailValidationMessage,
            style: TextStyle(
              color: emailValidationMessage == '사용 가능한 이메일 주소입니다.' ? Colors.blue : Colors.red,
            ),
          ),
        ],
      ),
    );
  }


  Future<void> updateUserData() async {
    String emailText = _email.text;

    if (emailText.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('이메일 누락'),
            content: Text('이메일을 입력해주세요.'),
            actions: [
              TextButton(
                child: Text('확인'),
                onPressed: () {
                  Navigator.of(context).pop(); // 다이얼로그 닫기
                },
              ),
            ],
          );
        },
      );
    } else if (!isEmailValid(emailText)) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('유효하지 않은 이메일 형식'),
            content: Text('올바른 이메일 형식으로 입력해주세요.'),
            actions: [
              TextButton(
                child: Text('확인'),
                onPressed: () {
                  Navigator.of(context).pop(); // 다이얼로그 닫기
                },
              ),
            ],
          );
        },
      );
    } else {
      try {
        CollectionReference users = FirebaseFirestore.instance.collection("userList");
        QuerySnapshot snap = await users.where('userId', isEqualTo: widget.data['userId']).get();

        for (QueryDocumentSnapshot doc in snap.docs) {
          await users.doc(doc.id).update({'email': _email.text});

          setState(() {
            Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?; // 데이터를 Map으로 변환
            if (data != null) {
              setState(() {
                labelText = data['email'] ?? '';
                labelText = _email.text; // labelText를 업데이트
              });
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
                    Navigator.of(context).pop();
                    FocusScope.of(context).unfocus();
                    setState(() {
                      labelText = _email.text;
                    });
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
  }



  Future<String?> getUserProfileImageUrl() async {
    try {
      CollectionReference users = FirebaseFirestore.instance.collection("userList");
      QuerySnapshot snap = await users.where('userId', isEqualTo: widget.data['userId']).get();

      for (QueryDocumentSnapshot doc in snap.docs) {
        return doc['profileImageUrl'] as String?;
      }
    } catch (e) {
      // 여기서 오류 처리를 수행합니다. 예를 들어, 기본 이미지 URL을 반환할 수 있습니다.
      return null;
    }
  }

  void _updateProfileImage(File image) {
    final storageRef = FirebaseStorage.instance.ref().child('profile_images/${Uuid().v4()}.png');
    final uploadTask = storageRef.putFile(image);

    uploadTask.then((TaskSnapshot snapshot) {
      snapshot.ref.getDownloadURL().then((downloadURL) async {
        CollectionReference users = FirebaseFirestore.instance.collection("userList");
        QuerySnapshot snap = await users.where('userId', isEqualTo: widget.data['userId']).get();

        for (QueryDocumentSnapshot doc in snap.docs) {
          await users.doc(doc.id).update({
            'profileImageUrl': downloadURL,
          });
        }
        // 업데이트 성공 시 사용자에게 성공 메시지 표시
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('프로필 이미지 업데이트 완료'),
              content: Text('프로필 이미지가 성공적으로 업데이트되었습니다.'),
              actions: [
                TextButton(
                  child: Text('확인'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      });
    });
  }

  //이메일 중복검사
  Future<bool> isEmailAlreadyRegistered(String email) async {
    bool isDuplicate = false;
    // Firebase Firestore 인스턴스 가져오기
    final FirebaseFirestore _fs = FirebaseFirestore.instance;

    try {
      // 'userList' 컬렉션에서 이메일이 주어진 이메일과 일치하는 문서를 쿼리합니다.
      final QuerySnapshot query = await _fs
          .collection('userList')
          .where('email', isEqualTo: _email.text)
          .get();

      // 쿼리 결과에서 문서가 하나 이상 반환되면, 해당 이메일이 이미 등록되었음을 나타냅니다.
      if (query.docs.isNotEmpty) {
        isDuplicate = true;
      }
    } catch (e) {
      // 오류 처리: 데이터베이스 쿼리 중 오류 발생
      print('Error: $e');
    }

    return isDuplicate;
  }

  //이메일 형식 유효성검사
  bool isEmailValid(String email) {
    String pattern = r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$';
    RegExp regExp = RegExp(pattern);
    return regExp.hasMatch(email);
  }



  Future<void> updateUserPassword(newPasswordController, currentPasswordController, Function(bool) setShowError) async {
    try {
      CollectionReference users = FirebaseFirestore.instance.collection(
          "userList");
      QuerySnapshot snap = await users.where(
          'userId', isEqualTo: widget.data['userId']).get();

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
                mainAxisSize: MainAxisSize.min,
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

  void _logOut() {
    // 사용자 데이터 초기화 (예: Provider를 사용하면 해당 Provider를 초기화)
    Provider.of<UserModel>(context, listen: false).logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MyHomePage(),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {



    return MaterialApp(
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white, // 여기서 색상을 흰색으로 설정
        ),
        primaryColor: Colors.white,
        hintColor: Color(0xff424242),
        fontFamily: 'Pretendard',
        iconTheme: IconThemeData(
          color: Color(0xff424242), // 아이콘 색상 설정
          size: 24, // 아이콘 크기 설정
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.black, fontSize: 16),
        ),
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: TextStyle(
            color: Colors.black, // 레이블 텍스트의 색상
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFFF8C42), width: 2.0),
            borderRadius: BorderRadius.circular(10.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFFF8C42), width: 2.0),
            borderRadius: BorderRadius.circular(10.0),
          ),

        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            "계정 설정",
            style: TextStyle(color: Color(0xff424242), fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 1.0,
          iconTheme: IconThemeData( color: Color(0xff424242),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
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

        body: RefreshIndicator(
          onRefresh: () async {
            // 이 부분에서 실제 데이터를 가져오거나 다른 작업을 수행합니다.
            await updateUserData(); // 예: 데이터 업데이트 함수를 호출

            // 데이터가 업데이트된 후, 화면을 다시 그립니다.
            setState(() {
              // 데이터를 가져와서 labelText를 업데이트합니다.
              labelText = 'New Email from Refresh'; // 실제 데이터 가져오는 로직으로 변경
            });
          },
          child: Column(
            children: [
              Stack(
                alignment: Alignment.bottomRight, // 카메라 버튼을 오른쪽 하단에 배치
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: FutureBuilder<String?>(
                      future: getUserProfileImageUrl(),
                      // snapshot의 데이터 상태에 따라 이미지를 표시합니다.
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          // 이미지 URL을 가져오는 동안 로딩 인디케이터 표시
                          return CircularProgressIndicator();
                        } else if (snapshot.hasError || snapshot.data == null) {
                          // 오류가 발생하거나 이미지 URL이 사용 불가능한 경우를 처리합니다.
                          return CircleAvatar(
                            radius: 70,
                            backgroundImage: AssetImage('assets/profile.png'), // 기본 이미지로 대체
                          );
                        } else {
                          // 이미지 URL을 사용 가능한 경우, CircleAvatar에 이미지 적용
                          return CircleAvatar(
                            radius: 70,
                            backgroundImage: NetworkImage(snapshot.data!),
                          );
                        }
                      },
                    )
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
                    ),
                  ),
                ],
              ),


              buildTextField(widget.data['email'], "바꿀 이메일을 입력하세요.", '이메일'),

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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AlertControl(), // 로그인 화면으로 이동하도록 변경
                          ),
                        );
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DeleteAccount(data : widget.data), // 로그인 화면으로 이동하도록 변경
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: SubBottomBar(),
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
            '프로필사진을 선택하세요',
            style: TextStyle(
              fontSize: 20,
            ),
          ),
          SizedBox(height: 20,),
          TextButton.icon(
            icon: Icon(Icons.photo_library, size: 40),
            onPressed: () async{
              final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
              if (pickedFile != null) {
                final imageFile = File(pickedFile.path);
                setState(() {
                  _image = imageFile;
                });
                // 이미지를 선택한 후에 바로 업데이트 수행
                _updateProfileImage(imageFile);
              } else {
                // 이미지 선택이 취소되면 이미지 변수 초기화
                setState(() {
                  _image = null;
                });
              }
              Navigator.pop(context);
            },
            label: Text('Gallery', style: TextStyle(fontSize: 20)),
          ),
        ],
      ),
    );
  }
}
