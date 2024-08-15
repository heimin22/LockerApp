import 'package:first_project/hiddenScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';

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
class _NumberCounterState extends State<NumberCounter>
    with WidgetsBindingObserver {
  int number = 0;
  bool showHamster = false;
  bool showHamsterMouse = false;
  bool switchToHiddenScreen = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // TODO: implement didChangeAppLifecycleState
    if (state == AppLifecycleState.paused) {
      terminateApp();
    }
  }

  void terminateApp() {
    if (Platform.isAndroid) {
      // minimizes the app (optional)
      SystemNavigator.pop();
      // terminates the process
      exit(0);
    } else if (Platform.isIOS) {
      exit(0);
    }
  }

  // increment
  void incrementNumber() {
    setState(() {
      number++;
      pictureAppearance();
    });
  }

  // decrement
  void decrementNumber() {
    setState(() {
      number--;
      pictureAppearance();
    });
  }

  void pictureAppearance() {
    setState(() {
      if (number == 10) {
        showHamster = true;
        showHamsterMouse = false;
        switchToHiddenScreen = false;
      } else if (number == 20) {
        showHamsterMouse = true;
        showHamster = false;
        switchToHiddenScreen = false;
      } else if (number == 30) {
        switchToHiddenScreen = true;
        showHamster = false;
        showHamsterMouse = false;
      } else {
        showHamster = false;
        showHamsterMouse = false;
        switchToHiddenScreen = false;
      }
    });
  }

  // the main application production code
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Locker'),
        backgroundColor: const Color.fromARGB(255, 240, 201, 84),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 15.0),
              child: Text(
                'Hello kalibutan!',
                style: TextStyle(
                  letterSpacing: 1.0,
                  color: Colors.grey[600],
                ),
              ),
            ),
            if (switchToHiddenScreen)
              Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => HiddenScreen()),
                      );
                    },
                    icon: Icon(Icons.arrow_right),
                    label: Text('Continue'),
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                      Color.fromARGB(255, 240, 201, 84),
                    )),
                  ),
                ],
              )
            else if (showHamsterMouse)
              Column(
                children: [
                  Image.asset('assets/hamster_mouse.png'),
                  SizedBox(height: 1),
                  Text(
                    'This is a hamster with a mouse.',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              )
            else if (showHamster)
              Column(
                children: [
                  Image.asset('assets/hamster.png'),
                  SizedBox(height: 1),
                  Text(
                    'This is a hamster.',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              )
            else
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
              child: Icon(Icons.add),
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 30.0),
              child: FloatingActionButton(
                onPressed: decrementNumber,
                backgroundColor: const Color.fromARGB(255, 240, 201, 84),
                child: Icon(Icons.remove),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
