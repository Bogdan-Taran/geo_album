// map_photos.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart'; // Добавляем для получения extra и навигации
import 'image_exif_service.dart';

const backColorScreens = Color(0xff100F14);

// Обновим StatelessWidget, чтобы он мог получать параметры из маршрута
class MapPhotosScreen extends StatelessWidget {
  const MapPhotosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Получаем координаты из extra
    final state = GoRouterState.of(context);
    final extraData = state.extra;
    LatLng? selectedCoordinatesFromPhoto;
    // Также получим urlImages и index, если они были переданы из PhotoLookingScreen
    // Предположим, что при передаче координат из PhotoLookingScreen туда же передавались urlImages и index
    // Но в предыдущем коде это не делалось. Нам нужно передать идентификатор (например, индекс или путь) фото обратно.
    // В предыдущем коде мы передавали только LatLng.
    // Для простоты, если _selectedImageFromMapTap установлен (через нажатие на маркер), используем его.
    // Если экран открыт из PhotoLookingScreen, то _selectedImageFromMapTap будет null,
    // и кнопка "Открыть полностью" не будет работать, так как мы не знаем, какое фото открыто.
    // Чтобы кнопка работала в обоих случаях (нажатие на маркер и открытие из PhotoLookingScreen),
    // нужно либо передавать больше данных из PhotoLookingScreen (path или index),
    // либо находить _selectedImageFromMapTap по координатам из extra.
    // Выберем второй путь: найдём ImageWithLocation по координатам из extra при необходимости.

    ImageWithLocation? initialSelectedImageFromPhoto;
    if (extraData != null && extraData is LatLng) {
      // Найдём ImageWithLocation по переданным координатам
      // Это нужно сделать асинхронно, но для отображения кнопки "Открыть полностью" в оверлее
      // мы можем использовать _selectedImageFromMapTap (для нажатия на маркер) или
      // специальное поле, которое будет установлено при открытии из PhotoLookingScreen.
      // Введём такое поле в State.
      // Но сначала передадим и путь/индекс из PhotoLookingScreen.
      // Пока что, просто сохраним координаты.
      selectedCoordinatesFromPhoto = extraData;
    }

    // Передаём координаты в Stateful widget
    return _MapPhotosScreenStatefulWidget(
      initialSelectedCoordinates: selectedCoordinatesFromPhoto,
      // initialImageUrl: initialImageUrlFromExtra, // Если решим передавать путь
      // initialIndex: initialIndexFromExtra,       // Если решим передавать индекс
    );
  }
}

// StatefulWidget получает координаты как параметр
class _MapPhotosScreenStatefulWidget extends StatefulWidget {
  const _MapPhotosScreenStatefulWidget({this.initialSelectedCoordinates});

  final LatLng? initialSelectedCoordinates; // Принимаем координаты

  @override
  State<_MapPhotosScreenStatefulWidget> createState() =>
      _MapPhotosScreenState();
}

class _MapPhotosScreenState extends State<_MapPhotosScreenStatefulWidget> {
  ImageWithLocation? _selectedImageFromMapTap;
  bool _isOverlayVisible = false;
  LatLng? _selectedCoordinatesFromPhoto;

  // Добавим поле для хранения ImageWithLocation, соответствующего _selectedCoordinatesFromPhoto
  ImageWithLocation? _initialImageFromPhoto;

  @override
  void initState() {
    super.initState();
    _selectedCoordinatesFromPhoto = widget.initialSelectedCoordinates;
    // Если переданы координаты из фото, попробуем найти соответствующий ImageWithLocation
    // Это можно сделать, только когда данные загружены.
    // Загрузим их снова или найдём в кэше, если он у тебя есть.
    // Пока что, просто установим флаг, что карта открыта с выделением,
    // и найдём _initialImageFromPhoto позже, в builder.
  }

  void _onMarkerTapped(ImageWithLocation image) {
    setState(() {
      _selectedImageFromMapTap = image;
      _selectedCoordinatesFromPhoto = null; // Сбрасываем координаты из фото
      _initialImageFromPhoto = null; // Сбрасываем начальное изображение
      _isOverlayVisible = true;
    });
  }

