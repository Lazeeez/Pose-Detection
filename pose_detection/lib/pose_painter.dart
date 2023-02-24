import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:csv/csv.dart';
import 'coordinates_translator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:external_path/external_path.dart';

class PosePainter extends CustomPainter {
  PosePainter(this.poses, this.absoluteImageSize, this.rotation, this.filename);

  final List<Pose> poses;
  final Size absoluteImageSize;
  final InputImageRotation rotation;
  final filename;
  List<List<dynamic>> data = [];

  @override
  Future<void> paint(Canvas canvas, Size size) async {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..color = Colors.green;

    final leftPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.yellow;

    final rightPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.blueAccent;

    for (final pose in poses) {
      pose.landmarks.forEach((_, landmark) {
        canvas.drawCircle(
            Offset(
              translateX(landmark.x, rotation, size, absoluteImageSize),
              translateY(landmark.y, rotation, size, absoluteImageSize),
            ),
            1,
            paint);
      });

      void paintLine(
          PoseLandmarkType type1, PoseLandmarkType type2, Paint paintType) {
        final PoseLandmark joint1 = pose.landmarks[type1]!;
        final PoseLandmark joint2 = pose.landmarks[type2]!;
        canvas.drawLine(
            Offset(translateX(joint1.x, rotation, size, absoluteImageSize),
                translateY(joint1.y, rotation, size, absoluteImageSize)),
            Offset(translateX(joint2.x, rotation, size, absoluteImageSize),
                translateY(joint2.y, rotation, size, absoluteImageSize)),
            paintType);
      }

      //Draw arms
      paintLine(
          PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow, leftPaint);
      paintLine(
          PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist, leftPaint);
      paintLine(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow,
          rightPaint);
      paintLine(
          PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist, rightPaint);

      //Draw Body
      paintLine(
          PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip, leftPaint);
      paintLine(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip,
          rightPaint);

      //Draw legs
      paintLine(PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee, leftPaint);
      paintLine(
          PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle, leftPaint);
      paintLine(
          PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee, rightPaint);
      paintLine(
          PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle, rightPaint);
      exportCoordinates();
    }
    // final String path = await ExternalPath.getExternalStoragePublicDirectory(
    //     ExternalPath.DIRECTORY_DOWNLOADS);
    // final String filePath = '$path/$filename.csv';
    // File file = File(filePath);
    // // convert the data to a csv file
    // // final String csv = const ListToCsvConverter().convert(data);
    // file.writeAsString(data.toString());
  }

  @override
  bool shouldRepaint(covariant PosePainter oldDelegate) {
    return oldDelegate.absoluteImageSize != absoluteImageSize ||
        oldDelegate.poses != poses;
  }

  // write a function to create a dictionary of the coordinates mapped to the landmark type
  exportCoordinates() async {
    // create a csv file
    final List<List<dynamic>> rows = [];
    rows.add(['Landmark', 'X', 'Y', 'Z']);
    for (final pose in poses) {
      pose.landmarks.forEach((_, landmark) {
        rows.add([
          landmark.type.toString(),
          landmark.x.toString(),
          landmark.y.toString(),
          landmark.z.toString()
        ]);
      });
    }

    // bool permission = await requestPermissionHelper(Permission.manageExternalStorage);

    var status = await Permission.manageExternalStorage.status;
    if (status != PermissionStatus.granted) {
      await Permission.manageExternalStorage.request();
    } else {
      final String csv = const ListToCsvConverter().convert(rows);

      // print(csv);
      // return csv;
      // print(csv);

      // write the csv file to the external storage in downloads folder
      final String path = await ExternalPath.getExternalStoragePublicDirectory(
          ExternalPath.DIRECTORY_DOWNLOADS);
      final String filePath = '$path/$filename.csv';
      File file = File(filePath);
      file.writeAsString(csv);

      // String csvData = ListToCsvConverter().convert(rows);
      // final String directory = (await getApplicationSupportDirectory()).path;
      // final path = "$directory/csv-${DateTime.now()}.csv";
      // print(path);
      // final File file = File(path);
      // await file.writeAsString(csvData);
    }

    // create a .csv file called coordinates_pose_detection.csv

    // final String csv = const ListToCsvConverter().convert(rows);
    // // write the csv file to the external storage
    // final String path = await ExternalPath.getExternalStoragePublicDirectory(
    //     ExternalPath.DIRECTORY_DOWNLOADS);
    // final String filePath = '$path/coordinates_pose_detection.csv';
    // // File(filePath).create(recursive: true);
    // File file = File(filePath);
    // file.writeAsString(csv);
    // // show a snack bar to notify the user that the file has been saved
    // return "File saved to $filePath";
  }

  // exportFile() async {
  //   Future<void> csv = printCoordinates();
  // }
}
