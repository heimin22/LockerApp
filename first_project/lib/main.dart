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
                'Hello kalibutan!',
                style: TextStyle(
                  letterSpacing: 1.0,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                number.toString(),
                style: TextStyle(
                  fontSize: 70,
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: Stack(
          children: <Widget>[
            Align(
              alignment: Alignment.bottomRight,
              child: FloatingActionButton(
                onPressed: () {},
                backgroundColor: const Color.fromARGB(255, 240, 201, 84),
                child: Text(
                  '+',
                  style: TextStyle(fontSize: 30),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: FloatingActionButton(
                onPressed: () {},
                backgroundColor: const Color.fromARGB(255, 240, 201, 84),
                child: Text(
                  '-',
                  style: TextStyle(fontSize: 30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void incrementNumber() {

  }

  void decrementNumber() {

  }
}
