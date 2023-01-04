import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:sellers_app/brandScreens/brands_ui_design_widget.dart';
import 'package:sellers_app/brandScreens/upload_brands_screen.dart';
import 'package:sellers_app/global/global.dart';
import 'package:sellers_app/models/brands.dart';
import 'package:sellers_app/pushNotifications/push_notifications_system.dart';
import 'package:sellers_app/widgets/text_delegate_header_widget.dart';

import '../functions/functions.dart';
import '../splashScreen/my_splash_screen.dart';
import '../widgets/my_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  getSellerEarningsFromDatabase() {
    FirebaseFirestore.instance
        .collection('sellers')
        .doc(sharedPreferences!.getString('uid'))
        .get()
        .then((dataSnapshot) {
      previousEarning = dataSnapshot.data()!['earnings'].toString();
    }).whenComplete(() {
      restrictBlockedSellersFromUsingSellersApp();
    });
  }

  //metoda za onemogucavanje usera koji je blokiran da pristupi
  restrictBlockedSellersFromUsingSellersApp() async {
    await FirebaseFirestore.instance
        .collection('sellers')
        .doc(sharedPreferences!.getString('uid'))
        .get()
        .then((snapshot) {
      if (snapshot.data()!['status'] != 'approved') {
        showReusableSnackBar(context, 'You have been BLOCKED by admin.');
        showReusableSnackBar(context, 'Contact admin: admin1@gmail.com');

        FirebaseAuth.instance.signOut();
        Navigator.push(
            context, MaterialPageRoute(builder: (c) => MySplashScreen()));
      }
    });
  }

  @override
  void initState() {
    super.initState();

    PushNotificationSystem pushNotificationSystem = PushNotificationSystem();
    pushNotificationSystem.whenNotificationRecived(context);
    pushNotificationSystem.generateDeviceRecognitionToken();

    getSellerEarningsFromDatabase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MyDrawer(),
      appBar: AppBar(
        flexibleSpace: Container(
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
        ),
        title: const Text(
          'iShop',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (c) => UploadBrandsScreen()));
              },
              icon: const Icon(
                Icons.add,
                color: Colors.white,
              ))
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: TextDelegateHeaderWidget(title: 'My Brands'),
          ),
          //1. write query
          // 2. model class
          // 3. ui design widget

          StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('sellers')
                  .doc(sharedPreferences!.getString('uid'))
                  .collection('brands')
                  .orderBy('publishDate', descending: true)
                  .snapshots(),
              builder: (context, AsyncSnapshot dataSnapshot) {
                if (dataSnapshot.hasData) {
                  // display brands if brand exists
                  return SliverStaggeredGrid.countBuilder(
                      crossAxisCount: 1,
                      staggeredTileBuilder: (c) => const StaggeredTile.fit(1),
                      itemBuilder: (context, index) {
                        Brands brandsModel = Brands.fromJson(
                            dataSnapshot.data.docs[index].data()
                                as Map<String, dynamic>);
                        return BrandsUiDesignWidget(
                          model: brandsModel,
                          context: context,
                        );
                      },
                      itemCount: dataSnapshot.data.docs.length);
                } else {
                  return const SliverToBoxAdapter(
                    child: Center(
                      child: Text("No brands exists"),
                    ),
                  );
                }
              }),
        ],
      ),
    );
  }
}
