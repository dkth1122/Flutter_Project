import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:project_flutter/product.dart';

void main() {
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '메인',
      home: Main(),
    );
  }
}

class Main extends StatefulWidget {
  const Main({super.key});

  @override
  State<Main> createState() => _MainState();
}

class _MainState extends State<Main> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("용채"),),
        body: Container(
          child: Swiper(
            viewportFraction: 0.8, // 전체 슬라이드 아이템 크기
            scale: 0.9, // 활성화 슬라이드 아이템 크기
            scrollDirection: Axis.horizontal, // 슬라이드 방향
            axisDirection: AxisDirection.left, // 정렬
            pagination: SwiperPagination(
              alignment: Alignment.bottomCenter, // 페이지네이션 위치
              builder: SwiperPagination.rect, // 세 가지 스타일의 pagination 사용 가능
            ), // 페이지네이션
            control: SwiperControl(
              iconPrevious: Icons.access_alarms_rounded,// 이전 버튼
              iconNext: Icons.add,// 다음 버튼
              color: Colors.red,// 버튼 색상
              disableColor: Colors.lightGreenAccent, // 비활성화 버튼 색상
              size: 50.0, // 버튼 크기
            ),// 컨트롤 방향 버튼
            loop: false,// 반복
            autoplay: true,// 자동 슬라이드
            duration: 300,// 속도
            itemCount: 3, // 슬라이드 개수
            itemBuilder: (BuildContext ctx, int idx) {
              return SizedBox(
                child: Column(
                  children: [

                  ],
                ),
              );
            },
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                  onPressed: (){
                    Navigator.push(
                        context, MaterialPageRoute(builder: (context) => Product())
                    );
                  },
                  icon: Icon(Icons.add_circle_outline)
              )
            ],
          ),
        ),
      ),
    );
  }
}