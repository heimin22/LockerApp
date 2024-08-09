import 'package:flutter/material.dart';

int number = 0;

void main() => runApp(MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        title: Text(number.toString()),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 240, 201, 84),
      ),
      body: Center(
        child: Text("hello niggas"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color.fromARGB(255, 240, 201, 84),
        child: Text(
          '+',
          style: TextStyle(fontSize: 30),
        ),
      ),
    )));
