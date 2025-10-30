// map_photos.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
// Импортируем наш сервис
import 'image_exif_service.dart';

class MapPhotosScreen extends StatelessWidget {
  const MapPhotosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Используем StatefulWidget для управления состоянием оверлея
    return _MapPhotosScreenStatefulWidget();
  }
}

class _MapPhotosScreenStatefulWidget extends StatefulWidget {
  const _MapPhotosScreenStatefulWidget();

  @override
  State<_MapPhotosScreenStatefulWidget> createState() => _MapPhotosScreenState();
}

class _MapPhotosScreenState extends State<_MapPhotosScreenStatefulWidget> {
  // Хранит информацию о выбранном изображении
  ImageWithLocation? _selectedImage;

  // Флаг, показывающий, отображается ли оверлей
  bool _isOverlayVisible = false;

  // Обработчик нажатия на маркер
  void _onMarkerTapped(ImageWithLocation image) {
    setState(() {
      _selectedImage = image;
      _isOverlayVisible = true;
    });
  }

  // Обработчик нажатия на кнопку "убрать"
  void _onRemoveButtonPressed() {
    setState(() {
      _isOverlayVisible = false;
      _selectedImage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Карта всех фото'),
      ),
      body: FutureBuilder<List<ImageWithLocation>>(
        future: ImageExifService.loadAllImagesWithLocation(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            debugPrint('Ошибка в MapPhotosScreen: ${snapshot.error}');
            return Center(child: Text('Ошибка: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final allImagesData = snapshot.data!;
            final imagesWithCoords = allImagesData.where((image) => image.location != null).toList();

            if (imagesWithCoords.isEmpty) {
              return const Center(
                child: Text('Нет изображений с геоданными для отображения на карте.'),
              );
            }

            // Создаём список маркеров
            List<Marker> markers = imagesWithCoords.asMap().entries.map((entry) {
              int index = entry.key;
              ImageWithLocation image = entry.value;
              return Marker(
                width: 40,
                height: 40,
                point: image.location!,
                child: GestureDetector(
                  onTap: () {
                    _onMarkerTapped(image); // Вызываем обработчик при нажатии
                  },
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.blue,
                    size: 32,
                  ),
                ),
              );
            }).toList();

            // Вычисляем границы для отображения всех маркеров
            List<LatLng> points = imagesWithCoords.map((e) => e.location!).toList();
            LatLngBounds? bounds;
            try {
              bounds = LatLngBounds.fromPoints(points);
            } catch (e) {
              debugPrint('Ошибка вычисления границ: $e');
              if (points.isNotEmpty) {
                bounds = LatLngBounds(points[0], points[0]);
              }
            }

            LatLng center = bounds != null ? bounds.center : const LatLng(0, 0);
            double zoom = 2.0;
            if (bounds != null) {
              zoom = 10.0;
            }

            // Возвращаем Stack, чтобы размещать оверлей поверх карты
            return Stack(
              children: [
                // Карта
                FlutterMap(
                  options: MapOptions(
                    center: center,
                    zoom: zoom,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                      subdomains: const ['a', 'b', 'c'],
                    ),
                    MarkerLayer(
                      markers: markers,
                    ),
                  ],
                ),
                // Условно отображаемый оверлей
                if (_isOverlayVisible && _selectedImage != null)
                  Positioned(
                    top: 0, // Прижимаем к верху экрана
                    left: 0,
                    right: 0,
                    child: Container(
                      // Высота оверлея - примерно высота изображения + отступы
                      height: 150.0,
                      // Добавим фон для контента оверлея
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
                      ),
                      child: Row(
                        children: [
                          // Кнопка "убрать" слева
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: _onRemoveButtonPressed, // Вызываем обработчик
                            ),
                          ),
                          // Изображение справа от кнопки
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Image.asset(
                                _selectedImage!.imagePath, // Отображаем выбранное изображение
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          } else {
            return const Center(child: Text('Нет данных.'));
          }
        },
      ),
    );
  }
}