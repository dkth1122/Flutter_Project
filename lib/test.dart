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
        scrollDirection: Axis.horizontal,
        pageSnapping: false, // false로 수정
        controller: controller,
        children: <Widget>[
          Container(
            color: Colors.blue.withOpacity(0.5),
            child: Center(
              child: Text('첫 번째 페이지'),
            ),
          ),
        ],
      ),
    );
  }
}