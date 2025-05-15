
import 'package:flutter/material.dart';
import 'dart:async';
import 'login.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // الانتقال بعد 3 ثواني
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Welcome to',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 30),
              Image(
                image: AssetImage('images/splash_image.png'), // تأكد من وضع الصورة هنا
                height: 200,
              ),
              SizedBox(height: 30),
              Text(
                'Support a cause today.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('Explore donation options now'),
              SizedBox(height: 40),
              Icon(Icons.favorite, size: 28, color: Colors.black),
            ],
          ),
        ),
      ),
    );
  }
}
