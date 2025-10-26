import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomNavBar extends StatelessWidget {
  const CustomNavBar({
    super.key,
    required this.navigationShell,
    required this.currentIndex,
  });

  final StatefulNavigationShell navigationShell;
  final int currentIndex; //текущий индекс для подсветки активности кнопки

  //по нажатию переход на другую страницу
  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      _NavBarItem(
        icon: Icons.photo_library_outlined,
        activeIcon: Icons.photo_library,
        //активное состояние
        label: 'Галерея',
        isActive: currentIndex == 0,
        onTap: () => _onTap(0),
      ),
      _NavBarItem(
        icon: Icons.map_outlined,
        activeIcon: Icons.map,
        label: 'Карта',
        isActive: currentIndex == 1,
        //индекс 'map' ветки - 1 (0-indexed)
        onTap: () => _onTap(1),
      ),
      // _NavBarItem(
      //   icon: Icons.photo_outlined,
      //   activeIcon: Icons.photo,
      //   label: 'Фото',
      //   isActive: currentIndex == 1,
      //   //индекс 'map' ветки - 2 (0-indexed)
      //   onTap: () => _onTap(2),
      // ),
    ];

    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Color(0xff100F14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: items,
      ),
    );
  }
}


//внутренний виджет для одной кнопки навигации
class _NavBarItem extends StatelessWidget{
  const _NavBarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: isActive ? Color(0xff1D1C21) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, //будет занимать минимум места
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? Color(0xffE1E0E0) : Color(0xff776C6B),
              size: 24,
            ),
            const SizedBox(height: 4,),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Color(0xffFFFFFF) : Color(0xff776C6B),
                fontSize: 12,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            )
          ],
        ),
      ),
    );
  }
}