  void _onRemoveButtonPressed() {
    setState(() {
      _isOverlayVisible = false;
      _selectedImageFromMapTap = null;
    });
  }

  // Обработчик для кнопки "Открыть полностью"
  void _onOpenFullPhotoPressed(ImageWithLocation? imageToOpen) {
    if (imageToOpen != null) {
      // Найдём индекс этого изображения в общем списке
      // Это нужно для передачи в PhotoLookingScreen
      // Загрузим список снова, чтобы получить индекс
      // Или передай путь и найди индекс позже в PhotoLookingScreen
      // Для простоты, передадим весь список и путь
      // Но в go_router передача сложных списков может быть неудобна.
      // Лучше передать путь и индекс.
      // Найдём индекс:
      ImageExifService.loadAllImagesWithLocation().then((allImagesData) {
        int index = allImagesData.indexOf(imageToOpen);
        if (index != -1) {
          // Передаём список путей и индекс
          List<String> urlImages = allImagesData.map((e) => e.imagePath).toList();
          // Используем go_router для навигации обратно
          // Нам нужно вернуться к состоянию Gallery -> PhotoLookingScreen
          // Это можно сделать через context.go('/gallery/photo', extra: ...) или pop.
          // context.pop() может не подойти, если мы не на прямом пути от Gallery к MapPhotos.
          // Лучше использовать context.go('/gallery/photo', extra: ...), но нужно передать правильные данные.
          // GoRouterState.of(context).location покажет текущий путь (/map).
          // Возможно, проще использовать context.push заменяя текущий маршрут.
          // Но для go_router предпочтительнее использовать go/push с маршрутами.
          // Попробуем push.
          // В app_routings.dart маршрут '/gallery/photo' ожидает extra: {'urlImages': ..., 'index': ..., 'coordinates': ...}
          // Нам нужно сформировать это extra.
          // coordinates уже есть в imageToOpen.location
          context.push('/gallery/photo', extra: {
            'urlImages': urlImages,
            'index': index,
            'coordinates': imageToOpen.location, // Передаём LatLng
          });
        } else {
          debugPrint("Индекс изображения не найден при открытии полноэкранного просмотра.");
        }
      }).catchError((error) {
        debugPrint("Ошибка при загрузке данных для открытия фото: $error");
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backColorScreens,
      // --- Добавляем AppBar с кнопкой Назад ---
      appBar: AppBar(
        title: const Text('Карта всех фото', style: TextStyle(color: Colors.white)),
        backgroundColor: backColorScreens,
        iconTheme: const IconThemeData(color: Colors.white),
        // Добавляем кнопку назад
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // При нажатии на "назад" - закрываем текущий экран
            // context.pop() или Navigator.of(context).pop() - стандартный способ
            // GoRouter предоставляет вспомогательный метод для этого
            context.pop(); // Это аналог Navigator.pop()
          },
        ),
      ),
      // --- Конец изменения AppBar ---
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
            final imagesWithCoords = allImagesData
                .where((image) => image.location != null)
                .toList();

            // Если карта была открыта с координатами из PhotoLookingScreen,
            // найдём соответствующий ImageWithLocation здесь, в builder
            if (_selectedCoordinatesFromPhoto != null && _initialImageFromPhoto == null) {
              _initialImageFromPhoto = imagesWithCoords.firstWhere(
                    (image) => image.location!.latitude == _selectedCoordinatesFromPhoto!.latitude &&
                    image.location!.longitude == _selectedCoordinatesFromPhoto!.longitude,
                orElse: () => ImageWithLocation(imagePath: '', location: null), // Заглушка, если не найдено
              );
              // Если _initialImageFromPhoto != заглушка, можно установить _isOverlayVisible = true,
              // чтобы показать оверлей сразу при открытии из PhotoLookingScreen.
              // Но в предыдущем коде этого не было.
              // Если хочешь, можешь раскомментировать:
              // if (_initialImageFromPhoto!.location != null) {
              //   _isOverlayVisible = true;
              //   _selectedImageFromMapTap = _initialImageFromPhoto; // Используем это для оверлея
              // }
            }


            if (imagesWithCoords.isEmpty) {
              return const Center(
                child: Text(
                  'Нет изображений с геоданными для отображения на карте.',
                ),
              );
            }

            // Определяем, какой маркер выделен
            // Приоритет: нажатие на маркер на карте (_selectedImageFromMapTap)
            // Если нет нажатия, то координаты из PhotoLookingScreen (_initialImageFromPhoto)
            ImageWithLocation? highlightedImage = _selectedImageFromMapTap ?? _initialImageFromPhoto;
            LatLng? highlightedCoords = highlightedImage?.location;

            List<Marker> markers = imagesWithCoords
                .asMap()
                .entries
                .map((entry,) {
              int index = entry.key;
              ImageWithLocation image = entry.value;
              Color markerColor = Colors.blue;
              if (highlightedCoords != null &&
                  image.location!.latitude == highlightedCoords.latitude &&
                  image.location!.longitude == highlightedCoords.longitude) {
                markerColor = Colors.red;
              }

              return Marker(
                width: 40,
                height: 40,
                point: image.location!,
                child: GestureDetector(
                  onTap: () {
                    _onMarkerTapped(image);
                  },
                  child: Icon(
                    Icons.location_on,
                    color: markerColor,
                    size: 32,
                  ),
                ),
              );
            }).toList();

            LatLng? centerToUse = highlightedCoords;
            double zoomToUse = 11.0;

            if (centerToUse == null) {
              List<LatLng> points = imagesWithCoords
                  .map((e) => e.location!)
                  .toList();

              if (points.isNotEmpty) {
                try {
                  LatLngBounds bounds = LatLngBounds.fromPoints(points);
                  centerToUse = bounds.center;
                  zoomToUse = 11.0;
                } catch (e) {
                  debugPrint('Ошибка вычисления границ: $e');
                  centerToUse = points.first;
                  zoomToUse = 11.0;
                }
              } else {
                centerToUse = const LatLng(0, 0);
                zoomToUse = 2.0;
              }
            }

            return Stack(
              children: [
                FlutterMap(
                  options: MapOptions(
                    center: centerToUse,
                    zoom: zoomToUse,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                      "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                      subdomains: const ['a', 'b', 'c'],
                    ),
                    MarkerLayer(markers: markers),
                  ],
                ),
                // Оверлей для выбранного изображения
                // Используем _selectedImageFromMapTap для оверлея, так как _initialImageFromPhoto
                // открывается без оверлея (только выделенный маркер)
                if (_isOverlayVisible && _selectedImageFromMapTap != null)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Column(
                        children: [
                          SizedBox(
                            height: 300,
                            width: MediaQuery.of(context).size.width * 1,
                            child: Padding(
                              padding: const EdgeInsets.all(0.0),
                              child: Image.asset(
                                _selectedImageFromMapTap!.imagePath,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Кнопка "Открыть полностью"
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: <Color>[
                                        Color(0xcd100f14),
                                        Color(0xcb100f14),
                                        Color(0xcb222222),
                                      ],
                                      begin: Alignment.bottomLeft,
                                      end: Alignment.topRight,
                                    ),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(25),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(25),
                                      // Вызываем новый обработчик, передавая _selectedImageFromMapTap
                                      onTap: () => _onOpenFullPhotoPressed(_selectedImageFromMapTap),
                                      child: const Icon(
                                        Icons.open_in_full, // Иконка "открыть полностью"
                                        color: Colors.white,
                                        size: 36,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // Кнопка "Закрыть"
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: <Color>[
                                        Color(0xcd100f14),
                                        Color(0xcb100f14),
                                        Color(0xcb222222),
                                      ],
                                      begin: Alignment.bottomLeft,
                                      end: Alignment.topRight,
                                    ),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(25),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(25),
                                      onTap: _onRemoveButtonPressed,
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 36,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
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
