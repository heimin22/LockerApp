import 'package:flutter/material.dart';
import 'package:first_project/hiddenDrawer.dart';
import 'package:flutter/services.dart';

class hiddenVideosHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Images',
      color: const Color.fromARGB(255, 240, 201, 84),
      theme: ThemeData(
          fontFamily: 'ProductSans'
      ),
      home: HiddenVideosScreen(),
    );
  }
}

class HiddenVideosScreen extends StatefulWidget {
  @override
  hiddenVideos createState() => hiddenVideos();
}

void addNewVideos() {

}


class hiddenVideos extends State<HiddenVideosScreen> with WidgetsBindingObserver {
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
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
            Navigator.push (
              context,
              MaterialPageRoute(builder: (context) => hiddenDrawerHome()),
            );
          },
        ),
        title: Text('Videos'),
        backgroundColor: const Color.fromARGB(255, 240, 201, 84),
      ),
      body: Center(
        child: Text(
          'This is the hidden videos drawer',
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
              onPressed: addNewVideos,
              backgroundColor: const Color.fromARGB(255, 240, 201, 84),
              child: Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}