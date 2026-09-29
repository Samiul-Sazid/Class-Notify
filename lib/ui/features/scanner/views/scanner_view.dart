import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../view_models/scanner_view_model.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../core/glass_card.dart';
import 'review_extracted_routine_view.dart';

/// Routine scanner view for uploading and parsing timetable images.
class ScannerView extends StatelessWidget {
  final ScannerViewModel viewModel;

  const ScannerView({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 8),

                if (viewModel.parseStatus == ParseStatus.idle ||
                    viewModel.parseStatus == ParseStatus.error)
                  _buildUploadSection(context),

                if (viewModel.selectedImagePath != null &&
                    viewModel.selectedImagePath != 'sample' &&
                    viewModel.parseStatus == ParseStatus.idle)
                  _buildImagePreview(context),

                if (viewModel.parseStatus == ParseStatus.loading)
                  _buildLoadingState(context),

                if (viewModel.parseStatus == ParseStatus.error)
                  _buildErrorState(context),

                if (viewModel.parseStatus == ParseStatus.success)
                  _buildSuccessState(context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Scan Routine', style: textTheme.headlineMedium),
          const SizedBox(height: 4),
          Text(
            'Upload a photo of your class routine to auto-extract your schedule.',
            style: textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildUploadSection(BuildContext context) {
    return Column(
      children: [
        // Camera + Gallery cards
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: _buildUploadCard(
                  context,
                  icon: Icons.camera_alt_outlined,
                  label: 'Take Photo',
                  color: AppColors.primary,
                  onTap: () => viewModel.pickImage(ImageSource.camera),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildUploadCard(
                  context,
                  icon: Icons.photo_library_outlined,
                  label: 'Gallery',
                  color: AppColors.accent,
                  onTap: () => viewModel.pickImage(ImageSource.gallery),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Quick demo button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GlassCard(
            margin: EdgeInsets.zero,
            onTap: () => viewModel.parseWithSample(),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: AppColors.warning,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Try with Sample Routine',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        'Test the full flow with a demo schedule',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 16),
              ],
            ),
          ),
        ),

        // API key notice
        if (!viewModel.hasApiKey)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.info.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppColors.info, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Set up your free Gemini API key in Settings to use AI-powered image parsing.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.info,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildUploadCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 28),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.3),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.file(
              File(viewModel.selectedImagePath!),
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: viewModel.hasApiKey
                      ? () => viewModel.parseWithGemini()
                      : null,
                  icon: const Icon(Icons.auto_fix_high),
                  label: const Text('Extract with AI'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: () {
                  viewModel.reset();
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 56,
              height: 56,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              viewModel.statusMessage,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'This may take a few seconds...',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return GlassCard(
      borderColor: AppColors.danger.withValues(alpha: 0.3),
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: AppColors.danger, size: 40),
          const SizedBox(height: 12),
          Text(
            'Parsing Failed',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.danger,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            viewModel.errorMessage ?? 'Unknown error',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => viewModel.reset(),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessState(BuildContext context) {
    return ReviewExtractedRoutineView(viewModel: viewModel);
  }
}
