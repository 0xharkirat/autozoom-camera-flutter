import 'dart:developer';
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:test/components/boxes.dart';
import 'package:test/components/image_display_screen.dart';
import 'package:tflite/tflite.dart';

class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({super.key, required this.camera});

  final CameraDescription camera;

  @override
  State<TakePictureScreen> createState() => _TakePictureScreenState();
}

class _TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  late String label;
  bool isDetecting = false;

  var x, y, w, h = 0;

  List<dynamic> _recognitions = [];
  int _imageHeight = 0;
  int _imageWidth = 0;

  _init() {
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.medium,
    );

    int imageCount = 0;
    label = "";

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller
        .initialize()
        .then((value) => _controller.startImageStream((image) {
              
              if (!isDetecting) {
                
                
                imageCount++;
                if (imageCount % 10 == 0) {
                  isDetecting = true;
                  imageCount = 0;
                  _objectDetector(image);
                }
              }
            }));
  }

  @override
  void initState() {
    super.initState();
    _init();
    _initTFLite();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
    Tflite.close();
  }

  _initTFLite() async {
    await Tflite.loadModel(
        model: "assets/ssd_mobilenet.tflite",
        labels: "assets/ssd_mobilenet.txt",
        isAsset: true,
        numThreads: 1,
        useGpuDelegate: false);
  }

  _objectDetector(CameraImage img) async {
    Tflite.detectObjectOnFrame(
      bytesList: img.planes.map((plane) {
        return plane.bytes;
      }).toList(),
      model: "SSDMobileNet",
      imageHeight: img.height,
      imageWidth: img.width,
      imageMean: 127.5,
      imageStd: 127.5,
      numResultsPerClass: 1,
      threshold: 0.4,
    ).then((recognitions) {
      log("$recognitions");

      setRecognitions(recognitions, img.height, img.width);

      isDetecting = false;
    });
  }

  setRecognitions(recognitions, imageHeight, imageWidth) {
    setState(() {
      _recognitions = recognitions;
      _imageHeight = imageHeight;
      _imageWidth = imageWidth;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(title: const Text('Take a picture')),
      // You must wait until the controller is initialized before displaying the
      // camera preview. Use a FutureBuilder to display a loading spinner until the
      // controller has finished initializing.
      body: FutureBuilder(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                CameraPreview(_controller),
                Boxes(
                  results: _recognitions,
                  previewH: math.max(_imageHeight, _imageWidth),
                  previewW: math.min(_imageHeight, _imageWidth),
                  screenH: screen.height,
                  screenW: screen.width,
                )
              ],
            );
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
