import 'package:camera/camera.dart';
import 'package:detect_face_example/utils/scanner_utils.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class DetectFacePage extends StatefulWidget {
  @override
  _DetectFacePageState createState() => _DetectFacePageState();
}

class _DetectFacePageState extends State<DetectFacePage> {
  List<Face> _scanResults;

  CameraController _camera;

  String _faceStatus = '';

  bool _isDetecting = false;

  final CameraLensDirection _direction = CameraLensDirection.front;

  final FaceDetector _faceDetector = FirebaseVision.instance.faceDetector(
    FaceDetectorOptions(
      enableClassification: true,
      enableLandmarks: true,
      enableTracking: true,
      minFaceSize: 0.1,
      mode: FaceDetectorMode.accurate,
    ),
  );

  Future<void> _initiliazeCamera() async {
    final description = await ScannerUtils.getCamera(_direction);

    _camera = CameraController(
        description,
        defaultTargetPlatform == TargetPlatform.iOS
            ? ResolutionPreset.medium
            : ResolutionPreset.max,
        imageFormatGroup: defaultTargetPlatform == TargetPlatform.iOS
            ? ImageFormatGroup.bgra8888
            : ImageFormatGroup.unknown);
    await _camera.initialize();

    await _camera.startImageStream((image) {
      if (_isDetecting) return;

      _isDetecting = true;

      ScannerUtils.detect(
              image: image,
              detectInImage: _getDetectionMethod(),
              imageRotatation: description.sensorOrientation)
          .then((results) {
        setState(() {
          _scanResults = results;
          if (_scanResults.isNotEmpty) {
            _faceStatus = 'Rosto Detectado';

            /*if (_scanResults[0].smilingProbability > 0.5) {
              _faceStatus = 'Você sorriu';
            } else if (_scanResults[0].smilingProbability < 0.5) {
              _faceStatus = 'Rosto Detectado';*/

            /*if (_scanResults[0].headEulerAngleY < -20) {
              _faceStatus = 'Você moveu o rosto para esquerda';
            } else if (_scanResults[0].headEulerAngleY > 30) {
              _faceStatus = 'Você moveu o rosto para direita';
            } else {
              _faceStatus = 'Rosto Detectado';
            }*/
          } else {
            _faceStatus = 'Nenhum Rosto Detectado';
          }
        });
      }).whenComplete(() => _isDetecting = false);
    });
  }

  Future<List<Face>> Function(FirebaseVisionImage image) _getDetectionMethod() {
    return _faceDetector.processImage;
  }

  @override
  void initState() {
    super.initState();
    _initiliazeCamera();
  }

  @override
  void dispose() {
    _camera.dispose().then((_) {
      _faceDetector.close();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          _camera == null
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : Center(
                  child: Transform.scale(
                      scale: 1.3, child: CameraPreview(_camera))),
          Container(
            height: MediaQuery.of(context).size.height * 0.36,
            width: MediaQuery.of(context).size.width * 0.55,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.elliptical(200, 380),
                top: Radius.elliptical(200, 220),
              ),
              border: Border.all(width: 9, color: Color(0XFF3FD65F)),
            ),
          ),
          Text(_faceStatus),
        ],
      ),
    );
  }
}
