// gallery_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// import 'package:flutter/services.dart'; // Для rootBundle - теперь не нужен здесь
// import 'package:native_exif/native_exif.dart'; // Теперь не нужен здесь
// import 'package:path_provider/path_provider.dart'; // Теперь не нужен здесь
// import 'dart:io'; // Теперь не нужен здесь
import 'photo_looking_screen.dart';
// Импортируем наш сервис
import 'image_exif_service.dart';

const whiteColor = Colors.white;
const blackColor = Colors.black;
const backColorScreens = Color(0xff100F14);

class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backColorScreens,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: backColorScreens,
        centerTitle: true,
        title: Text(
          title,
          style: const TextStyle(color: whiteColor),
        ),
        iconTheme: const IconThemeData(color: whiteColor),
      ),
      body: SafeArea(
        child: FutureBuilder<List<ImageWithLocation>>( // Обновляем тип FutureBuilder
          // future: _getSizeOfImagesAndExif(context), // Убираем старый метод
          future: ImageExifService.loadAllImagesWithLocation(), // Вызываем метод из сервиса
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              debugPrint('Ошибка в GalleryScreen: ${snapshot.error}');
              if (snapshot.error != null) {
                debugPrint(snapshot.error.toString());
              }
              return Center(child: Text('Ошибка: ${snapshot.error}'));
            } else if (snapshot.hasData) {
              // final transformedImages = snapshot.data!; // Убираем старую переменную
              final allImagesData = snapshot.data!; // Новая переменная с типом ImageWithLocation

              // Фильтруем, чтобы отображать только изображения (для галереи может быть нужно все)
              // Но для GridView мы будем использовать все, как и раньше, просто отображая их
              // и передавая индекс для доступа к данным
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                      decoration: const BoxDecoration(
                        color: backColorScreens,
                      ),
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 5,
                          mainAxisSpacing: 5,
                        ),
                        // itemCount: transformedImages.length, // Меняем на длину нового списка
                        itemCount: allImagesData.length,
                        itemBuilder: (context, index) {
                          // final imageData = transformedImages[index]; // Меняем на новый список
                          final imageData = allImagesData[index];

                          // Пропускаем изображения без пути? (Вряд ли, но на всякий случай)
                          if (imageData.imagePath.isEmpty) {
                            // Возвращаем пустой контейнер или заглушку
                            return Container();
                          }

                          return RawMaterialButton(
                            child: InkWell(
                              child: Ink.image(
                                // image: AssetImage(transformedImages[index]['path']), // Меняем на новый путь
                                image: AssetImage(imageData.imagePath),
                                height: 300,
                                fit: BoxFit.cover,
                              ),
                            ),
                            onPressed: () {
                              // Проверяем, есть ли координаты у этого изображения
                              if (imageData.location != null) {
                                // Передаём координаты как LatLng
                                context.go('/gallery/photo', extra: {
                                  // 'urlImages': transformedImages.map((e) => e['path'] as String).toList(), // Меняем на новый список
                                  'urlImages': allImagesData.map((e) => e.imagePath).toList(),
                                  'index': index,
                                  'coordinates': imageData.location, // Передаём LatLng напрямую
                                });
                              } else {
                                // Если координат нет, можно передать null или обработать иначе
                                context.go('/gallery/photo', extra: {
                                  'urlImages': allImagesData.map((e) => e.imagePath).toList(),
                                  'index': index,
                                  'coordinates': null,
                                });
                              }
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              );
            } else {
              return const Center(child: Text('Нет изображений'));
            }
          },
        ),
      ),
    );
  }

// Убираем старый метод _getSizeOfImagesAndExif, так как он теперь в сервисе
// Future<List<Map<String, dynamic>>> _getSizeOfImagesAndExif(BuildContext context) async { ... }
}
