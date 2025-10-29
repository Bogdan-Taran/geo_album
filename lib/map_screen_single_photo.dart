import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapSinglePhotoScreen extends StatelessWidget{
  const MapSinglePhotoScreen({super.key, required this.coordinates});

  final LatLng coordinates;

  @override
  Widget build(BuildContext context) {

    final List<Marker> markers = [
      Marker(
        width: 80,
        height: 80,
        point: coordinates,  // переданные координаты
        child: const Icon(
          Icons.location_on,  //иконка метки
          color: Colors.red,
          size: 48,
        ),
      )
    ];


    return Scaffold(
      appBar: AppBar(
        title: Text('Карта'),
      ),
      body: FlutterMap(
          options: MapOptions(
            center: coordinates,
            zoom: 15.0,
            interactionOptions: InteractionOptions(
              flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
              subdomains: ['a', 'b', 'c'],
            ),
            MarkerLayer(markers: markers),
          ]
      ),
    );


  }
}