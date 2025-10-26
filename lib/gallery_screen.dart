import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const _photos = [
  'photo1',
  'photo2',
  'photo3',
  'photo4',
  'photo5',
];

class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context){
    return  Center(
      child: ListView.separated(
        itemBuilder: (context, index){
          return ListTile(
            title: Text(_photos[index]),
            onTap: () {
              context.go('/photo');
            },
          );
        },
        separatorBuilder: (context, index){
          return const Divider();
        },
        itemCount: _photos.length,
      )
    );
  }

}