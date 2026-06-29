import 'package:flutter/material.dart';
import 'package:flutter_unity_widget_2/flutter_unity_widget_2.dart';

import '../core/design/archy_widgets.dart';

/// Unity-powered AR view. Receives a ready-to-load GLB URL (an HTTPS Firebase
/// Storage download URL produced by the architect's model upload) and hands it
/// to the embedded Unity AR scene, which downloads + places it via glTFast.
///
/// AR runs only on physical arm64 Android devices (the Unity export is
/// arm64-only and needs ARCore). Elsewhere, callers should prefer the
/// model_viewer_plus preview used on the virtual-visit / walkthrough screens.
///
/// Message contract: the Unity project F:\UnityProjects\archy_ar contains
/// Assets/Scripts/ModelLoader.cs, a self-registering MonoBehaviour on a
/// GameObject named "ModelLoader" exposing `LoadModel(string url)` (downloads
/// the GLB via glTFast and places it in AR). These constants MUST match those
/// names. The contract only takes effect once that project is re-exported over
/// android/unityLibrary — see F:\UnityProjects\archy_ar\EXPORT_INSTRUCTIONS.txt.
const String kUnityModelGameObject = 'ModelLoader';
const String kUnityLoadMethod = 'LoadModel';

class ARViewerScreen extends StatefulWidget {
  final String? glbUrl;
  final String projectId;

  const ARViewerScreen({super.key, required this.projectId, this.glbUrl});

  @override
  State<ARViewerScreen> createState() => _ARViewerScreenState();
}

class _ARViewerScreenState extends State<ARViewerScreen> {
  UnityWidgetController? _controller;

  void _sendModel() {
    final url = widget.glbUrl;
    if (url == null || url.isEmpty || _controller == null) return;
    _controller!.postMessage(kUnityModelGameObject, kUnityLoadMethod, url);
  }

  @override
  Widget build(BuildContext context) {
    final hasModel = widget.glbUrl != null && widget.glbUrl!.isNotEmpty;
    if (!hasModel) {
      return Scaffold(
        appBar: AppBar(title: const Text('AR View')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'No 3D model has been uploaded for this project yet.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    // Fullscreen camera/3D with the single sanctioned glassmorphism surface:
    // frosted control bars floating over the live AR feed.
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: UnityWidget(
              onUnityCreated: (controller) {
                _controller = controller;
                _sendModel();
              },
              onUnitySceneLoaded: (_) => _sendModel(),
            ),
          ),
          // Top status pill + exit
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const ArchyGlass(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.circle, size: 9, color: Color(0xFF7FCE7F)),
                        SizedBox(width: 7),
                        Text('AR · 1:1 scale',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  ArchyGlass(
                    padding: const EdgeInsets.all(10),
                    radius: 14,
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, color: Colors.white, size: 20),
                  ),
                ],
              ),
            ),
          ),
          // Bottom frosted control bar
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ArchyGlass(
                  radius: 20,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _arCtrl(Icons.push_pin_outlined, 'Place',
                          () => _sendModel()),
                      _arCtrl(Icons.open_in_full, 'Scale', () {}),
                      _arCtrl(Icons.refresh, 'Reset', () => _sendModel()),
                      _arCtrl(Icons.close, 'Exit',
                          () => Navigator.pop(context)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _arCtrl(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 21),
            const SizedBox(height: 4),
            Text(label,
                style: const TextStyle(color: Colors.white, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
