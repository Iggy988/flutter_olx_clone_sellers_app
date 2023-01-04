import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sellers_app/global/global.dart';
import 'package:sellers_app/splashScreen/my_splash_screen.dart';

class EarningsScreen extends StatefulWidget {
  const EarningsScreen({super.key});

  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  String totalSellerEarnings = '';

  readTotalEarnings() async {
    await FirebaseFirestore.instance
        .collection('sellers')
        .doc(sharedPreferences!.getString('uid'))
        .get()
        .then((snap) {
      setState(() {
        totalSellerEarnings = snap.data()!['earnings'].toString();
      });
    });
  }

  @override
  void initState() {
    super.initState();
    readTotalEarnings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                totalSellerEarnings + ' KM',
                style: const TextStyle(
                  fontSize: 36,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'Total Earnings',
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 20,
                width: 200,
                child: Divider(
                  color: Colors.white,
                  thickness: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              Card(
                margin:
                    const EdgeInsets.symmetric(vertical: 40, horizontal: 120),
                color: Colors.white54,
                child: ListTile(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MySplashScreen()));
                  },
                  leading: const Icon(Icons.arrow_back, color: Colors.white),
                  title: const Text(
                    'Go Back',
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
