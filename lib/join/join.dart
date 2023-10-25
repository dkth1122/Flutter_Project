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
  final TextEditingController _addr = TextEditingController();

  DateTime? _dateTime;
  String idValidationMessage = ''; // 변수를 선언하여 메시지 저장



  void _register() async {
    if (_pw.text != _pw2.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('패스워드가일치하지 않습니다.')),
      );
      return;
    }

    // Firestore에서 중복 아이디 체크

    try {
      await _fs.collection('userList').add({
        'id': _id.text,
        'pw': _pw.text,
        'email': _email.text,
        'name': _name.text,
        'nick': _nick.text,
        'birth': _birth.text,
        'addr': _addr.text,
        'status':'C',//기본값 의뢰인 C
        'banYn': 'N',//기본값 N
        'delYn': 'N',//기본값 N
        'cdatetime': FieldValue.serverTimestamp(),//가입시간

      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('가입완료. ${_name.text}님 환영합니다!')),
      );

      _id.clear();
      _pw.clear();
      _pw2.clear();
      _email.clear();
      _nick.clear();
      _birth.clear();
      _addr.clear();
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
          .where('id', isEqualTo: _id.text)
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
    // 이메일 형식의 정규식 패턴
    String pattern = r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)*$';
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



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('회원가입'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

        Padding(

        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _id,
              onChanged: (value) {
                String id = _id.text;
                if (!isIdValid(id)) {
                  setState(() {
                    idValidationMessage = '유효하지 않은 아이디 형식입니다. 영어소문자와 숫자를 조합한 6자 이상';
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
                labelText: '아이디 , 영어소문자와 숫자를 조합한 6자리 이상',
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
              ),
            ),
            if (idValidationMessage.isNotEmpty)
              Text(
                idValidationMessage,
                style: TextStyle(
                  color: idValidationMessage == '사용 가능한 아이디 입니다.' ? Colors.blue : Colors.red,
                ),
              ),
          ],
        ),
      ),




      Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _pw,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: '비밀번호',
                  labelStyle: TextStyle(
                    color: Color(0xff328772), // 포커스된 상태의 라벨 텍스트 색상
                  ),

                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xff328772), width: 2.0,), // 포커스된 상태의 테두리 색상 설정
                    borderRadius: BorderRadius.circular(10.0), // 포커스된 상태의 테두리 모양 설정 (선택 사항)
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xfff48752),  width: 2.0,), // 비활성 상태의 테두리 색상 설정
                    borderRadius: BorderRadius.circular(10.0), // 비활성 상태의 테두리 모양 설정 (선택 사항)
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _pw2,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: '비밀번호 확인',
                  labelStyle: TextStyle(
                    color: Color(0xff328772), // 포커스된 상태의 라벨 텍스트 색상
                  ),

                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xff328772), width: 2.0,), // 포커스된 상태의 테두리 색상 설정
                    borderRadius: BorderRadius.circular(10.0), // 포커스된 상태의 테두리 모양 설정 (선택 사항)
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xfff48752),  width: 2.0,), // 비활성 상태의 테두리 색상 설정
                    borderRadius: BorderRadius.circular(10.0), // 비활성 상태의 테두리 모양 설정 (선택 사항)
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _name,
                decoration: InputDecoration(
                  labelText: '이름',
                  labelStyle: TextStyle(
                    color: Color(0xff328772), // 포커스된 상태의 라벨 텍스트 색상
                  ),

                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xff328772), width: 2.0,), // 포커스된 상태의 테두리 색상 설정
                    borderRadius: BorderRadius.circular(10.0), // 포커스된 상태의 테두리 모양 설정 (선택 사항)
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xfff48752),  width: 2.0,), // 비활성 상태의 테두리 색상 설정
                    borderRadius: BorderRadius.circular(10.0), // 비활성 상태의 테두리 모양 설정 (선택 사항)
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _nick,
                decoration: InputDecoration(
                  labelText: '닉네임',
                  labelStyle: TextStyle(
                    color: Color(0xff328772), // 포커스된 상태의 라벨 텍스트 색상
                  ),

                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xff328772), width: 2.0,), // 포커스된 상태의 테두리 색상 설정
                    borderRadius: BorderRadius.circular(10.0), // 포커스된 상태의 테두리 모양 설정 (선택 사항)
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xfff48752),  width: 2.0,), // 비활성 상태의 테두리 색상 설정
                    borderRadius: BorderRadius.circular(10.0), // 비활성 상태의 테두리 모양 설정 (선택 사항)
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _email,
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
                  suffixIcon: IconButton(
                    onPressed: () {
                      String email = _email.text;
                      if (!isEmailValid(email)) {
                        // 유효하지 않은 이메일 형식입니다. 사용자에게 메시지를 표시하세요.
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('유효하지 않은 이메일 형식입니다.')),
                        );
                        return;
                      }

                      // 이메일 중복 확인
                      isEmailAlreadyRegistered(email).then((isDuplicate) {
                        if (isDuplicate) {
                          // 중복된 이메일입니다. 사용자에게 메시지를 표시하세요.
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('중복된 이메일 주소입니다.')),
                          );
                        } else {
                          // 중복되지 않은 유효한 이메일입니다. 다음 단계로 진행하세요.
                          // 회원가입 또는 기타 작업을 수행합니다.
                        }
                      });
                    },
                    icon: Icon(Icons.check),
                  ),
                ),

            ),),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _birth,
                decoration: InputDecoration(
                  labelText: '생일',
                  labelStyle: TextStyle(
                    color: Color(0xff328772),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0xff328772),
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0xfff48752),
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  // suffixIcon을 사용하여 아이콘 버튼 추가
                  suffixIcon: IconButton(
                    onPressed: () {
                      showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      ).then((value) {
                        if (value != null) {
                          setState(() {
                            _dateTime = value;
                            _birth.text = _dateTime.toString(); // 선택한 날짜를 TextField에 표시
                          });
                        }
                      });
                    },
                    icon: Icon(Icons.calendar_today), // 아이콘 지정
                  ),
                ),
              ),

            ),
            Text(_dateTime != null
                ? "선택한 날짜: ${_dateTime.toString().split(" ")[0].replaceAll("-", "/")}"
                : "날짜를 선택하세요"),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _addr,
                decoration: InputDecoration(
                  labelText: '주소',
                  labelStyle: TextStyle(
                    color: Color(0xff328772), // 포커스된 상태의 라벨 텍스트 색상
                  ),

                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xff328772), width: 2.0,), // 포커스된 상태의 테두리 색상 설정
                    borderRadius: BorderRadius.circular(10.0), // 포커스된 상태의 테두리 모양 설정 (선택 사항)
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xfff48752),  width: 2.0,), // 비활성 상태의 테두리 색상 설정
                    borderRadius: BorderRadius.circular(10.0), // 비활성 상태의 테두리 모양 설정 (선택 사항)
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _register,
              child: Text('회원가입'),
            ),
          ],
        ),
      ),
    );
  }
}