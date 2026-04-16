import 'package:flutter/material.dart';
import 'package:splashscreen/splashscreen.dart';

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
      navigateAfterSeconds: AfterSplashScreen(),
      title: Text(
        'Welcome to our game!',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
      ),
      backgroundColor: Colors.green,
      styleTextUnderTheLoader: TextStyle(),
      image: Image.network( //change here:
          'data:image/png;base64,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'),
      photoSize: 100.0,
      loaderColor: Colors.white,
      loadingText: Text('Welcome'),
      loadingTextPadding: EdgeInsets.zero,
      useLoader: true,
    );
  }


}
class AfterSplashScreen extends StatelessWidget {
  const AfterSplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( //add the title we want here:
        //title: Text('Landing page'),
        backgroundColor: Colors.greenAccent,
      ),
      body: Center( //add anything we want to say here:
        //child: Text('Finally Done, uff'),

      ),
    );
  }
}