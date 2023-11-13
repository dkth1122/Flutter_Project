import 'package:flutter/material.dart';

class Test extends StatefulWidget {
  const Test({super.key});

  @override
  State<Test> createState() => _TestState();
}
void _showFilterOptions(BuildContext context, List<String> options) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return ListView(
        children: options.map((option) {
          return ListTile(
            title: Text(option),
            onTap: () {
              print(option);
            },
          );
        }).toList(),
      );
    },
  );
}
class _TestState extends State<Test> {
  List<String> optionsButton = ['전체','UX기획','웹','커머스','모바일','프로그램','트렌드','데이터','기타'];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "테스트",
          style: TextStyle(
            color: Color(0xff424242),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: (){
              _showFilterOptions(context, optionsButton);
            },
            icon: Icon(Icons.filter_list, color:Color(0xFFFF8C42)),
          )

        ],),
    );
  }
}
