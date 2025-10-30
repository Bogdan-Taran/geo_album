# geo_album

A mobile application for viewing photos on a map (made for **Volga-IT**).

The app acts as a smart gallery that lets you switch to an interactive map and see **where your photos were taken** — as long as they contain **geotagged EXIF data**.

![App Preview](https://via.placeholder.com/300x600?text=Map+%2B+Gallery+Preview) <!-- Replace with real screenshot later -->

## 📸 Features

- 🗺️ Display geotagged photos on an interactive map (powered by [Flutter Map](https://pub.dev/packages/flutter_map))
- 🖼️ Browse images in a clean, scrollable gallery view
- 📍 Tap any photo on the map to view it in full screen
- 📂 Local asset-based image loading (manual setup required)

## ⚙️ How to Add Your Own Photos

> ⚠️ **Note**: The app currently **does not access your device’s photo gallery**. All images must be added manually as assets.

### Step 1: Add images to the assets folder
Place your geotagged images (JPEG/PNG) into:
assets/Pictures/


### Step 2: Register image paths
Open `lib/image_exif_service.dart` and update the `imagePaths` list:

```dart
static const List<String> imagePaths = [
  'assets/Pictures/image1.jpg',
  'assets/Pictures/image2.jpg',
  'assets/Pictures/vacation_photo.png',
  // Add more paths here
];
```

Tip: Only images with valid GPS EXIF metadata will appear on the map. 
Use tools like ExifTool to verify or edit geotags. 

### Tech Stack
Framework: Flutter
Map: flutter_map + OpenStreetMap tiles
EXIF Parsing: Custom parser using dart:typed_data (extracts GPS coordinates from image bytes)
State Management: Provider


### Known Limitations
❌ No access to device photo library (manual asset loading only)
❌ Only static image list (no dynamic file scanning)
❌ PNG support for EXIF is limited (JPEG recommended)
❌ No offline map caching
