import 'package:exif/exif.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const backColorScreens = Color(0xff100F14);


class PhotoLookingScreen extends StatelessWidget {
  const PhotoLookingScreen({super.key});

  @override
  Widget build(BuildContext context) {

    // Получаем данные из state.extra
    final state = GoRouterState.of(context);
    final extraData = state.extra;

    List<String>? urlImages;
    int? index;
    Map<String, IfdTag>? exifData;  //type for exif data

    if (extraData != null && extraData is Map<String, dynamic>) {
      urlImages = (extraData['urlImages'] as List?)?.cast<String>();
      index = extraData['index'] as int?;
      exifData = extraData['exifData'] as Map<String, IfdTag>?;   //get exif data
    }

    // check if data
    if (urlImages == null || index == null || index >= urlImages.length) {
      return Scaffold(
        backgroundColor: backColorScreens,
        appBar: AppBar(title: Text("Ошибка")),
        body: Center(child: Text("Не удалось загрузить изображение.", style: TextStyle(color: Colors.white),)),
      );
    }

    //extract geoData from EXIF

    String? gpsInfo = 'Геоданные отсутствуют или недоступны';
    if(exifData != null){
      IfdTag? latTag = exifData['GPS GPSLatitude'];
      IfdTag? latRefTag = exifData['GPS GPSLatitudeRef'];
      IfdTag? lonTag = exifData['GPS GPSLongtitude'];
      IfdTag? lonRefTag = exifData['GPS GPSLatitudeRef'];

      if(latTag != null && lonTag != null && latRefTag != null && lonRefTag != null){
        try{
          if (latTag.values is List && lonTag.values is List) {
            List<dynamic> latValues = latTag.values as List;
            List<dynamic> lonValues = lonTag.values as List;
            String latRef = latRefTag.printable ?? "";
            String lonRef = lonRefTag.printable ?? "";

            //convert DMC to decimal degrees
            double lat = _convertDMSToDD(latValues[0], latValues[1], latValues[2], latRef);
            double lon = _convertDMSToDD(lonValues[0], lonValues[1], lonValues[2], lonRef);

            gpsInfo = "Широта: $lat, Долгота: $lon";
          } else {
            double? lat = latTag.printable != null ? double.tryParse(latTag.printable!) : null;
            double? lon = lonTag.printable != null ? double.tryParse(lonTag.printable!) : null;
            if (lat != null && lon != null) {
              gpsInfo = "Широта: $lat, Долгота: $lon";
            }
          }
        } catch (e) {
          debugPrint("Ошибка при парсинге GPS данных: $e");
          gpsInfo = "Ошибка при чтении геоданных.";
        }
      }
    }
    // end of extracting geodata

    // Теперь используем urlImages и index
    return Scaffold(
      backgroundColor: backColorScreens,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white, //change your color here
        ),
        backgroundColor: backColorScreens,
        title: Text('Фото ${index + 1}', style: TextStyle(color: Colors.white),),
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
            // show geo data
            Container(
              padding: EdgeInsets.all(16),
              child: Text(
                'Геоданные: $gpsInfo',
                style: TextStyle(fontSize: 14),
              ),
            ),
            if (gpsInfo != "Геоданные отсутствуют или недоступны." && !gpsInfo.contains("Ошибка"))
              ElevatedButton(
                onPressed: () {
                  // TODO: Реализовать открытие карты (например, с помощью url_launcher)
                  // final uri = Uri.parse('geo:$lat,$lon');
                  // await launchUrl(uri);
                },
                child: const Text('Открыть на карте'),
              ),
          ],
        ),
      )
    );
  }

  double _convertDMSToDD(dynamic degrees, dynamic minutes, dynamic seconds, String ref){
    double dd = degrees.toDouble() + minutes.toDouble() / 60 + seconds.toDouble() / 3600;
    if(ref == "S" || ref == "W"){
      dd = dd * -1;
    }
    return dd;
  }
}
