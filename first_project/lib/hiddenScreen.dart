import 'package:flutter/material.dart';

class HiddenScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hidden Screen'),
        backgroundColor: const Color.fromARGB(255, 240, 201, 84),
      ),
      body: Center(
        child: Text (
          "This is the hidden screen.",
          style: TextStyle(
            fontSize: 24,
          ),
        )
      )
    );
  }
}