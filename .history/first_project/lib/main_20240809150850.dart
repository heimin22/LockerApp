import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Cebuano++'),
          centerTitle: true,
          backgroundColor: const Color.fromARGB(255, 240, 201, 84),
        ),
        body: Center(
          child: Text("hello niggas"),
        ),
        floatingActionButton: FloatingActionButton(
          child: Text('+'),
          onPressed: () {},
        ),
      ),
    ));
