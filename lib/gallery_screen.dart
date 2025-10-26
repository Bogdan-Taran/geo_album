import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
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
          future: _getSizeOfImages(), // Вызываем асинхронную функцию
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Показываем индикатор загрузки, пока данные загружаются
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              // Показываем ошибку, если она произошла
              return Center(child: Text('Ошибка: ${snapshot.error}'));
            } else if (snapshot.hasData) {
              // Данные успешно загружены, строим GridView
              final transformedImages = snapshot.data!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                      decoration: const BoxDecoration(
                        color: Colors.white,
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
                                image: AssetImage(transformedImages[index]['path']), // Исправлено
                                height: 300,
                                fit: BoxFit.cover,
                              ),
                            ),
                            onPressed: () {
                              context.go('/gallery/photo', extra: {
                                'urlImages': transformedImages.map((e) => e['path'] as String).toList(),
                                'index': index,
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
              // Если данных нет, но ошибки тоже нет
              return const Center(child: Text('Нет изображений'));
            }
          },
        ),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _getSizeOfImages() async {
    final urlImages = [
      'assets/Pictures/image1.png',
      'assets/Pictures/image2.png',
      'assets/Pictures/image3.png',
      'assets/Pictures/image4.jpg',
    ];

    List<Map<String, dynamic>> transformedImages = [];
    for (int i = 0; i < urlImages.length; i++) {
      final imageObject = <String, dynamic>{};
      await rootBundle.load(urlImages[i]).then((value) {
        imageObject['path'] = urlImages[i];
        imageObject['size'] = value.lengthInBytes;
      });
      transformedImages.add(imageObject);
    }
    return transformedImages;
  }
}

