import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../services/api_service.dart';
import '../models/analysis_result.dart';
import '../widgets/glass_card.dart';
import 'loading_screen.dart';
import 'result_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  bool _isProcessing = false;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    _controller = CameraController(
      firstCamera,
      ResolutionPreset.high,
      enableAudio: false,
    );

    _initializeControllerFuture = _controller!.initialize();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _scanImage() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    // Haptic + sound feedback on capture
    HapticFeedback.mediumImpact();
    SystemSound.play(SystemSoundType.click);

    try {
      final image = await _controller!.takePicture();

      if (!mounted) return;

      // Navigate to full-screen loading page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoadingScreen()),
      );

      final inputImage = InputImage.fromFilePath(image.path);
      final textRecognizer = TextRecognizer();
      final RecognizedText recognizedText =
          await textRecognizer.processImage(inputImage);
      String text = recognizedText.text;

      textRecognizer.close();

      if (text.isEmpty) {
        if (mounted) {
          Navigator.pop(context); // Remove loading screen
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('No text found. Try pointing at an ingredient label.'),
              backgroundColor: Color(0xFFFF1744),
            ),
          );
        }
        return;
      }

      // Send to API
      final result = await _apiService.analyzeText(text);

      if (mounted) {
        // Replace loading screen with result screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(result: result),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        // Try to pop loading screen if it's there
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Color(0xFFFF1744),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                // Camera Preview
                Positioned.fill(child: CameraPreview(_controller!)),

                // Overlay Gradient
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.5),
                          Colors.transparent,
                          Colors.transparent,
                          Colors.black.withOpacity(0.6),
                        ],
                        stops: [0, 0.25, 0.75, 1],
                      ),
                    ),
                  ),
                ),

                // Scanner Frame
                Center(
                  child: Container(
                    width: 300,
                    height: 400,
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: Colors.white.withOpacity(0.3), width: 1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _cornerWidget(true, true),
                            _cornerWidget(true, false),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _cornerWidget(false, true),
                            _cornerWidget(false, false),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Instructions
                Positioned(
                  bottom: 180,
                  left: 40,
                  right: 40,
                  child: Center(
                    child: GlassCard(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.info_outline,
                              color: Color(0xFF00E676), size: 16),
                          SizedBox(width: 8),
                          Text(
                            'Point camera at ingredient label',
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Scan Button
                Positioned(
                  bottom: 60,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: GestureDetector(
                      onTap: _isProcessing ? null : _scanImage,
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        width: _isProcessing ? 70 : 76,
                        height: _isProcessing ? 70 : 76,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          color: _isProcessing
                              ? Colors.grey.withOpacity(0.5)
                              : Color(0xFF00E676),
                          boxShadow: _isProcessing
                              ? []
                              : [
                                  BoxShadow(
                                    color: Color(0xFF00E676).withOpacity(0.4),
                                    blurRadius: 20,
                                    spreadRadius: 2,
                                  ),
                                ],
                        ),
                        child: _isProcessing
                            ? Padding(
                                padding: EdgeInsets.all(18),
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 3,
                                ),
                              )
                            : Icon(
                                Icons.camera_alt,
                                color: Colors.black,
                                size: 30,
                              ),
                      ),
                    ),
                  ),
                ),

                // Top Bar
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.arrow_back_ios_new,
                                color: Colors.white, size: 20),
                          ),
                        ),
                        Text(
                          'Scan Label',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.flash_off,
                              color: Colors.white, size: 20),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          } else {
            return Container(
              color: Color(0xFF0D0D0D),
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFF00E676)),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _cornerWidget(bool isTop, bool isLeft) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        border: Border(
          top: isTop
              ? BorderSide(color: const Color(0xFF00E676), width: 4)
              : BorderSide.none,
          left: isLeft
              ? BorderSide(color: const Color(0xFF00E676), width: 4)
              : BorderSide.none,
          bottom: !isTop
              ? BorderSide(color: const Color(0xFF00E676), width: 4)
              : BorderSide.none,
          right: !isLeft
              ? BorderSide(color: const Color(0xFF00E676), width: 4)
              : BorderSide.none,
        ),
      ),
    );
  }
}
