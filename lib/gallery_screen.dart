import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'photo_looking_screen.dart';
import 'package:exif/exif.dart';


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
          future: _getSizeOfImagesAndExif(), // Вызываем асинхронную функцию
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Показываем индикатор загрузки, пока данные загружаются
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              // Показываем ошибку, если она произошла
              debugPrint('Ошибка в GalleryScreen: ${snapshot.error}');
              if(snapshot.error != null){
                debugPrint(snapshot.error.toString());
              }
              return Center(child: Text('Ошибка: ${snapshot.error}'),);
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
                                image: AssetImage(transformedImages[index]['path']),
                                height: 300,
                                fit: BoxFit.cover,
                              ),
                            ),
                            onPressed: () {
                              context.go('/gallery/photo', extra: {
                                'urlImages': transformedImages.map((e) => e['path'] as String).toList(),
                                'index': index,
                                'exifData': transformedImages[index]['exif'] as Map<String, IfdTag>?,
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

  //функция для получения данных из фотографий
  Future<List<Map<String, dynamic>>> _getSizeOfImagesAndExif() async {
    final urlImages = [
      'assets/Pictures/image1.png',
      'assets/Pictures/image2.png',
      'assets/Pictures/image3.png',
      'assets/Pictures/image4.jpg',
    ];

    List<Map<String, dynamic>> transformedImages = [];
    for (int i = 0; i < urlImages.length; i++) {
      final imageObject = <String, dynamic>{};
      try{
        //load bytes from image
        ByteData byteData = await rootBundle.load(urlImages[i]);
        Uint8List bytes = byteData.buffer.asUint8List();

        //save path and size
        imageObject['path'] = urlImages[i];
        imageObject['size'] = bytes.lengthInBytes;

        //extract exif data
        Map<String, IfdTag>? exifData = await _extractExif(bytes);
        imageObject['exif'] = exifData;
      } catch (e, stack){
        debugPrint('Ошибка при обработке ${urlImages[i]}: $e');
//        debugPrintStack(stack: stack);
        imageObject['exif'] = null;
      }
      transformedImages.add(imageObject);
    }
    return transformedImages;
  }

  //function to extract EXIF from bytes

  Future<Map<String, IfdTag>?> _extractExif(Uint8List bytes) async {
    try{
      //use exif library
      Map<String, IfdTag>? exif = await readExifFromBytes(bytes);
      return exif;
    } catch(e){
      debugPrint('Ошибка при извлечении EXIF: $e');
      return null;  //return null if there any error
    }
  }

}

