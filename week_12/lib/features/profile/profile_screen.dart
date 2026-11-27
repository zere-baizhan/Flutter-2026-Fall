import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../settings/settings_model.dart';

///file name the photo is saved under in doc
const avatarFileName = 'avatar.jpg';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _picker = ImagePicker();
  bool _busy = false;

  Future<void> _choosePhoto() => _pick(ImageSource.gallery);

  Future<void> _takePhoto() async {
    final status = await Permission.camera.request();
    if (!mounted) return;

    switch (status) {
      case PermissionStatus.granted:
      case PermissionStatus.limited:
      case PermissionStatus.provisional:
        await _pick(ImageSource.camera);
      case PermissionStatus.denied:
        _snack(
          'Camera access is needed to take a photo. '
          'You can still choose one from the gallery.',
        );
      case PermissionStatus.restricted:
        _snack('The camera is restricted on this device.');
      case PermissionStatus.permanentlyDenied:
        await _showOpenSettingsDialog();
    }
  }

  Future<void> _pick(ImageSource source) async {
    setState(() => _busy = true);
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        imageQuality: 85,
      );
      if (picked == null) return; 
      if (!mounted) return;

      final dir = await getApplicationDocumentsDirectory();
      final dest = File('${dir.path}${Platform.pathSeparator}$avatarFileName');
      await File(picked.path).copy(dest.path);
      await FileImage(dest).evict();

      if (!mounted) return;
      await context.read<SettingsModel>().setAvatar(dest.path, avatarFileName);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _showOpenSettingsDialog() async {
    final open = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.no_photography),
        title: const Text('Camera is turned off'),
        content: const Text(
          'You said "Don\'t allow" before, so Android/iOS will not ask again. '
          'To take a profile photo, turn on Camera for this app in Settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Not now'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Open settings'),
          ),
        ],
      ),
    );
    if (open ?? false) await openAppSettings();
  }

  void _snack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    final path = context.watch<SettingsModel>().avatarPath;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: CircleAvatar(
              radius: 72,
              backgroundColor: scheme.primaryContainer,
              foregroundImage: path == null ? null : FileImage(File(path)),
              // Shown when there is no photo (or the file failed to load).
              child: Icon(
                Icons.person,
                size: 72,
                color: scheme.onPrimaryContainer,
              ),
            ),
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: _busy ? null : _choosePhoto,
            icon: const Icon(Icons.photo_library),
            label: const Text('Choose photo'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _busy ? null : _takePhoto,
            icon: const Icon(Icons.photo_camera),
            label: const Text('Take photo'),
          ),
          if (_busy) ...[
            const SizedBox(height: 24),
            const Center(child: CircularProgressIndicator()),
          ],
        ],
      ),
    );
  }
}
