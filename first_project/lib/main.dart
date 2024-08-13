import 'package:flutter/material.dart';

int number = 0;

// run the app
void main() => runApp(MyApp());

// class for setting the main app activity and the universal properties
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cebuano++',
      theme: ThemeData(
        fontFamily: 'ProductSans',
      ),
      home: NumberCounter(),
    );
  }
}

// number counter class that runs the number activity class
class NumberCounter extends StatefulWidget {
  @override
  _NumberCounterState createState() => _NumberCounterState();
}

// the number activity class
class _NumberCounterState extends State<NumberCounter> {
  int number = 0;

  // increment
  void incrementNumber() {
    setState(() {
      number++;
    });
  }

  // decrement
  void decrementNumber() {
    setState(() {
      number--;
    });
  }

  // the main application production code
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              onPressed: incrementNumber,
              backgroundColor: const Color.fromARGB(255, 240, 201, 84),
              child: Text(
                '+',
                style: TextStyle(fontSize: 30),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 30.0),
              child: FloatingActionButton(
                onPressed: decrementNumber,
                backgroundColor: const Color.fromARGB(255, 240, 201, 84),
                child: Text(
                  '-',
                  style: TextStyle(fontSize: 30),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
