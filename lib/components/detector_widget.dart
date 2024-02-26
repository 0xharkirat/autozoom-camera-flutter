import 'dart:async';
import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:test/components/box_widget.dart';
import 'package:test/models/recognition.dart';
import 'package:test/models/screen_params.dart';
import 'package:test/screens/image_display_screen.dart';
import 'package:test/service/detector_service.dart';

class DetectorWidget extends StatefulWidget {
  const DetectorWidget({super.key});

  @override
  State<DetectorWidget> createState() => _DetectorWidgetState();
}

class _DetectorWidgetState extends State<DetectorWidget>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  // List of available cameras
  late List<CameraDescription> cameras;

  // Controller
  CameraController? _cameraController;

  // use only when initialized, so - nut null
  get _controller => _cameraController;

  /// Object Detector is running on a background [Isolate]. This is nullable
  /// because acquiring a [Detector] is an asynchronous operation. This
  /// value is `null` until the detector is initialized.
  Detector? _detector;

  StreamSubscription? _subscription;

  /// Results to draw bounding boxes
  List<Recognition>? results;

  int frameCount = 0;
  bool isZoomed = false;

  void onDoubleTapDetected(Recognition result) async {
    log("double tapped on ${result.label}");

    // Calculate zoom level based on the bounding box size and screen size
    // For simplicity, let's assume zoom level of 2.0

    setState(() {
      isZoomed = true;
    });
    await _controller.setZoomLevel(2.0);

    // Start the animation
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initStateAsync();
  }

  void _initStateAsync() async {
    // initalize preview and CameraImage stream
    _initializeCamera();

    //Spawn a new isolate
    Detector.start().then((instance) => {
          setState(() {
            _detector = instance;
            _subscription = instance.resultsStream.stream.listen((values) {
              setState(() {
                results = values['recognitions'];
              });
            });
          })
        });
  }

  /// Initializes the camera by setting [_cameraController]
  ///
  void _initializeCamera() async {
    cameras = await availableCameras();

    _cameraController = CameraController(
      cameras[0],
      ResolutionPreset.medium,
      enableAudio: false,
    )..initialize().then((_) async {
        await _controller.startImageStream(onLatestImageAvailable);
        setState(() {});

        ScreenParams.previewSize = _controller.value.previewSize!;
      });
  }

  @override
  Widget build(BuildContext context) {
    // Return empty container while the camera is not initialized
    if (_cameraController == null || !_controller.value.isInitialized) {
      return const Center(child: CircularProgressIndicator(),);
    }

    var aspect = 1 / _controller.value.aspectRatio;

    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              AspectRatio(
                aspectRatio: aspect,
                child: _buildZoomableCameraPreview(),
              ),
              AspectRatio(
                aspectRatio: aspect,
                child: _boundingBoxes(),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _instructions(),
              _buildCaptureButton(),
            ],
          ),
        )
      ],
    );
  }

  // Widget to wrap the CameraPreview for zooming
  Widget _buildZoomableCameraPreview() {
    return GestureDetector(
      onDoubleTap: () async {
        // Reset zoom level
        setState(() {
          isZoomed = false;
        });
        await _controller.setZoomLevel(1.0);
      },
      child: CameraPreview(_controller!),
    );
  }

  Widget _instructions() {
    return Expanded(
      child: Text(isZoomed
          ? "Double Tap to reset zoom"
          : "Double tap on any detected object to autozoom."),
    );
  }

  /// Returns Stack of bounding boxes
  Widget _boundingBoxes() {
    if (results == null || isZoomed) {
      return const SizedBox.shrink();
    }
    return Stack(
      children: results!
          .map(
              (box) => BoxWidget(result: box, onDoubleTap: onDoubleTapDetected))
          .toList(),
    );
  }

  Widget _buildCaptureButton() {
    return FloatingActionButton(
      onPressed: () async {
        try {
          await _controller;

          final image = await _controller.takePicture();

          await _controller.setZoomLevel(1.0);
          setState(() {
            isZoomed = false;
          });

          if (!mounted) return;

          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ImageDisplayScreen(
                displayPath: image.path,
              ),
            ),
          );
        } catch (e) {
          log("$e");
        }
      },
      child: const Icon(Icons.camera_alt),
    );
  }

  /// Callback to receive each fram [CameraImage] perform inference on it
  void onLatestImageAvailable(CameraImage cameraImage) async {
    frameCount++;
    if (frameCount % 10 == 0) {
      frameCount = 0;

      _detector?.processFrame(cameraImage);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.paused:
        _cameraController?.stopImageStream();
        _detector?.stop();
        _subscription?.cancel();
        break;
      case AppLifecycleState.resumed:
        _initStateAsync();
        break;
      default:
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    _detector?.stop();
    _subscription?.cancel();
    super.dispose();
  }
}
