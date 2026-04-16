import 'package:flutter/material.dart';
import 'package:splashscreen/splashscreen.dart';
import 'main_menu_screen.dart';
void main() {

  runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyApp()));
}

class MyApp extends StatefulWidget {
  //animation = stateful
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return SplashScreen(
      seconds: 6,
      navigateAfterSeconds: MainMenuScreen(),
      title: Text(
        'Welcome to our game!',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
      ),
      backgroundColor: Colors.green,
      styleTextUnderTheLoader: TextStyle(),
      image: Image.asset( //change here:
          'assets/images/temp.png'),
      photoSize: 100.0,
      loaderColor: Colors.white,
      loadingText: Text('Welcome'),
      loadingTextPadding: EdgeInsets.zero,
      useLoader: true,
    );
  }


}
