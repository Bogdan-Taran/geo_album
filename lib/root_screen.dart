import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'custom_bottom_nav_bar.dart';

const backColorScreens = Color(0xff100F14);


class RootScreen extends StatelessWidget {
  const RootScreen({super.key, required this.navigationShell});

  //Контейнер для навиационного бара
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
        backgroundColor: backColorScreens,
        bottomNavigationBar: CustomNavBar(
        currentIndex: navigationShell.currentIndex, //передаём текущий индекс
           navigationShell: navigationShell,
      )
    );
  }



}