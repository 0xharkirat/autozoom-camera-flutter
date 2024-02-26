import 'package:flutter/material.dart';
import 'package:test/components/detector_widget.dart';
import 'package:test/models/screen_params.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // must be initialized for bounding boxes...
    ScreenParams.screenSize = MediaQuery.sizeOf(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Autozoom Camera Flutter"),
      ),
      body: const DetectorWidget(),
    );
  }
}
