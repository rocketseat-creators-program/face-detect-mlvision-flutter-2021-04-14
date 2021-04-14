import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ScannerUtils {
  ScannerUtils._();

  static Future<CameraDescription> getCamera(CameraLensDirection dir) {
    return availableCameras().then(
      (cameras) => cameras.firstWhere((camera) => camera.lensDirection == dir),
    );
  }

  static Future<List<Face>> detect({
    @required CameraImage image,
    @required
        Future<List<Face>> Function(FirebaseVisionImage image) detectInImage,
    @required int imageRotatation,
  }) {
    return detectInImage(
      FirebaseVisionImage.fromBytes(
        _concatenatedPlanes(image.planes),
        _buildMetaData(
          image,
          _rotationIntToImageRotation(imageRotatation),
        ),
      ),
    );
  }

  static Uint8List _concatenatedPlanes(List<Plane> planes) {
    final allBytes = WriteBuffer();
    for (var plane in planes) {
      allBytes.putUint8List(plane.bytes);
    }
    return allBytes.done().buffer.asUint8List();
  }

  static FirebaseVisionImageMetadata _buildMetaData(
      CameraImage image, ImageRotation rotation) {
    return FirebaseVisionImageMetadata(
      rawFormat: image.format.raw,
      size: Size(image.width.toDouble(), image.height.toDouble()),
      rotation: rotation,
      planeData: image.planes.map((plane) {
        return FirebaseVisionImagePlaneMetadata(
            bytesPerRow: plane.bytesPerRow,
            height: plane.height,
            width: plane.width);
      }).toList(),
    );
  }

  static ImageRotation _rotationIntToImageRotation(int rotation) {
    switch (rotation) {
      case 0:
        return ImageRotation.rotation0;
      case 90:
        return ImageRotation.rotation90;
      case 180:
        return ImageRotation.rotation180;
      default:
        assert(rotation == 270);
        return ImageRotation.rotation270;
    }
  }
}
