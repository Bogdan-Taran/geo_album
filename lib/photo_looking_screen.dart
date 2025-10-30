// photo_looking_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// import 'package:native_exif/native_exif.dart'; // Больше не нужен здесь
import 'package:latlong2/latlong.dart'; // Импортируем LatLng
import 'package:geocoding/geocoding.dart'; // Импортируем geocoding
import 'map_photos.dart'; // Путь к файлу
// Убираем импорт map_screen_single_photo.dart, так как больше не используем его напрямую
// import 'map_screen_single_photo.dart'; // Путь к файлу

const whiteColor = Colors.white;
const blackColor = Colors.black;
const backColorScreens = Color(0xff100F14);

class PhotoLookingScreen extends StatelessWidget {
  const PhotoLookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = GoRouterState.of(context);
    final extraData = state.extra;

    List<String>? urlImages;
    int? index;
    LatLng? coordinates;

    if (extraData != null && extraData is Map<String, dynamic>) {
      urlImages = (extraData['urlImages'] as List?)?.cast<String>();
      index = extraData['index'] as int?;
      coordinates = extraData['coordinates'] as LatLng?;
    }

    if (urlImages == null || index == null || index >= urlImages.length) {
      return Scaffold(
        appBar: AppBar(title: const Text("Ошибка")),
        body: const Center(child: Text("Не удалось загрузить изображение или данные.")),
      );
    }

    // --- Логика получения адреса ---
    Widget addressWidget = FutureBuilder<String>(
      future: coordinates != null
          ? _getAddressFromCoordinates(coordinates!)
          : Future.value("Геоданные отсутствуют."),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Получение адреса...',
              style: TextStyle(fontSize: 14, color: Colors.white),
            ),
          );
        } else if (snapshot.hasError) {
          debugPrint('Ошибка геокодирования: ${snapshot.error}');
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Ошибка получения адреса: ${snapshot.error}',
              style: const TextStyle(fontSize: 14, color: Colors.red),
            ),
          );
        } else {
          String address = snapshot.data ?? "Адрес не найден.";
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Адрес: $address',
              style: const TextStyle(fontSize: 14, color: Colors.white),
            ),
          );
        }
      },
    );
    // --- Конец логики получения адреса ---

    String gpsInfo = "отсутствуют или недоступны.";
    if (coordinates != null) {
      gpsInfo = "Широта: ${coordinates.latitude}, Долгота: ${coordinates.longitude}";
    }

    return Scaffold(
      backgroundColor: backColorScreens,
      appBar: AppBar(
        title: Text('Фото ${index + 1}', style: const TextStyle(color: whiteColor)),
        backgroundColor: backColorScreens,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: Image.asset(
                urlImages[index],
                fit: BoxFit.contain,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Геоданные: $gpsInfo',
                style: const TextStyle(fontSize: 14, color: Colors.white),
              ),
            ),
            addressWidget,
            if (coordinates != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: 200,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: <Color>[
                        Color(0xcb1b1b1b),
                        Color(0xcb2b2b2b),
                        Color(0xcb222222),
                      ],
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                    ),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(25),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(25),
                      // --- Изменяем onTap ---
                      onTap: () {
                        debugPrint('Открыть на карте: ${coordinates?.latitude}, ${coordinates?.longitude}');
                        // Используем go_router для навигации и передачи координат
                        // Путь может отличаться, если ты добавлял маршрут в app_routings.dart
                        // context.push('/map_with_selected_marker', extra: coordinates);
                        // Или передаём через go, если маршрут вложен или используешь StatefulShell
                        // context.go('/map_with_selected_marker', extra: coordinates);

                        // Если у тебя нет отдельного маршрута, просто передай в MapPhotosScreen через extra
                        // Убедись, что MapPhotosScreen может получить это значение
                        context.go('/map', extra: coordinates); // Предполагаем, что маршрут '/map' ведёт в MapPhotosScreen
                      },
                      // --- Конец изменения onTap ---
                      child: const Center(
                        child: Text(
                          'Открыть на карте',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<String> _getAddressFromCoordinates(LatLng coordinates) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        coordinates.latitude,
        coordinates.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        List<String> addressParts = [
          if (place.name?.isNotEmpty == true) place.name!,
          if (place.locality?.isNotEmpty == true) place.locality!,
          if (place.administrativeArea?.isNotEmpty == true) place.administrativeArea!,
          if (place.country?.isNotEmpty == true) place.country!,
        ];
        return addressParts.join(', ');
      } else {
        return "Адрес не найден.";
      }
    } catch (e) {
      debugPrint('Ошибка при геокодировании: $e');
      rethrow;
    }
  }
}
