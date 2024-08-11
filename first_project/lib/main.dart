import 'package:flutter/material.dart';

int number = 0;

void main() => runApp(MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        title: Text(
          'Cebuano++',
          style: TextStyle(
            fontFamily: 'ProductSans',
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 240, 201, 84),
      ),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Hello mga real niggas!",
            style: TextStyle(
              letterSpacing: 1.0,
              color: Colors.grey[600],
              fontFamily: 'ProductSans',
            ),
          ),
          Text(
            number.toString(),
            style: TextStyle(
              fontSize: 70,
              fontFamily: 'ProductSans',
            ),
          ),
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
