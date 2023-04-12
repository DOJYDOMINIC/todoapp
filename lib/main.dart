import 'package:flutter/material.dart';
import 'package:todoapp/views/homepage.dart';

void main (){
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  static final title = Text('ToDo App');

  @override
  Widget build(BuildContext context)=> MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(primaryColor: Colors.black),
    home: HomePage(),
  );
}
