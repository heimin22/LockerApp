import 'package:flutter/material.dart';

class HiddenDrawerScreen extends StatefulWidget {
  @override
  hiddenDrawer createState() => hiddenDrawer();
}

class hiddenDrawer extends State<HiddenDrawerScreen> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('Drawer'),
        backgroundColor: Color.fromARGB(255, 240, 201, 84),
      ),
      body: Center(
        child: Text(
          'This is the hidden drawer',
          style: TextStyle(
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}
