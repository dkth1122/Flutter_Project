import 'package:flutter/material.dart';

void main() => runApp(const Test());

/// This is the main application widget.
class Test extends StatelessWidget {
  const Test({Key? key}) : super(key: key);

  static const String _title = 'Text PageView';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      home: Scaffold(
        appBar: AppBar(title: const Text(_title)),
        body: const PageViewWidget(),
      ),
    );
  }
}

/// This is the stateless widget that the main application instantiates.
class PageViewWidget extends StatelessWidget {
  const PageViewWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final PageController controller =
    PageController(initialPage: 0, viewportFraction: 0.8);

    return Container(
      height: 100,
      child: PageView(
        // 페이지 목록
        children: [
          // 첫 번째 페이지
          SizedBox.expand(
            child: Container(
              color: Colors.red,
              child: Center(
                child: Text(
                  'Page index : 0',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
          ),
          // 두 번째 페이지
          SizedBox.expand(
            child: Container(
              color: Colors.yellow,
              child: Center(
                child: Text(
                  'Page index : 1',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
          ),
          // 세 번째 페이지
          SizedBox.expand(
            child: Container(
              color: Colors.green,
              child: Center(
                child: Text(
                  'Page index : 2',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
          ),
          // 네 번째 페이지
          SizedBox.expand(
            child: Container(
              color: Colors.blue,
              child: Center(
                child: Text(
                  'Page index : 3',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
          )
        ],
      )
    );
  }
}