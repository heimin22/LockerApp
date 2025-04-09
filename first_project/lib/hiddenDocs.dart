import 'package:flutter/material.dart';
import 'package:first_project/hiddenDrawer.dart';
import 'package:flutter/services.dart';

class hiddenOthersHome extends StatelessWidget {
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
      home: HiddenOthersScreen(),
    );
  }
}

class HiddenOthersScreen extends StatefulWidget {
  @override
  hiddenOthers createState() => hiddenOthers();
}

void addNewDocuments() {
  
}

class hiddenOthers extends State<HiddenOthersScreen> with WidgetsBindingObserver {
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
      SystemNavigator.pop();
    }
  }

  @override
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
        title: Text('Others'),
        backgroundColor: const Color.fromARGB(255, 240, 201, 84),
      ),
      body: Center(
        child: Text(
          'This is the hidden other files/documents drawer',
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
              onPressed: addNewDocuments,
              backgroundColor: const Color.fromARGB(255, 240, 201, 84),
              child: Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}