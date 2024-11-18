import 'package:flutter/material.dart';

class FullImageView extends StatelessWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const FullImageView({
    required this.imageUrls,
    required this.initialIndex,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.orange.shade900,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: PageView.builder(
        controller: PageController(initialPage: initialIndex),
        itemCount: imageUrls.length,
        reverse: true,
        itemBuilder: (context, index) {
          return Center(
            child: InteractiveViewer(
              child: Image.network(imageUrls[index]),
            ),
          );
        },
      ),
    );
  }
}