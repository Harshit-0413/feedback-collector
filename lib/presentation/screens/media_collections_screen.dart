import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_theme.dart';
import '../../core/di/service_locator.dart';
import '../../data/services/media_service.dart';
import '../blocs/feedback_bloc.dart';
import '../blocs/auth_bloc.dart';

class MediaCollectionScreen extends StatefulWidget {
  const MediaCollectionScreen({super.key});

  @override
  State<MediaCollectionScreen> createState() => _MediaCollectionScreenState();
}

class _MediaCollectionScreenState extends State<MediaCollectionScreen> {
  final MediaService _mediaService = sl<MediaService>();
  bool _isLoading = false;

  Future<void> _pickImage() async {
    setState(() => _isLoading = true);
    try {
      final path = await _mediaService.pickImage();
      if (path != null && mounted) {
        context.read<FeedbackBloc>().add(FeedbackMediaAdded(path));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _captureImage() async {
    setState(() => _isLoading = true);
    try {
      final path = await _mediaService.captureImage();
      if (path != null && mounted) {
        context.read<FeedbackBloc>().add(FeedbackMediaAdded(path));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickVideo() async {
    setState(() => _isLoading = true);
    try {
      final path = await _mediaService.pickVideo();
      if (path != null && mounted) {
        context.read<FeedbackBloc>().add(FeedbackMediaAdded(path));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _removeMedia(String path) {
    context.read<FeedbackBloc>().add(FeedbackMediaRemoved(path));
  }

  void _onSubmit() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<FeedbackBloc>().add(
        FeedbackSubmitted(
          authState.user.displayName ?? authState.user.email ?? 'Owner',
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        title: const Text('Media Collection'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocConsumer<FeedbackBloc, FeedbackState>(
        listener: (context, state) {
          if (state is FeedbackSubmitSuccess) {
            Navigator.pushReplacementNamed(context, '/thank-you');
          } else if (state is FeedbackError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final mediaPaths = state is FeedbackMediaState
              ? state.mediaPaths
              : <String>[];
          final isSubmitting = state is FeedbackLoading;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStepIndicator(),
                const SizedBox(height: 28),
                _buildSectionTitle('Attach Media'),
                const SizedBox(height: 8),
                const Text(
                  'Attach screenshots, images, or videos related to the issue. This step is optional.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                _buildMediaActions(),
                const SizedBox(height: 24),
                if (mediaPaths.isNotEmpty) ...[
                  _buildMediaGrid(mediaPaths),
                  const SizedBox(height: 24),
                ],
                _buildSubmitButton(isSubmitting, mediaPaths.length),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      children: List.generate(5, (index) {
        final isActive = index <= 2;
        final isCurrent = index == 2;
        return Expanded(
          child: Container(
            margin: const EdgeInsets.only(right: 4),
            height: 4,
            decoration: BoxDecoration(
              color: isActive
                  ? isCurrent
                        ? AppTheme.primary
                        : AppTheme.primary.withValues(alpha: 0.4)
                  : AppTheme.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppTheme.textPrimary,
        letterSpacing: -0.3,
      ),
    );
  }

  Widget _buildMediaActions() {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            icon: Icons.photo_library_rounded,
            label: 'Gallery',
            onTap: _isLoading ? null : _pickImage,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            icon: Icons.camera_alt_rounded,
            label: 'Camera',
            onTap: _isLoading ? null : _captureImage,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            icon: Icons.videocam_rounded,
            label: 'Video',
            onTap: _isLoading ? null : _pickVideo,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.primary, size: 26),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaGrid(List<String> mediaPaths) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${mediaPaths.length} file${mediaPaths.length > 1 ? 's' : ''} attached',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: mediaPaths.length,
          itemBuilder: (context, index) {
            return _buildMediaTile(mediaPaths[index]);
          },
        ),
      ],
    );
  }

  Widget _buildMediaTile(String path) {
    final isVideo = _mediaService.isVideo(path);
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: isVideo
              ? Container(
                  color: AppTheme.divider,
                  child: const Icon(
                    Icons.play_circle_rounded,
                    color: AppTheme.textSecondary,
                    size: 36,
                  ),
                )
              : Image.file(File(path), fit: BoxFit.cover),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => _removeMedia(path),
            child: Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close_rounded,
                color: Colors.white,
                size: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(bool isSubmitting, int mediaCount) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isSubmitting ? null : _onSubmit,
        child: isSubmitting
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Submit Feedback'),
                  const SizedBox(width: 8),
                  const Icon(Icons.check_rounded, size: 18),
                ],
              ),
      ),
    );
  }
}
