// photo_looking_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// import 'package:native_exif/native_exif.dart'; // Больше не нужен здесь
import 'package:latlong2/latlong.dart'; // Импортируем LatLng
import 'map_photos.dart'; // Путь к файлу
import 'map_screen_single_photo.dart'; // Путь к файлу

class PhotoLookingScreen extends StatelessWidget {
  const PhotoLookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = GoRouterState.of(context);
    final extraData = state.extra;

    List<String>? urlImages;
    int? index;
    // --- Меняем тип с ExifLatLong? на LatLng? ---
    LatLng? coordinates;
    // --- Конец изменения ---

    if (extraData != null && extraData is Map<String, dynamic>) {
      urlImages = (extraData['urlImages'] as List?)?.cast<String>();
      index = extraData['index'] as int?;
      // --- Обновляем приведение типа ---
      coordinates = extraData['coordinates'] as LatLng?;
      // --- Конец обновления ---
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
      // --- LatLng также имеет поля latitude и longitude ---
      gpsInfo = "Широта: ${coordinates.latitude}, Долгота: ${coordinates.longitude}";
      // --- Конец обновления ---
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
                  // --- Убираем конвертацию, coordinates уже LatLng ---
                  // final latLng = LatLng(coordinates!.latitude, coordinates.longitude);
                  debugPrint('Открыть на карте: ${coordinates?.latitude}, ${coordinates?.longitude}'); // coordinates не может быть null здесь из-за if
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        // builder: (context) => MapSinglePhotoScreen(coordinates: latLng), // Передаём coordinates напрямую
                        builder: (context) => MapSinglePhotoScreen(coordinates: coordinates!), // coordinates не может быть null здесь из-за if
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