import 'package:flutter/material.dart';
import 'package:geo_album/app_routings.dart';

void main() {
  runApp(const AppGeoAlbum());
}

class AppGeoAlbum extends StatelessWidget {
  const AppGeoAlbum({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
    );
  }
}


