import 'package:flutter/material.dart';

int number = 0;

void main() => runApp(MaterialApp(
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
          Text("hello niggas"),
          Text(number.toString()),
        ],
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color.fromARGB(255, 240, 201, 84),
        child: Text(
          '+',
          style: TextStyle(fontSize: 30),
        ),
      ),
    )));