import 'package:flutter/material.dart';

class GiphyTabTop extends StatefulWidget {
  final Color? topDragColor;
  GiphyTabTop({Key? key, this.topDragColor}) : super(key: key);

  @override
  State<GiphyTabTop> createState() => _GiphyTabTopState();
}

class _GiphyTabTopState extends State<GiphyTabTop> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Container(
        width: 40,
        height: 5,
        decoration: BoxDecoration(
            color: widget.topDragColor ?? Colors.white.withOpacity(0.2),
            borderRadius: const BorderRadius.all(Radius.circular(10))),
      ),
    );
    /*Container(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      width: 50,
      height: 2,
      color: Theme.of(context).textTheme.bodyLarge!.color!,
    );
    */
  }
}
