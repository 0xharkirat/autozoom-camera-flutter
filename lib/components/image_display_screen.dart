import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:test/utils/permissions.dart';

class ImageDisplayScreen extends StatelessWidget {
  const ImageDisplayScreen({super.key, required this.displayPath});

  final String displayPath;

  void _saveImage(BuildContext context) async {
    bool hasPermission = await PermissionHandler.checkStoragePermission();

    if (hasPermission) {
      // final dir = await getTemporaryDirectory();
      final timestamp = DateTime.now();
      var newFormat = DateFormat("yMMdd_HmsSSS"); // YYYYMMDD_HHMMSS
      String updatedDt = newFormat.format(timestamp);

      final imagePath = '/storage/emulated/0/DCIM/Camera/IMG_$updatedDt.jpg';
      

      final File imageFile = File(displayPath);

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
        print('Image saved successfully: $imagePath');
        // You may also want to show a snackbar or a toast to indicate successful save
      } catch (e) {
        print('Error saving image: $e');
        // Handle error if necessary
      }

      // if (Platform.isIOS) {
      //   final documents = await getApplicationDocumentsDirectory();
      //   file = File('${documents.path}/live_darbar_$timestamp.mp3');
      //   // print(documents.path);
      // } else {
      //   file = File('/storage/emulated/0/Music/live_darbar_$timestamp.mp3');
      // }
    }

    // cancel the stream
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Display the picture"),
      ),
      body: Center(child: Image.file(File(displayPath))),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _saveImage(context);
        },
        child: Icon(Icons.save_alt),
      ),
    );
  }
}
