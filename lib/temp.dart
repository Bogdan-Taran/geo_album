//Отлично. Метка на карте по казываетcя. Теперь нужно чтобы на карте со всеми метками (map_photos) показывались метки всех фотографий (у которых они есть).

gallery_screen:import 'package:flutter/material.dart';
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
          future: _getSizeOfImagesAndExif(context),
          // Вызываем новую асинхронную функцию
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 20),
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
                                image: AssetImage(
                                    transformedImages[index]['path']),
                                // Используем путь для отображения
                                height: 300,
                                fit: BoxFit.cover,
                              ),
                            ),
                            onPressed: () {
                              context.go('/gallery/photo', extra: {
                                'urlImages': transformedImages.map((
                                    e) => e['path'] as String).toList(),
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
  Future<List<Map<String, dynamic>>> _getSizeOfImagesAndExif(
      BuildContext context) async {
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
        final tempFile = File('${tempDir.path}/temp_image_${i}_${DateTime
            .now()
            .millisecondsSinceEpoch}.jpg'); // Добавим время, чтобы имена не совпадали
        await tempFile.writeAsBytes(bytes);

// 4. Извлекаем EXIF данные через native_exif
        Exif? exifInstance = await Exif.fromPath(tempFile.path);
        if (exifInstance != null) {
// Извлекаем геоданные
          ExifLatLong? coordinates = await exifInstance.getLatLong();
          imageObject['coordinates'] =
              coordinates; // Добавляем координаты в объект

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

app_routings:import 'package:go_router/go_router.dart';
import '/gallery_screen.dart';
import '/photo_looking_screen.dart';
import '/map_photos.dart';
import '/root_screen.dart';

final router = GoRouter(
  initialLocation: '/gallery',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          RootScreen(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch( //index 0 - Галерея
          routes: [
            GoRoute(
                path: '/gallery',
                builder: (context, state) =>
                const GalleryScreen(title: 'Галерея',),
                routes: [
                  GoRoute(
                    path: 'photo',
                    builder: (context, state) => const PhotoLookingScreen(),
                  ),
                ]
            ),
          ],
        ),

        StatefulShellBranch( //index 1
          routes: [
            GoRoute(
              path: '/map',
              builder: (context, state) => const MapPhotosScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);

map_screen_single_photo
import
'
package:flutter/material.dart
';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapSinglePhotoScreen extends StatelessWidget {
  const MapSinglePhotoScreen({super.key, required this.coordinates});

  final LatLng coordinates;

  @override
  Widget build(BuildContext context) {
    final List<Marker> markers = [
      Marker(
        width: 80,
        height: 80,
        point: coordinates, // переданные координаты
        child: const Icon(
          Icons.location_on, //иконка метки
          color: Colors.red,
          size: 48,
        ),
      )
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Карта'),
      ),
      body: FlutterMap(
          options: MapOptions(
            center: coordinates,
            zoom: 15.0,
            interactionOptions: InteractionOptions(
              flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
              subdomains: ['a', 'b', 'c'],
            ),
            MarkerLayer(markers: markers),
          ]
      ),
    );
  }
}

map_photos:import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapPhotosScreen extends StatelessWidget {
  const MapPhotosScreen({super.key,});


  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Это экран просмотра карты'),
    );
  }
}

photo_looking_screen:
// photo_looking_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:native_exif/native_exif.dart'; // Импортируем native_exif
import 'package:latlong2/latlong.dart';
import 'package:geo_album/map_photos.dart';
import 'package:geo_album/map_screen_single_photo.dart';

class PhotoLookingScreen extends StatelessWidget {
  const PhotoLookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = GoRouterState.of(context);
    final extraData = state.extra;

    List<String>? urlImages;
    int? index;
    ExifLatLong? coordinates; // Тип для геоданных

    if (extraData != null && extraData is Map<String, dynamic>) {
      urlImages = (extraData['urlImages'] as List?)?.cast<String>();
      index = extraData['index'] as int?;
// Получаем координаты
      coordinates = extraData['coordinates'] as ExifLatLong?;
    }

    if (urlImages == null || index == null || index >= urlImages.length) {
      return Scaffold(
        appBar: AppBar(title: const Text("Ошибка")),
        body: const Center(
            child: Text("Не удалось загрузить изображение или данные.")),
      );
    }

// формируем геоданные
    String gpsInfo = "отсутствуют или недоступны.";
    if (coordinates != null) {
// ExifLatLong имеет поля latitude и longitude как double
      gpsInfo =
      "Широта: ${coordinates.latitude}, Долгота: ${coordinates.longitude}";
    }
// закончили формировать геоданные

    return Scaffold(
      appBar: AppBar(
        title: Text('Фото ${index + 1}'),
      ),
      body: SingleChildScrollView( // добавляем прокрутку, если контент большой
        child: Column(
          children: [
            Center(
              child: Image.asset(
                urlImages[index],
                fit: BoxFit.contain,
              ),
            ),
// Отображаем геоданные
            Container(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Геоданные: $gpsInfo',
                style: const TextStyle(fontSize: 14, color: Colors.black),
              ),
            ),
// кнопка для открытия карты
            if (coordinates !=
                null) // Показываем кнопку только если координаты есть
              ElevatedButton(
                onPressed: () {
// конвертим exiflatlong в latlong

                  final latLng = LatLng(
                      coordinates!.latitude, coordinates.longitude);
                  debugPrint(
                      'Открыть на карте: ${coordinates?.latitude}, ${coordinates
                          ?.longitude}');
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            MapSinglePhotoScreen(coordinates: latLng),
                      )
                  );
                },
                child: const Text('Открыть на карте'),
              ),
          ],
        ),
      ),
    );
  }
}