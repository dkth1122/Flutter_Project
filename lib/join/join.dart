import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';


class Join extends StatefulWidget {
  const Join({super.key});
  @override
  State<Join> createState() => _JoinState();
}

class _JoinState extends State<Join> {

  final FirebaseFirestore _fs = FirebaseFirestore.instance;
  final TextEditingController _id = TextEditingController();
  final TextEditingController _pw = TextEditingController();
  final TextEditingController _pw2 = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _nick = TextEditingController();
  final TextEditingController _birth = TextEditingController();

  DateTime? _dateTime;
  String idValidationMessage = ''; //아이디유효성메시지
  String passwordValidationMessage = ''; //비밀번호유효성메시지
  String nameValidationMessage = '';//이름유효성메시지
  String nickValidationMessage = '';//닉네임유효성메시지
  String emailValidationMessage = '';//이메일 유효성메시지



  void _register() async {
    // 패스워드 확인
    if (_pw.text != _pw2.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('패스워드가 일치하지 않습니다.')),
      );
      return;
    }

    // 아이디 유효성 검사
    String id = _id.text;
    if (!isIdValid(id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('유효하지 않은 아이디 형식입니다. (6자 이상의 영어 소문자와 숫자의 조합)')),
      );
      return;
    }

    // 아이디 중복 확인
    bool isIdDuplicate = await isIdAlreadyRegistered(id);
    if (isIdDuplicate) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('이미 가입된 아이디입니다.')),
      );
      return;
    }

    // 이름 유효성 검사
    String name = _name.text;
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('이름을 입력하세요.')),
      );
      return;
    }

    // 이메일 유효성 검사
    String email = _email.text;
    if (!isEmailValid(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('유효하지 않은 이메일 형식입니다.')),
      );
      return;
    }

    // 이메일 중복 확인
    bool isEmailDuplicate = await isEmailAlreadyRegistered(email);
    if (isEmailDuplicate) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('중복된 이메일 주소입니다.')),
      );
      return;
    }

    // 닉네임 유효성 검사
    String nickname = _nick.text;
    if (!isNicknameValid(nickname)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('유효하지 않은 닉네임 형식입니다. (최대 8자)')),
      );
      return;
    }

    // 닉네임 중복 확인
    bool isNicknameDuplicate = await isNickAlreadyRegistered(nickname);
    if (isNicknameDuplicate) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('이미 사용 중인 닉네임입니다.')),
      );
      return;
    }


    // 생일 유효성 검사
    String birth = _birth.text;
    if (birth.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('생일을 입력하세요.')),
      );
      return;
    }

    // 여기까지 도달하면 모든 검사를 통과한 것이므로 회원가입을 처리
    try {
      await _fs.collection('userList').add({
        'userId': _id.text,
        'pw': _pw.text,
        'email': _email.text,
        'name': _name.text,
        'nick': _nick.text,
        'birth': _birth.text,
        'status': 'C', // 기본값 의뢰인 C
        'banYn': 'N', // 기본값 N
        'delYn': 'N', // 기본값 N
        'cdatetime': FieldValue.serverTimestamp(), // 가입시간
        'profileImageUrl' : 'https://firebasestorage.googleapis.com/v0/b/projectflutter-15fe4.appspot.com/o/profile_images%2F830aeba4-0c48-49a1-bb23-ead9d2c796b7.png?alt=media&token=d74f9ad5-21f3-4741-8b4c-5831c11b73e6' //기본프로필로 설정

      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('가입완료. ${_name.text}님 환영합니다!')),
      );

      FirebaseFirestore.instance.collection('coupon').add({
        'cName': '회원가입 축하 쿠폰',
        'discount': 10,
        'userId': _id.text,
      });

      _id.clear();
      _pw.clear();
      _pw2.clear();
      _email.clear();
      _nick.clear();
      _birth.clear();

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }



  // 아이디 중복 확인 함수
  Future<bool> isIdAlreadyRegistered(String id) async {
    bool isDuplicate = false;
    final FirebaseFirestore _fs = FirebaseFirestore.instance;
    try {
      final QuerySnapshot query = await _fs
          .collection('userList')
          .where('userId', isEqualTo: _id.text)
          .get();
      if (query.docs.isNotEmpty) {
        isDuplicate = true;
      }
    } catch (e) {
      print('Error: $e');
    }
    return isDuplicate;
  }

