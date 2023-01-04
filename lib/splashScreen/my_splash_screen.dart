import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../authScreens/auth_screen.dart';
import '../brandScreens/home_screen.dart';

class MySplashScreen extends StatefulWidget {
  const MySplashScreen({Key? key}) : super(key: key);

  @override
  State<MySplashScreen> createState() => _MySplashScreenState();
}

class _MySplashScreenState extends State<MySplashScreen> {
  splashScreenTimer() {
    Timer(const Duration(seconds: 2), () async {
      // seller is already login
      if (FirebaseAuth.instance.currentUser != null) {
        Navigator.push(
            context, MaterialPageRoute(builder: (c) => HomeScreen()));
      } else {
        //user is not loged in
        Navigator.push(
            context, MaterialPageRoute(builder: (c) => AuthScreen()));
      }
    });
  }

  // moramo metodu ubaciti u init state da bi se pozvala na pocetku lifecycla
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    splashScreenTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              colors: [
                Colors.pinkAccent,
                Colors.purpleAccent,
              ],
              begin: FractionalOffset(0.0, 0.0),
              end: FractionalOffset(1.0, 0.0),
              stops: [0.0, 1.0],
              tileMode: TileMode.clamp),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Image.asset('images/splash.png'),
              ),
              const SizedBox(height: 10),
              const Text(
                'iShop Sellers App',
                style: TextStyle(
                    fontSize: 30,
                    letterSpacing: 3,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
