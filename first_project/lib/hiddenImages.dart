import 'package:flutter/material.dart';

class hiddenImagesHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      title: 'Images',
      color: const Color.fromARGB(255, 240, 201, 84),
      theme: ThemeData(
        fontFamily: 'ProductSans'
      ),
      home: HiddenImagesScreen(),
    );
  }
}

class HiddenImagesScreen extends StatefulWidget {
  @override
  hiddenImages createState() => hiddenImages();
}

class hiddenImages extends State<HiddenImagesScreen> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(

        title: Text('Images'),
        backgroundColor: const Color.fromARGB(255, 240, 201, 84),
      ),
      body: Center(
        child: Text(
          'This is the hidden images drawer',
          style: TextStyle(
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}