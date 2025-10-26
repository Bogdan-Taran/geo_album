import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PhotoLookingScreen extends StatelessWidget {
  const PhotoLookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Получаем данные из state.extra
    final extraData = GoRouterState.of(context).extra;
    List<String>? urlImages;
    int? index;

    if (extraData != null && extraData is Map<String, dynamic>) {
      urlImages = (extraData['urlImages'] as List?)?.cast<String>();
      index = extraData['index'] as int?;
    }

    // Проверяем, что данные пришли
    if (urlImages == null || index == null || index >= urlImages.length) {
      return Scaffold(
        appBar: AppBar(title: Text("Ошибка")),
        body: Center(child: Text("Не удалось загрузить изображение.")),
      );
    }

    // Теперь используем urlImages и index
    return Scaffold(
      appBar: AppBar(
        title: Text('Фото ${index + 1}'),
      ),
      body: Center(
        child: Image.asset(
          urlImages[index],
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
