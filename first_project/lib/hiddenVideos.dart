import 'package:flutter/material.dart';

class hiddenVideosHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      title: 'Images',
      color: const Color.fromARGB(255, 240, 201, 84),
      theme: ThemeData(
          fontFamily: 'ProductSans'
      ),
      home: HiddenVideosScreen(),
    );
  }
}

class HiddenVideosScreen extends StatefulWidget {
  @override
  hiddenVideos createState() => hiddenVideos();
}

class hiddenVideos extends State<HiddenVideosScreen> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('Videos'),
        backgroundColor: const Color.fromARGB(255, 240, 201, 84),
      ),
      body: Center(
        child: Text(
          'This is the hidden videos drawer',
          style: TextStyle(
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}