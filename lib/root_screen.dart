import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RootScreen extends StatelessWidget {
  const RootScreen({super.key, required this.navigationShell});

  //Контейнер для навиационного бара
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
        bottomNavigationBar: BottomNavigationBar(
        items: _buildBottomNavBarItems,
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
      )
    );
  }

  //возвращаем лист элементов для ниженго нав бара
  List<BottomNavigationBarItem> get _buildBottomNavBarItems => [
    const BottomNavigationBarItem(
      icon: Icon(Icons.photo_library_outlined),
      label: 'Галерея',
    ),
    const BottomNavigationBarItem(
        icon: Icon(Icons.photo),
        label: 'Фотографии',
    ),
    const BottomNavigationBarItem(
        icon: Icon(Icons.person),
        label: 'Профиль',
    ),
  ];

}