import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickCrop {
  static final ImagePicker _picker = ImagePicker();

  static Future<File?> pickAndCrop({
    required BuildContext context,
    required ImageSource source,
    required CropStyle cropStyle, // circle ou rectangle (via UI settings)
    required List<CropAspectRatioPreset> presets, // lista de presets no menu
    CropAspectRatio? lockedRatio, // se passar, trava o ratio
    int compressQuality = 92,
  }) async {
    final picked = await _picker.pickImage(source: source);
    if (picked == null) return null;

    final cropped = await ImageCropper().cropImage(
      sourcePath: picked.path,
      aspectRatio: lockedRatio, // se != null, trava o aspecto
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: compressQuality,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Ajustar imagem',
          toolbarWidgetColor: const Color.fromARGB(255, 0, 0, 0),
          statusBarLight: false,
          cropStyle: cropStyle,
          aspectRatioPresets: presets,
          initAspectRatio: presets.isNotEmpty ? presets.first : CropAspectRatioPreset.original,
          lockAspectRatio: lockedRatio != null,
          activeControlsWidgetColor: Theme.of(context).colorScheme.primary,
        ),
        IOSUiSettings(
          title: 'Ajustar imagem',
          cropStyle: cropStyle,
          aspectRatioPresets: presets,
          aspectRatioLockEnabled: lockedRatio != null,
        ),
        // Se seu app compila pra Web, adicione também:
        // WebUiSettings(context: context),
      ],
    ); // [page:0]

    if (cropped == null) return null;
    return File(cropped.path);
  }
}
