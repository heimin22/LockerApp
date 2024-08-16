import 'package:flutter/material.dart';
import 'package:first_project/hiddenImages.dart';
import 'package:first_project/hiddenVideos.dart';
import 'package:first_project/hiddenDocs.dart';

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
        title: Text('Drawer'),
        backgroundColor: const Color.fromARGB(255, 240, 201, 84),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => hiddenImagesHome()),
                    );
                  },
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/picture_icon.png',
                        width: 50,
                        height: 50,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Pictures',
                        style: TextStyle(
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 30),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => hiddenVideosHome()),
                    );
                  },
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/video_icon.png',
                        width: 50,
                        height: 50,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Videos',
                        style: TextStyle(
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 30),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => hiddenOthersHome()),
                    );
                  },
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/otherfiles_icon.png',
                        width: 50,
                        height: 50,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Others',
                        style: TextStyle(
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