// 아이디 유효성 검사 (영어 소문자와 숫자를 섞어서 6자리 이상)
  bool isIdValid(String id) {
    final RegExp idRegExp = RegExp(r'^(?=.*[a-z])(?=.*\d)[a-z\d]{6,}$');
    return idRegExp.hasMatch(id);
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


  // 비밀번호 유효성 검사 함수 (8자 이상의 영어 소문자와 숫자)
  bool isPasswordValid(String password) {
    final RegExp passwordRegExp = RegExp(r'^(?=.*[a-z])(?=.*\d)[a-z\d]{8,}$');
    return passwordRegExp.hasMatch(password);
  }

// 비밀번호와 비밀번호 확인 일치 여부 확인 함수
  bool arePasswordsMatching(String password, String password2) {
    return password == password2;
  }
  void checkPasswordValidity(String password, String password2) {
    if (isPasswordValid(password) && arePasswordsMatching(password, password2)) {
      setState(() {
        passwordValidationMessage = '비밀번호가 유효하며 일치합니다.';
      });
    } else {
      setState(() {
        passwordValidationMessage = '비밀번호는 8자 이상의 영어 소문자와 숫자 조합이어야 하며, 두 비밀번호는 일치해야 합니다.';
      });
    }
  }

  // 정규식을 사용하여 이름이 한글로만 구성되며 최대 10자 이내인지 확인
  bool isNameValid(String name) {
    final RegExp nameRegExp = RegExp(r'^[가-힣]{1,10}$');
    return nameRegExp.hasMatch(name);
  }
  // 정규식을 사용하여 닉네임이 최대 10자 이내인지 확인
  bool isNicknameValid(String nickname) {
    final RegExp nicknameRegExp = RegExp(r'^[a-zA-Z0-9가-힣]{1,8}$');
    return nicknameRegExp.hasMatch(nickname);
  }

  //닉네임 중복검사
  Future<bool> isNickAlreadyRegistered(String nick) async {
    bool isDuplicate = false;
    final FirebaseFirestore _fs = FirebaseFirestore.instance;
    try {
      final QuerySnapshot query = await _fs
          .collection('userList')
          .where('nick', isEqualTo: _nick.text)
          .get();

      if (query.docs.isNotEmpty) {
        isDuplicate = true;
      }
    } catch (e) {
      print('Error: $e');
    }
    return isDuplicate;
  }





  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Color(0xFF4E598C),
        hintColor: Color(0xFFFCAF58),
        fontFamily: 'Pretendard',
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.black, fontSize: 16),
        ),
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: TextStyle(
            color: Colors.black, // 레이블 텍스트의 색상
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF4E598C), width: 2.0),
            borderRadius: BorderRadius.circular(10.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF4E598C), width: 2.0),
            borderRadius: BorderRadius.circular(10.0),
          ),
          hintStyle: TextStyle(
            color: Color(0xFFFF8C42) ,
          ),

        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('회원가입',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: Color(0xFFFCAF58), // 배경색 변경
          elevation: 1.0,
          iconTheme: IconThemeData(color: Colors.white),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: SingleChildScrollView(
            child:
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _id,
                  onChanged: (value) {
                    String id = _id.text;
                    if (!isIdValid(id)) {
                      setState(() {
                        idValidationMessage = '유효하지 않은 아이디 형식입니다. (6자 이상의 영어소문자와 숫자의 조합)';
                      });
                    } else {
                      isIdAlreadyRegistered(id).then((isDuplicate) {
                        if (isDuplicate) {
                          setState(() {
                            idValidationMessage = '이미 가입된 아이디 입니다.';
                          });
                        } else {
                          setState(() {
                            idValidationMessage = '사용 가능한 아이디 입니다.';
                          });
                        }
                      });
                    }
                  },
                  decoration: InputDecoration(
                    labelText: '아이디',
                    hintText: "영어소문자와 숫자를 조합한 6자리 이상",
                    suffixIcon: idValidationMessage == '사용 가능한 아이디 입니다.' ? Icon(Icons.check) : null,

                  ),
                ),
              ),
              if (idValidationMessage.isNotEmpty)
                Text(
                  idValidationMessage,
                  style: TextStyle(
                    color: idValidationMessage == '사용 가능한 아이디 입니다.' ? Colors.blue : Colors.red,
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _pw,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: '비밀번호',
                    hintText: "8자 이상의 영어 소문자와 숫자 조합",


                  ),
                  onChanged: (password) {
                    setState(() {
                      if (isPasswordValid(password)) {
                        passwordValidationMessage = '비밀번호가 유효합니다. 비밀번호 확인해주세요. ';
                      } else {
                        passwordValidationMessage = '비밀번호가 유효하지 않습니다. (8자 이상의 영어 소문자와 숫자 조합)';
                      }
                    });
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _pw2,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: '비밀번호 확인',

                      ),
                      onChanged: (password2) {
                        setState(() {
                          bool isValidPassword = isPasswordValid(_pw.text);
                          bool doPasswordsMatch = (password2 == _pw.text);

                          if (isValidPassword && doPasswordsMatch) {
                            passwordValidationMessage = '비밀번호가 유효하며 일치합니다.';
                          } else if (!isValidPassword) {
                            passwordValidationMessage = '비밀번호가 유효하지 않습니다. (8자 이상의 영어 소문자와 숫자 조합)';
                          } else if (!doPasswordsMatch) {
                            passwordValidationMessage = '비밀번호가 일치하지 않습니다.';
                          }
                        });
                      },

                    ),
                    Text(
                      passwordValidationMessage,
                      style: TextStyle(
                        color: passwordValidationMessage == '비밀번호가 유효하며 일치합니다.' ? Colors.blue : Colors.red,
                      ),
                    ),

                  ],
                ),


              ),



              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _name,
                      decoration: InputDecoration(
                        labelText: '이름',
                        hintText: '한글로만, 10자 이내',

                      ),
                      onChanged: (name) {
                        setState(() {
                          if (isNameValid(name)) {
                            nameValidationMessage = '유효한 이름입니다.';
                          } else {
                            nameValidationMessage = '한글로만 최대 10자 이내로 입력하세요.';
                          }
                        });
                      },
                    ),
                    Text(
                      nameValidationMessage,
                      style: TextStyle(
                        color: nameValidationMessage == '유효한 이름입니다.' ? Colors.blue : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _nick,
                      onChanged: (value) {
                        String nickname = _nick.text;
                        if (nickname.isEmpty) {
                          setState(() {
                            nickValidationMessage = '닉네임을 입력하세요';
                          });
                        } else if (isNicknameValid(nickname)) {
                          isNickAlreadyRegistered(nickname).then((isDuplicate) {
                            if (isDuplicate) {
                              setState(() {
                                nickValidationMessage = '이미 사용 중인 닉네임입니다.';
                              });
                            } else {
                              setState(() {
                                nickValidationMessage = '사용 가능한 닉네임입니다.';
                              });
                            }
                          });
                        } else {
                          setState(() {
                            nickValidationMessage = '닉네임은 최대 10자 이내로 입력하세요.';
                          });
                        }
                      },
                      decoration: InputDecoration(
                        labelText: '닉네임',
                        hintText: '10자 이내, 특수기호 불가',


                      ),
                    ),
                    if (nickValidationMessage.isNotEmpty)
                      Text(
                        nickValidationMessage,
                        style: TextStyle(
                          color: nickValidationMessage == '닉네임을 입력하세요' ? Colors.red :
                          nickValidationMessage == '사용 가능한 닉네임입니다.' ? Colors.blue : Colors.red,
                        ),
                      ),
                  ],
                ),
              ),


              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _email,
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
                  decoration: InputDecoration(
                    labelText: '이메일',
                    hintText: '이메일 형식으로 (@포함)',
                  ),
                ),
              ),

              Text(
                emailValidationMessage,
                style: TextStyle(
                  color: emailValidationMessage == '사용 가능한 이메일 주소입니다.' ? Colors.blue : Colors.red,
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _birth,
                  decoration: InputDecoration(
                    labelText: '생일',
                    // suffixIcon을 사용하여 아이콘 버튼 추가
                    suffixIcon: IconButton(
                      onPressed: () {
                        showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                          builder: (BuildContext context, Widget? child) {
                            return Theme(
                              data: ThemeData.light().copyWith(
                                primaryColor: Color(0xFFFF9C784), // 선택된 날짜 색상
                                hintColor: Color(0xFFFF9C784), // 날짜 텍스트 색상
                                buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
                              ),
                              child: child!,
                            );
                          },
                        ).then((value) {
                          if (value != null) {
                            setState(() {
                              _dateTime = value;
                              _birth.text = _dateTime.toString().split(" ")[0].replaceAll("-", "/"); // 선택한 날짜를 TextField에 표시
                            });
                          }
                        });
                      },
                      icon: Icon(Icons.calendar_today), // 아이콘 지정
                    ),
                  ),
                ),

              ),


              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _register,
                child: Text('회원가입'),
                style: ButtonStyle(
                  minimumSize: MaterialStateProperty.all(Size(200, 55)),
                  backgroundColor: MaterialStateProperty.all(Color(0xFF4E598C)),
                  foregroundColor: MaterialStateProperty.all(Colors.white),
                ),
               ),
            ]
        ),
        ),
      ),
    );
  }
}