import 'package:first_project/hiddenDrawer.dart';
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

void addNewImages() {

}

class hiddenImages extends State<HiddenImagesScreen> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push (
              context,
              MaterialPageRoute(builder: (context) => hiddenDrawerHome()),
            );
          },
        ),
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
      floatingActionButton: Stack(
        children: <Widget>[
          Align (
            alignment: Alignment.bottomRight,
            child: FloatingActionButton(
              onPressed: addNewImages,
              backgroundColor: const Color.fromARGB(255, 240, 201, 84),
              child: Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}