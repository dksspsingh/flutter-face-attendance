import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_face_attendance/views/start_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

late List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(
    const ScreenUtilInit(
      child: StartScreen(),
    ),
  );
}
