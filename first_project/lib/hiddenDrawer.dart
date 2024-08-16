import 'package:flutter/material.dart';

class hiddenDrawerHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      title: 'Drawer',
      color: const Color.fromARGB(255, 240, 201, 84),
      theme: ThemeData(
        fontFamily: 'ProductSans',
      ),
      home: HiddenDrawerScreen(),
    );
  }
}

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
        title: Text('Locker'),
        backgroundColor: const Color.fromARGB(255, 240, 201, 84),
      ),
      body: Center(
        child: Text(
          'This is the hidden drawer',
          style: TextStyle(
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}
