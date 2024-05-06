import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_animated_progress_bar/flutter_animated_progress_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _StartScreenState createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen>
    with TickerProviderStateMixin {
  bool isCameraOpen = false;
  late CameraController _controller;
  late final ProgressBarController _progressController;
  late int currentProgress = 0;

  @override
  void initState() {
    super.initState();
    _progressController = ProgressBarController(vsync: this);
  }

  Future<void> _initializeCamera() async {
    // Get a list of available cameras.
    final cameras = await availableCameras();
    // Use the first camera from the list.
    _controller = CameraController(cameras[0], ResolutionPreset.medium);
    // Initialize the camera controller.
    await _controller.initialize();
    setState(() {
      isCameraOpen = true;
    });
    _startProgress();
  }

  void _startProgress() {
    setState(() {
      const duration = Duration(seconds: 10);
      _progressController.collapseBar(
        duration: duration,
        curve: Curves.easeIn,
      );
    });

    _captureAndSendImage();
  }

  Future<void> _captureAndSendImage() async {
    try {
      final XFile image = await _controller.takePicture();
      final bytes = await image.readAsBytes();
      log('Image bytes: $bytes');
      // Send bytes to API using http package
      // Example: await _sendImageToAPI(bytes);
    } catch (e) {
      log('Error capturing image: $e');
    }
  }

  @override
  void dispose() {
    // Dispose of the camera controller when not needed.
    _controller.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_outlined),
            color: const Color(0xFF5F69C7),
            onPressed: () {
              setState(() {
                isCameraOpen = false;
              });
            },
          ),
          title: Text(
            'Face Verification',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: isCameraOpen ? _buildCameraView() : _buildVerifyButton(),
      ),
    );
  }

  Widget _buildVerifyButton() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Spacer(),
          const Image(image: AssetImage('assets/image_1.png')),
          Text(
            'Initiate face verification \nfor quick attendance Process.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Text(
            'Privacy Notice',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFF5F69C7),
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              decoration: TextDecoration.underline,
              decorationColor: const Color(0xFF5F69C7),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5F69C7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                maximumSize: Size(335.w, 44.h),
                minimumSize: Size(335.w, 44.h),
              ),
              onPressed: () {
                setState(() {
                  isCameraOpen = true;
                  _initializeCamera();
                });
              },
              child: Text(
                'Verify',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCameraView() {
    return Container(
      decoration: const BoxDecoration(
          image: DecorationImage(
        image: AssetImage('assets/image_3.png'),
        fit: BoxFit.cover,
      )),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Stack(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: CameraPreview(_controller),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 20),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Text(
                          'Please look into the camera and hold still',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 40.h,
                    ),
                    const Image(image: AssetImage('assets/image_2.png')),
                    const Spacer(),
                    Text(
                      '$currentProgress% Scanning',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 20.0, right: 20.0, bottom: 20.0),
                      child: ProgressBar(
                        alignment: ProgressBarAlignment.center,
                        automaticallyHandleAnimations: true,
                        backgroundBarColor: const Color(0xFFFFECE2),
                        barCapShape: BarCapShape.round,
                        collapsedProgressBarColor: const Color(0xFF5F69C7),
                        controller: _progressController,
                        progress: Duration(seconds: currentProgress),
                        total: const Duration(seconds: 10),
                        onSeek: (position) {
                          log('New position: $position');
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
          // Add a progress bar at the bottom as needed
        ],
      ),
    );
  }
}
