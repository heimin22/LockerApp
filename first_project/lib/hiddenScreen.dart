import 'package:flutter/material.dart';
import 'package:first_project/hiddenDrawer.dart';

class HiddenScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Locker',
      color: const Color.fromARGB(255, 240, 201, 84),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'ProductSans',
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: Colors.black54,
        ),
      ),
      home: HiddenScreenHome(),
    );
  }
}

class HiddenScreenHome extends StatefulWidget {
  @override
  HiddenScreenHomeState createState() => HiddenScreenHomeState();
}

class HiddenScreenHomeState extends State<HiddenScreenHome> {
  final TextEditingController passwordController = TextEditingController();
  final String password = "Demonaire";
  bool isPasswordVisible = false;
  String errorMessage = ' ';

  void checkPassword() {
    if (passwordController.text == password) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => hiddenDrawerHome()),
      );
    } else {
      setState(() {
        errorMessage = 'Incorrect password. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        appBar: AppBar(
          title: Text('Locker'),
          backgroundColor: const Color.fromARGB(255, 240, 201, 84),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                style: TextStyle(
                  color: Colors.black54,
                ),
                controller: passwordController,
                obscureText: !isPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'Password',
                  errorText: errorMessage.isNotEmpty ? errorMessage : null,
                  suffixIcon: IconButton(
                    color: Colors.black54,
                    onPressed: () {
                      setState(() {
                        isPasswordVisible = !isPasswordVisible;
                      });
                    },
                    icon: Icon(
                      isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Colors.black54,
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: checkPassword,
                child: Text('Unlock'),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                      const Color.fromARGB(255, 240, 201, 84)),
                ),
              ),
            ],
          ),
        ));
  }
}
