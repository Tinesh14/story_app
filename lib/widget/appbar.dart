// ignore_for_file: must_be_immutable

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatefulWidget {
  Color? backgroundColor;
  bool? titleIsCenter;
  Color? titleBackgroundColor;
  String titleAppBar;
  double? titleSize;
  List<Widget>? actions;
  Widget child;
  Widget? trailingIconIos;
  void Function()? onPressedTrailing;
  String tag;
  String urlImage;
  CustomAppBar({
    super.key,
    required this.titleAppBar,
    required this.child,
    required this.urlImage,
    required this.tag,
    this.backgroundColor,
    this.titleIsCenter,
    this.titleBackgroundColor,
    this.titleSize,
    this.actions,
    this.trailingIconIos,
    this.onPressedTrailing,
  });

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.backgroundColor,
      body: NestedScrollView(
        floatHeaderSlivers: true,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              backgroundColor: Colors.orange,
              pinned: true,
              automaticallyImplyLeading: false,
              expandedHeight: 200,
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              forceElevated: innerBoxIsScrolled,
              flexibleSpace: FlexibleSpaceBar(
                background: Hero(
                  tag: widget.tag,
                  child: CachedNetworkImage(
                    imageUrl: widget.urlImage,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        const CircularProgressIndicator(),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  ),
                ),
                centerTitle: widget.titleIsCenter ?? true,
                title: Text(
                  widget.titleAppBar.toString(),
                  style: TextStyle(
                    fontSize: widget.titleSize ?? 22,
                    color: Colors.white,
                  ),
                ),
              ),
              actions: widget.actions,
            ),
          ];
        },
        body: widget.child,
      ),
    );
  }
}
