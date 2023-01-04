import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:sellers_app/global/global.dart';

import '../functions/functions.dart';

class PushNotificationSystem {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // notifications arives/recives
  Future whenNotificationRecived(context) async {
    //1. Terminated
    //When app is completely closed and opened directly from push notification
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? remoteMessage) {
      if (remoteMessage != null) {
        //open app and show notification data when open app

        showNotificationWhenOpenApp(
          remoteMessage.data['userOrderId'],
          context,
        );
      }
    });

    //2. Foreground
    // When app is open and it recives a push notification
    FirebaseMessaging.onMessage.listen((RemoteMessage? remoteMessage) {
      if (remoteMessage != null) {
        //directly show notification data
        showNotificationWhenOpenApp(
          remoteMessage.data['userOrderId'],
          context,
        );
      }
    });

    //3. Background
    //When appp is in background and opened directly from push notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? remoteMessage) {
      if (remoteMessage != null) {
        //open the app - directly show notification data
        showNotificationWhenOpenApp(
          remoteMessage.data['userOrderId'],
          context,
        );
      }
    });
  }

  // device recognition token
  Future generateDeviceRecognitionToken() async {
    String? registrationDeviceToken = await messaging.getToken();

    FirebaseFirestore.instance
        .collection('sellers')
        .doc(sharedPreferences!.getString('uid'))
        .update({
      'sellerDeviceToken': registrationDeviceToken,
    });

    messaging.subscribeToTopic('allSellers');
    messaging.subscribeToTopic('allUsers');
  }

  showNotificationWhenOpenApp(orderID, context) async {
    await FirebaseFirestore.instance
        .collection('orders')
        .doc(orderID)
        .get()
        .then((snapshot) {
      if (snapshot.data()!['status'] == 'ended') {
        showReusableSnackBar(context,
            'Order ID # $orderID \n\n has delivered & received by the user.');
      } else {
        showReusableSnackBar(context,
            'You have new Order. \nOrder ID # $orderID \n\n Please Check now.');
      }
    });
  }
}
