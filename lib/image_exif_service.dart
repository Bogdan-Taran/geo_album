// image_exif_service.dart
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart'; // Для rootBundle
import 'package:native_exif/native_exif.dart';
import 'package:path_provider/path_provider.dart';
import 'package:latlong2/latlong.dart';

class ImageExifService {
  // --- Переносим список изображений сюда как статическую константу ---
  static const List<String> imagePaths = [
    'assets/Pictures/image1.jpg',
  ];

  // --- Конец переноса ---

  // Метод для загрузки всех изображений и извлечения геоданных
  static Future<List<ImageWithLocation>> loadAllImagesWithLocation() async {
    // Используем статический список imagePaths
    List<ImageWithLocation> imagesWithLocation = [];
    for (int i = 0; i < imagePaths.length; i++) {
      try {
        // Загружаем байты
        ByteData byteData = await rootBundle.load(imagePaths[i]);
        Uint8List bytes = byteData.buffer.asUint8List();

        // Создаём временный файл
        final tempDir = await getTemporaryDirectory();
        final tempFile = File(
          '${tempDir.path}/temp_image_${i}_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        await tempFile.writeAsBytes(bytes);

        // Извлекаем EXIF
        Exif? exifInstance = await Exif.fromPath(tempFile.path);
        if (exifInstance != null) {
          ExifLatLong? coordinates = await exifInstance.getLatLong();
          await exifInstance.close(); // Закрываем экземпляр

          if (coordinates != null) {
            imagesWithLocation.add(
              ImageWithLocation(
                imagePath: imagePaths[i], // Используем путь из константы
                location: LatLng(coordinates.latitude, coordinates.longitude),
                tempFilePath: tempFile.path,
              ),
            );
          } else {
            imagesWithLocation.add(
              ImageWithLocation(
                imagePath: imagePaths[i],
                location: null,
                tempFilePath: tempFile.path,
              ),
            );
          }
        } else {
          imagesWithLocation.add(
            ImageWithLocation(imagePath: imagePaths[i], location: null),
          );
        }
      } catch (e, stack) {
        debugPrint('Ошибка при обработке ${imagePaths[i]}: $e');
        debugPrintStack(stackTrace: stack);
        imagesWithLocation.add(
          ImageWithLocation(imagePath: imagePaths[i], location: null),
        );
      }
    }
    return imagesWithLocation;
  }
}

class ImageWithLocation {
  final String imagePath;
  final LatLng? location;
  final String? tempFilePath;

  const ImageWithLocation({
    required this.imagePath,
    this.location,
    this.tempFilePath,
  });
}
