import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:test/utils/permissions.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final cameras = await availableCameras();

  final firstCamera = await cameras.first;

  runApp(
    MaterialApp(
      theme: ThemeData.dark(),
      home: TakePictureScreen(
        // Pass the appropriate camera to the TakePictureScreen widget.
        camera: firstCamera,
      ),
    ),
  );
}

class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({super.key, required this.camera});

  final CameraDescription camera;

  @override
  State<TakePictureScreen> createState() => _TakePictureScreenState();
}

class _TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.medium,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Take a picture')),
      // You must wait until the controller is initialized before displaying the
      // camera preview. Use a FutureBuilder to display a loading spinner until the
      // controller has finished initializing.
      body: FutureBuilder(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(_controller);
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            await _initializeControllerFuture;

            final image = await _controller.takePicture();

            if (!mounted) return;

            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ImageDisplayScreen(
                  displayPath: image.path,
                ),
              ),
            );
          } catch (e) {
            print(e);
          }
        },
        child: Icon(Icons.camera_alt),
      ),
    );
  }
}

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
