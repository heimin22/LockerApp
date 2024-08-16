import 'package:flutter/material.dart';
import 'package:first_project/hiddenDrawer.dart';

class hiddenOthersHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      title: 'Images',
      color: const Color.fromARGB(255, 240, 201, 84),
      theme: ThemeData(
          fontFamily: 'ProductSans'
      ),
      home: HiddenOthersScreen(),
    );
  }
}

class HiddenOthersScreen extends StatefulWidget {
  @override
  hiddenOthers createState() => hiddenOthers();
}

class hiddenOthers extends State<HiddenOthersScreen> {
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
        title: Text('Others'),
        backgroundColor: const Color.fromARGB(255, 240, 201, 84),
      ),
      body: Center(
        child: Text(
          'This is the hidden other files/documents drawer',
          style: TextStyle(
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}