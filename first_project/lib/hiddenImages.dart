import 'package:first_project/hiddenDrawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:first_project/selectingImages.dart';
import 'dart:io';

class hiddenImagesHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Images',
      color: const Color.fromARGB(255, 240, 201, 84),
      theme: ThemeData(fontFamily: 'ProductSans'),
      home: HiddenImagesScreen(),
    );
  }
}

class HiddenImagesScreen extends StatefulWidget {
  @override
  hiddenImages createState() => hiddenImages();
}

class hiddenImages extends State<HiddenImagesScreen> with WidgetsBindingObserver {
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addObserver(this); // Start observing lifecycle changes
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Remove observer on dispose
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      // App is in background or exited
      SystemNavigator.pop(); // Kills the app
    }
  }

  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
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
          Align(
            alignment: Alignment.bottomRight,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => selectingImagesHome())
                );
              },
              backgroundColor: const Color.fromARGB(255, 240, 201, 84),
              child: Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}
