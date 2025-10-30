// photo_looking_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// import 'package:native_exif/native_exif.dart'; // Больше не нужен здесь
import 'package:latlong2/latlong.dart'; // Импортируем LatLng
import 'map_photos.dart'; // Путь к файлу
import 'map_screen_single_photo.dart'; // Путь к файлу

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
      backgroundColor: backColorScreens,
      appBar: AppBar(
        title: Text('Фото ${index + 1}', style: TextStyle(color: whiteColor)),
        backgroundColor: backColorScreens,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        // добавляем прокрутку, если контент большой
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
                style: const TextStyle(fontSize: 14, color: Colors.white),
              ),
            ),
            // кнопка для открытия карты
            if (coordinates != null) // Показываем кнопку только если координаты есть
              Padding(
                padding: const EdgeInsets.all(8.0), // Добавим отступ
                child: Container(
                  width: 200, // Установи желаемую ширину
                  height: 50, // Установи желаемую высоту
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: <Color>[
                        Color(0xcb1b1b1b),
                        Color(0xcb2b2b2b),
                        Color(0xcb222222),
                      ],
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                    ),
                    borderRadius: BorderRadius.circular(25), // Закругление краёв
                  ),
                  child: Material( // Оберни в Material для правильной отрисовки Ink
                    color: Colors.transparent, // Прозрачный цвет, чтобы градиент был виден
                    borderRadius: BorderRadius.circular(25), // То же закругление
                    child: InkWell(
                      borderRadius: BorderRadius.circular(25), // То же закругление для InkWell
                      // --- Вызываем ту же логику, что была в onPressed ---
                      onTap: () {
                        debugPrint('Открыть на карте: ${coordinates?.latitude}, ${coordinates?.longitude}');
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MapSinglePhotoScreen(coordinates: coordinates!), // coordinates не может быть null здесь из-за if
                            )
                        );
                      },
                      // --- Конец изменения onTap ---
                      child: const Center( // Центрируем текст внутри кнопки
                        child: Text(
                          'Открыть на карте', // Текст кнопки
                          style: TextStyle(
                            color: Colors.white, // Цвет текста
                            fontSize: 16, // Размер текста
                            fontWeight: FontWeight.bold, // Жирность текста (опционально)
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
}