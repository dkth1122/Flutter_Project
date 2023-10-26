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

    return PageView(
      scrollDirection: Axis.horizontal,
      controller: controller,
      children: <Widget>[
        Container(
          color: Colors.blue.withOpacity(0.5),
          child: Center(
            child: Text('첫 번째 페이지',style: TextStyle(fontSize: 50),),
          ),
        ),
        Container(
          color: Colors.orangeAccent.withOpacity(0.5),
          child: Center(
            child: Text('두 번째 페이지',style: TextStyle(fontSize: 50),),
          ),
        ),
        Container(
          color: Colors.cyanAccent.withOpacity(0.5),
          child: Center(
            child: Text('세 번째 페이지',style: TextStyle(fontSize: 50),),
          ),
        ),
      ],
    );
  }
}