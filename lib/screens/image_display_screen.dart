import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:intl/intl.dart';
import 'package:test/models/recognition.dart';
import 'package:test/utils/permissions.dart';

class ImageDisplayScreen extends StatelessWidget {
  const ImageDisplayScreen(
      {super.key, required this.displayPath, required this.result});

  final String displayPath;
  final Recognition? result;

  void _saveImage(BuildContext context) async {
    bool hasPermission = await PermissionHandler.checkStoragePermission();

    if (hasPermission) {
      // final dir = await getTemporaryDirectory();
      final timestamp = DateTime.now();
      var newFormat = DateFormat("yMMdd_HmsSSS"); // YYYYMMDD_HHMMSS
      String updatedDt = newFormat.format(timestamp);
      final File imageFile = File(displayPath);

      if (Platform.isIOS) {
        try {
          Uint8List bytes = imageFile.readAsBytesSync();

          final result =
              await ImageGallerySaver.saveImage(bytes.buffer.asUint8List());

          log('$result');
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              showCloseIcon: true,
              behavior: SnackBarBehavior.floating,
              content: Text('Image saved in photos.')));
          // Show a message or perform any additional actions if needed
        } catch (e) {
          log(e.toString());
        }

        // print(documents.path);
      } else {
        final imagePath = '/storage/emulated/0/DCIM/Camera/IMG_$updatedDt.jpg';
        try {
          // Copy the image file to the specified path

          await imageFile.copy(imagePath);
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              showCloseIcon: true,
              behavior: SnackBarBehavior.floating,
              content: Text("Saved at DCIM/Camera/IMG_$updatedDt.jpg")));
          // Show a message or perform any additional actions if needed
          log('Image saved successfully: $imagePath');
          // You may also want to show a snackbar or a toast to indicate successful save
        } catch (e) {
          log('Error saving image: $e');
          // Handle error if necessary
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String info = result == null
        ? "Captured Without Zooming."
        : "Object Captured: ${result!.label}, score: ${result!.score.toStringAsFixed(2)}";
    return Scaffold(
      appBar: AppBar(
        title: const Text("Image Preview"),
      ),
      body: Dialog(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        insetPadding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.file(
              File(displayPath),
            ),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(info))
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _saveImage(context);
        },
        child: const Icon(Icons.save_alt),
      ),
    );
  }
}
