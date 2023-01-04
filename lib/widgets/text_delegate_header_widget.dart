import 'package:flutter/material.dart';

class TextDelegateHeaderWidget extends SliverPersistentHeaderDelegate {
  String? title;
  TextDelegateHeaderWidget({this.title});
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return InkWell(
      child: Container(
        decoration: const BoxDecoration(
          // boxShadow: [
          //   BoxShadow(
          //     blurRadius: 5.0,
          //     spreadRadius: 1.0,
          //   ),
          // ],
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
        height: 82,
        width: MediaQuery.of(context).size.width,
        alignment: Alignment.center,
        child: InkWell(
          child: Text(
            title.toString(),
            maxLines: 2,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              letterSpacing: 3,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  @override
  // TODO: implement maxExtent
  double get maxExtent => 50;

  @override
  // TODO: implement minExtent
  double get minExtent => 50;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      true;
}
