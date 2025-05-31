import 'package:flutter/material.dart';
import 'package:camera/camera.dart'; // Import the camera package
import 'package:flutter/services.dart'; // For SystemChrome

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isProcessingFrame =
      false; // To prevent processing multiple frames simultaneously

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      // Find a suitable camera (usually the back camera)
      final CameraDescription? firstCamera = _cameras?.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras!
            .first, // Fallback to the first camera if back is not found
      );

      if (firstCamera == null) {
        // Handle case where no cameras are available
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No cameras available.')),
          );
        }
        return;
      }

      _controller = CameraController(
        firstCamera,
        ResolutionPreset.medium, // You can adjust resolution
        enableAudio: false, // No need for audio for scanning
        imageFormatGroup:
            ImageFormatGroup.yuv420, // Suitable for image processing
      );

      await _controller!.initialize();

      // Start streaming images for processing
      _controller!.startImageStream((CameraImage image) {
        if (!_isProcessingFrame) {
          _isProcessingFrame = true;
          _processCameraImage(image); // Call our processing function
        }
      });

      if (!mounted) {
        return;
      }

      setState(() {
        _isCameraInitialized = true;
      });
    } catch (e) {
      print("Error initializing camera: $e"); // Log the error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error initializing camera: $e')),
        );
      }
    }
  }

  // This function will be called for each frame from the camera stream
  void _processCameraImage(CameraImage image) {
    // TODO: Implement QR code detection and processing logic here
    // You will need to use a library like google_mlkit_barcode_scanning
    // or zxing_flutter to detect and read QR codes from the 'image' data.
    // The QR code data will tell you the paper ID.
    // You'll then check if this ID has been processed.

    // IMPORTANT: Release the processing lock when done with the frame
    _isProcessingFrame = false;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // App state changes are important for camera management
    final CameraController? cameraController = _controller;

    // App state is not running.
    if (!cameraController!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      // Dispose the controller when the app is inactive.
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      // Reinitialize the controller when the app resumes.
      _initializeCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan MCQ Paper'),
        backgroundColor: const Color(0xFFF0F0F3), // Match dashboard theme
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Color(0xFF8A496B),
        ), // Match dashboard icon theme
        titleTextStyle: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(color: Colors.black87),
      ),
      backgroundColor: const Color(0xFFF0F0F3),
      body: Center(
        child: _isCameraInitialized
            ? AspectRatio(
                aspectRatio: _controller!.value.aspectRatio,
                child: CameraPreview(_controller!),
              )
            : const CircularProgressIndicator(), // Show loading indicator while camera initializes
      ),
    );
  }
}
