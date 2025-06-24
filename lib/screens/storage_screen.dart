import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_app/utils/supabase_services.dart';

class StorageScreen extends StatefulWidget {
  const StorageScreen({super.key});

  @override
  State<StorageScreen> createState() => _StorageScreenState();
}

class _StorageScreenState extends State<StorageScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload and Download Files'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {
                _showUploadFileDialog(context);
              },
              child: const Text('Upload File'),
            ),
            const Divider(),
            TextButton(
              onPressed: () {},
              child: const Text('Download File'),
            ),
            const Divider(),
            TextButton(
              onPressed: () {},
              child: const Text('Delete File'),
            ),
          ],
        ),
      ),
    );
  }

  void _showUploadFileDialog(BuildContext context) async {
    if (!await _checkAndRequestStoragePermission(context)) return;

    final XFile? file = await _pickImageFromGallery();
    if (file == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No file selected.")),
      );
      return;
    }

    _uploadFile(context, file);
  }

  Future<bool> _checkAndRequestStoragePermission(BuildContext context) async {
    if (Platform.isAndroid) {
      // For Android 13+
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt >= 33) {
        final status = await Permission.photos.status;
        if (status.isGranted) return true;

        final result = await Permission.photos.request();
        if (result.isGranted) return true;
      } else {
        final status = await Permission.storage.status;
        if (status.isGranted) return true;

        final result = await Permission.storage.request();
        if (result.isGranted) return true;
      }
    } else {
      // iOS or other platforms
      final status = await Permission.photos.status;
      if (status.isGranted) return true;

      final result = await Permission.photos.request();
      if (result.isGranted) return true;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Storage permission is required.")),
    );
    return false;
  }

  Future<XFile?> _pickImageFromGallery() async {
    final picker = ImagePicker();
    return await picker.pickImage(source: ImageSource.gallery);
  }

  void _uploadFile(BuildContext context, XFile file) {
    final filePath = file.path;

    SupabaseServices.uploadFile(
      file: File(filePath),
      onUploadSuccess: (message) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Upload successful: $message")),
        );
      },
      onUploadFailure: (message) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Upload failed: $message")),
        );
      },
      onChangeStatus: (text, isLoading) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(text)),
        );
      },
    );
  }
}
