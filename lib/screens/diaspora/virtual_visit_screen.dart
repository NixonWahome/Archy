import 'package:archy/core/theme/neomorphic_widgets.dart';
import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import '../ar_viewer_screen.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/database_service.dart';
import '../../core/services/auth_service.dart';
import '../../core/models/project_model.dart';

class VirtualVisitScreen extends StatefulWidget {
  final bool isDarkMode;

  const VirtualVisitScreen({super.key, required this.isDarkMode});

  @override
  State<VirtualVisitScreen> createState() => _VirtualVisitScreenState();
}

class _VirtualVisitScreenState extends State<VirtualVisitScreen> {
  double _compareSlider = 0.5;
  String? selectedProjectId;

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthService, DatabaseService>(
      builder: (context, authService, dbService, child) {
        final userId = authService.currentUser?.uid;
        if (userId == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          backgroundColor:
              widget.isDarkMode
                  ? AppTheme.darkBackground
                  : AppTheme.lightBackground,
          appBar: AppBar(
            backgroundColor:
                widget.isDarkMode
                    ? AppTheme.darkSurface
                    : AppTheme.lightSurface,
            title: const Text('Virtual Site Visit'),
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: widget.isDarkMode ? Colors.white : Colors.black87,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.info_outline,
                  color: widget.isDarkMode ? Colors.white : Colors.black87,
                ),
                onPressed: () {},
              ),
            ],
          ),
          body: StreamBuilder<List<ProjectModel>>(
            stream: dbService.diasporaProjectsStream(userId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final projects = snapshot.data ?? [];
              if (projects.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.construction, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No projects for virtual visit'),
                    ],
                  ),
                );
              }

              final project =
                  selectedProjectId != null
                      ? projects.firstWhere(
                        (p) => p.id == selectedProjectId,
                        orElse: () => projects.first,
                      )
                      : projects.first;

              return Column(
                children: [
                  // Live AR / 3D Model Viewer - Full Implementation
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ModelViewer(
                        src:
                            project.model3dUrl ??
                            'https://modelviewer.dev/shared-assets/models/Astronaut.glb',
                        alt: '${project.title} - Virtual 3D Model',
                        ar: true,
                        autoRotate: true,
                        cameraControls: true,
                        loading: Loading.eager,
                        backgroundColor: Color(
                          widget.isDarkMode ? 0xFF1A1A2E : 0xFFE8E8E8,
                        ),
                        exposure: 1.0,
                        shadowIntensity: 1.0,
                      ),
                    ),
                  ),

                  // Controls
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color:
                          widget.isDarkMode
                              ? AppTheme.darkSurface
                              : AppTheme.lightSurface,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          project.title,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color:
                                widget.isDarkMode
                                    ? Colors.white
                                    : Colors.black87,
                          ),
                        ),
                        Text(
                          project.address,
                          style: TextStyle(
                            color:
                                widget.isDarkMode
                                    ? Colors.white54
                                    : Colors.black45,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: _ProjectOption(project: projects.first),
                            ),
                            Expanded(
                              child: _ProjectOption(
                                project:
                                    projects.length > 1
                                        ? projects[1]
                                        : projects.first,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.architecture,
                                    color: AppTheme.primaryBlue,
                                  ),
                                  const SizedBox(height: 4),
                                  const Text('BIM Model'),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: Slider(
                                value: _compareSlider,
                                onChanged:
                                    (value) =>
                                        setState(() => _compareSlider = value),
                                activeColor: AppTheme.primaryBlue,
                              ),
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.photo_camera,
                                    color: AppTheme.warning,
                                  ),
                                  const SizedBox(height: 4),
                                  const Text('Site'),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: NeomorphicButton(
                            isDarkMode: widget.isDarkMode,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => ARViewerScreen(
                                        projectId: project.id,
                                        glbUrl:
                                            project
                                                .model3dUrl, // or backend URL
                                      ),
                                ),
                              );
                            },
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.view_in_ar),
                                SizedBox(width: 8),
                                Text('Launch Unity AR'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _ProjectOption extends StatelessWidget {
  final ProjectModel project;

  const _ProjectOption({required this.project});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 60,
              height: 60,
              color: Colors.blue.withOpacity(0.2),
              child: Icon(Icons.image, color: Colors.blue),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            project.title,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
