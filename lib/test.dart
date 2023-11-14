import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:project_flutter/main.dart';
import 'package:project_flutter/product/productView.dart';

class Test extends StatefulWidget {
  const Test({Key? key}) : super(key: key);

  @override
  State<Test> createState() => _TestState();
}

class _TestState extends State<Test> {
  int _current = 0;
  final CarouselController _controller = CarouselController();

  List<String> imageBanner = ['assets/banner1.webp', 'assets/banner3.webp', 'assets/banner4.webp', 'assets/banner5.webp'];
  List<Widget> bannerWidgets = [
    MyHomePage(),
    MyHomePage(),
    MyHomePage(),
    MyHomePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("테스트")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            sliderWidget(),
          ],
        ),
      ),
    );
  }

  Widget sliderWidget() {
    return CarouselSlider(
      carouselController: _controller,
      items: imageBanner.asMap().entries.map(
            (entry) {
          int index = entry.key;
          String imagePath = entry.value;

          return Builder(
            builder: (context) {
              return GestureDetector(
                onTap: () {
                  // 이미지를 클릭할 때의 동작을 정의
                  _navigateToNewScreen(bannerWidgets[index]); // 해당 이미지의 클래스로 이동
                },
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          );
        },
      ).toList(),
      options: CarouselOptions(
        height: 150,
        viewportFraction: 1.0,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 3),
        onPageChanged: (index, reason) {
          setState(() {
            _current = index;
          });
        },
      ),
    );
  }

  // 새로운 클래스로 이동하는 메서드
  void _navigateToNewScreen(Widget bannerWidget) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => bannerWidget),
    );
  }
}
