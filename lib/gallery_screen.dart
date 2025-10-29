import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart'; // Для rootBundle
import 'package:native_exif/native_exif.dart'; // Импортируем native_exif
import 'package:path_provider/path_provider.dart'; // Для временных файлов
import 'dart:io'; // Для File
import 'photo_looking_screen.dart';

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
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _getSizeOfImagesAndExif(context), // Вызываем новую асинхронную функцию
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
              final transformedImages = snapshot.data!;
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
                        itemBuilder: (context, index) {
                          return RawMaterialButton(
                            child: InkWell(
                              child: Ink.image(
                                image: AssetImage(transformedImages[index]['path']), // Используем путь для отображения
                                height: 300,
                                fit: BoxFit.cover,
                              ),
                            ),
                            onPressed: () {
                              context.go('/gallery/photo', extra: {
                                'urlImages': transformedImages.map((e) => e['path'] as String).toList(),
                                'index': index,
                                // Передаём геоданные (если есть)
                                'coordinates': transformedImages[index]['coordinates'],
                                // Опционально: передать путь к временному файлу, если PhotoLookingScreen будет его использовать напрямую
                                // 'tempFilePath': transformedImages[index]['tempFilePath'],
                              });
                            },
                          );
                        },
                        itemCount: transformedImages.length,
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

  // Изменяем функцию для загрузки изображений, получения размера и EXIF
  Future<List<Map<String, dynamic>>> _getSizeOfImagesAndExif(BuildContext context) async {
    final urlImages = [
      'assets/Pictures/image1.png', // Убедись, что файлы существуют
      'assets/Pictures/image2.png',
      'assets/Pictures/image3.png',
      'assets/Pictures/image4.jpg',
      'assets/Pictures/image5.jpg',
      'assets/Pictures/image6.jpg',
      'assets/Pictures/image7.jpg',
    ];

    List<Map<String, dynamic>> transformedImages = [];
    for (int i = 0; i < urlImages.length; i++) {
      final imageObject = <String, dynamic>{};
      try {
        // 1. Загружаем байты изображения из ассетов
        ByteData byteData = await rootBundle.load(urlImages[i]);
        Uint8List bytes = byteData.buffer.asUint8List();

        // 2. Сохраняем путь и размер
        imageObject['path'] = urlImages[i];
        imageObject['size'] = bytes.lengthInBytes;

        // 3. Создаём временный файл
        final tempDir = await getTemporaryDirectory();
        final tempFile = File('${tempDir.path}/temp_image_${i}_${DateTime.now().millisecondsSinceEpoch}.jpg'); // Добавим время, чтобы имена не совпадали
        await tempFile.writeAsBytes(bytes);

        // 4. Извлекаем EXIF данные через native_exif
        Exif? exifInstance = await Exif.fromPath(tempFile.path);
        if (exifInstance != null) {
          // Извлекаем геоданные
          ExifLatLong? coordinates = await exifInstance.getLatLong();
          imageObject['coordinates'] = coordinates; // Добавляем координаты в объект

          // Опционально: закрываем exifInstance, если не планируешь использовать его снова
          await exifInstance.close();
        } else {
          imageObject['coordinates'] = null;
        }

        // Сохраняем путь к временному файлу, если он понадобится позже (например, для редактирования)
        // imageObject['tempFilePath'] = tempFile.path;

      } catch (e, stack) {
        // Обработка ошибок при загрузке, сохранении или парсинге EXIF
        debugPrint('Ошибка при обработке ${urlImages[i]}: $e');
        debugPrintStack(stackTrace: stack);
        imageObject['coordinates'] = null; // В случае ошибки, координат нет
      }
      transformedImages.add(imageObject);
    }
    return transformedImages;
  }
}