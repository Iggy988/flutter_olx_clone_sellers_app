import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sellers_app/models/items.dart';

import '../global/global.dart';
import '../splashScreen/my_splash_screen.dart';

class ItemsDetailsScreen extends StatefulWidget {
  Items? model;

  ItemsDetailsScreen({this.model});

  @override
  State<ItemsDetailsScreen> createState() => _ItemsDetailsScreenState();
}

class _ItemsDetailsScreenState extends State<ItemsDetailsScreen> {
  deleteItem() {
    FirebaseFirestore.instance
        .collection("sellers")
        .doc(sharedPreferences!.getString("uid"))
        .collection("brands")
        .doc(widget.model!.brandID)
        .collection("items")
        .doc(widget.model!.itemID)
        .delete()
        .then((value) {
      FirebaseFirestore.instance
          .collection("items")
          .doc(widget.model!.itemID)
          .delete();

      Fluttertoast.showToast(msg: "Item Deleted Successfully.");
      Navigator.push(
          context, MaterialPageRoute(builder: (c) => MySplashScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            tileMode: TileMode.clamp,
          )),
        ),
        title: Text(
          widget.model!.itemTitle.toString(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          deleteItem();
        },
        label: const Text("Delete this Item"),
        icon: const Icon(
          Icons.delete_sweep_outlined,
          color: Colors.white,
        ),
        backgroundColor: Colors.pinkAccent,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(
            widget.model!.thumbnailUrl.toString(),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0, top: 8.0),
            child: Text(
              widget.model!.itemTitle.toString() + ":",
              textAlign: TextAlign.justify,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.pinkAccent,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 6.0),
            child: Text(
              widget.model!.longDescription.toString(),
              textAlign: TextAlign.justify,
              style: const TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 15,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              widget.model!.price.toString() + " KM",
              textAlign: TextAlign.justify,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 30,
                color: Colors.pink,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 8.0, right: 320.0),
            child: Divider(
              height: 1,
              thickness: 2,
              color: Colors.pinkAccent,
            ),
          ),
        ],
      ),
    );
  }
}
