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
        body: const Center(child: Text("Не удалось загрузить изображение или данные.")),
      );
    }

    // формируем геоданные
    String gpsInfo = "отсутствуют или недоступны.";
    if (coordinates != null) {
      // ExifLatLong имеет поля latitude и longitude как double
      gpsInfo = "Широта: ${coordinates.latitude}, Долгота: ${coordinates.longitude}";
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
            if (coordinates != null) // Показываем кнопку только если координаты есть
              ElevatedButton(
                onPressed: () {
                  // конвертим exiflatlong в latlong

                  final latLng = LatLng(coordinates!.latitude, coordinates.longitude);
                  debugPrint('Открыть на карте: ${coordinates?.latitude}, ${coordinates?.longitude}');
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MapSinglePhotoScreen(coordinates: latLng),
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