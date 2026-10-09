import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:teachers_app/ui/common/app_colors.dart';
import 'package:teachers_app/ui/common/app_styles.dart';
import 'package:teachers_app/ui/widgets/custom_text.dart';

enum AttachmentSource { camera, gallery, file }

/// Dashed-looking upload box, or a preview of what was picked with a remove button.
/// Shared by Signal Problem (photo) and Cancel Session (photo or PDF).
class AttachmentField extends StatelessWidget {
  const AttachmentField({super.key, required this.path, required this.onPick, required this.onRemove, this.allowPdf = false});

  final String? path;
  final ValueChanged<String> onPick;
  final VoidCallback onRemove;
  final bool allowPdf;

  bool get _isImage => path != null && !path!.toLowerCase().endsWith('.pdf');

  @override
  Widget build(BuildContext context) {
    if (path == null) {
      return InkWell(
        onTap: () => _pick(context),
        borderRadius: BorderRadius.circular(AppStyles.borderRadiusMediumValue),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 32),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppStyles.borderRadiusMediumValue),
            border: Border.all(color: AppColors.accentBorderColor),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppColors.primaryColor, borderRadius: BorderRadius.circular(4)),
                child: const Icon(Icons.add, color: Colors.white, size: 26),
              ),
              const SizedBox(height: 12),
              CustomText.bodyLarge(text: 'problem.upload'.tr(), fontWeight: FontWeight.w600),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppStyles.borderRadiusMediumValue),
          child: _isImage
              ? Image.file(File(path!), height: 180, width: double.infinity, fit: BoxFit.cover)
              : Container(
                  height: 100,
                  width: double.infinity,
                  color: AppColors.surfaceAltColor,
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.picture_as_pdf_outlined, color: AppColors.redColor, size: 32),
                      const SizedBox(width: 12),
                      Expanded(child: CustomText.bodyMedium(text: path!.split('/').last, maxLines: 2)),
                    ],
                  ),
                ),
        ),
        PositionedDirectional(
          top: 8,
          end: 8,
          child: IconButton.filled(
            onPressed: onRemove,
            icon: const Icon(Icons.close),
            style: IconButton.styleFrom(backgroundColor: AppColors.darkColor),
          ),
        ),
      ],
    );
  }

  Future<void> _pick(BuildContext context) async {
    final source = await showModalBottomSheet<AttachmentSource>(
      context: context,
      builder: (c) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text('problem.camera'.tr()),
              onTap: () => Navigator.pop(c, AttachmentSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text('problem.gallery'.tr()),
              onTap: () => Navigator.pop(c, AttachmentSource.gallery),
            ),
            if (allowPdf)
              ListTile(
                leading: const Icon(Icons.picture_as_pdf_outlined),
                title: Text('problem.pdf'.tr()),
                onTap: () => Navigator.pop(c, AttachmentSource.file),
              ),
          ],
        ),
      ),
    );
    if (source == null) return;

    if (source == AttachmentSource.file) {
      final picked = await FilePicker.pickFile(type: FileType.custom, allowedExtensions: ['pdf']);
      final path = picked?.path;
      if (path != null) onPick(path);
      return;
    }
    // Resized: the API caps uploads at 10 MB.
    final image = await ImagePicker().pickImage(
      source: source == AttachmentSource.camera ? ImageSource.camera : ImageSource.gallery,
      maxWidth: 1600,
      imageQuality: 80,
    );
    if (image != null) onPick(image.path);
  }
}
