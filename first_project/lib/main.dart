import 'package:flutter/material.dart';

int number = 0;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cebuano++',
      theme: ThemeData(
        fontFamily: 'ProductSans',
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Cebuano++'),
          centerTitle: true,
          backgroundColor: const Color.fromARGB(255, 240, 201, 84),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Hello mga real niggas!',
                style: TextStyle(
                  letterSpacing: 1.0,

                )
              )
            ],
          ),
        ),
      ),
    );
  }
}