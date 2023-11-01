import 'package:flutter/material.dart';

import 'category/categoryProduct.dart';

class Test extends StatefulWidget {
  const Test({Key? key});

  @override
  State<Test> createState() => _TestState();
}

class _TestState extends State<Test> {
  List<String> imageCartegory = ['assets/category_ux.png','assets/category_web.png','assets/category_shop.png','assets/category_mobile.png','assets/category_program.png','assets/category_trend.png','assets/category_data.png','assets/category_rest.png',];
  List<String> categoryKeywords = ["UX기획", "웹", "커머스", "모바일","프로그램", "트렌드", "데이터", "기타"];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("추천 검색어")),
      body: Center(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text("추천 검색어"),
              ],
            ),
            cartegory(),
          ],
        ),
      ),
    );
  }

  Widget cartegory() {
    return Expanded(
      child: Wrap(
        children: categoryKeywords.asMap().entries.map((entry) {
          final index = entry.key;
          final keyword = categoryKeywords[index];
          final imagePath = imageCartegory[index]; // 이미지 경로 가져오기

          return GestureDetector(
            onTap: () {
              // 클릭할 때 검색어 전달
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CategoryProduct(sendText: keyword), // 해당 검색어를 전달
                ),
              );
            },
            child: Column(
              children: [
                InkWell(
                  child: Container(
                    width: 80, // 넓이 80
                    height: 80, // 높이 80
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.all(6),
                    child: Image.asset(imagePath), // 이미지 표시
                  ),
                ),
                Text(keyword) // 검색 키워드 출력
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

}
