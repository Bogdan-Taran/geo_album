import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';

const _photos = [
  'photo1',
  'photo2',
  'photo3',
  'photo4',
  'photo5',
];

const whiteColor = Colors.white;
const blackColor = Colors.black;
const backColorScreens = Color(0xff100F14);

class GalleryScreen extends StatelessWidget {
  const GalleryScreen({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<GalleryScreen> createState() => _GalleryScreen();
}

class _GalleryScreen extends State<GalleryScreen> {
  final urlImages = [
    'assets/Pictures/image1.jpg',
    'assets/Pictures/image2.jpg',
    'assets/Pictures/image3.jpg',
    'assets/Pictures/image4.jpg',
    'assets/Pictures/image5.jpg',
    'assets/Pictures/image6.jpg',
  ];
  var transformedImages = [];

  Future<dynamic> getSizeIfImages() async {
    transformedImages = [];
    for (int i = 0; i < urlImages.length; i++) {
      final imageObject = {};
      await rootBundle.load(urlImages[i]).then((value) =>
      {
        imageObject['path'] = urlImages[i],
        imageObject['size'] = value.lengthInBytes,
      });
      transformedImages.add(imageObject);
    }
  }

  @override
  void initState() {
    getSizeIfImages();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: backColorScreens,
        centerTitle: true,
        title: Text(
          widget.title,
          style: const TextStyle(color: whiteColor),
        ),
        iconTheme: const IconThemeData(color: whiteColor),
      ),

      body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                  child: Container(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                      decoration: const BoxDecoration(
                        color: whiteColor,
                      ),
                      child: GridView.builder(
                        gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 5,
                          mainAxisSpacing: 5,
                        ),
                        itemBuilder: (context, index) {
                          return RawMaterialButton(
                            child: InkWell(
                              child: Ink.image(
                                image: AssetImage(
                                  transformedImages[index]['path']),
                                height: 300,
                                fit: BoxFit.cover,
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          GalleryWidget(
                                            urlImages: urlImages,
                                            index: index,
                                          )));
                            },
                          );
                        },
                        itemCount: transformedImages.length,
                      )))
            ],
          )),

    );
  }

}