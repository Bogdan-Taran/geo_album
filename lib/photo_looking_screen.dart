import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const backColorScreens = Color(0xff100F14);


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
        backgroundColor: backColorScreens,
        appBar: AppBar(title: Text("Ошибка")),
        body: Center(child: Text("Не удалось загрузить изображение.", style: TextStyle(color: Colors.white),)),
      );
    }

    // Теперь используем urlImages и index
    return Scaffold(
      backgroundColor: backColorScreens,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white, //change your color here
        ),
        backgroundColor: backColorScreens,
        title: Text('Фото ${index + 1}', style: TextStyle(color: Colors.white),),
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
