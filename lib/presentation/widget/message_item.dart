import 'dart:io';

import 'package:flutter/material.dart';
import 'package:webitel_sdk/domain/entity/dialog_message_entity.dart';

class MessageItem extends StatelessWidget {
  final String content;
  final MessageType messageType;
  final bool isMedia;
  final String? filePath;

  const MessageItem({
    required this.messageType,
    required this.content,
    required this.isMedia,
    this.filePath,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (isMedia) {
      final fileType = _getFileType(filePath!);

      if (fileType == FileType.image) {
        return ImageWidget(imagePath: filePath!);
      } else {
        return FileWidget(filePath: filePath!);
      }
    } else {
      return Container(
        padding: const EdgeInsets.all(8),
        height: 70,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topRight: const Radius.circular(20),
            topLeft: Radius.circular(messageType == MessageType.user ? 20 : 0),
            bottomLeft: const Radius.circular(20),
            bottomRight:
                Radius.circular(messageType == MessageType.operator ? 20 : 0),
          ),
          color: messageType == MessageType.user
              ? Colors.yellow.withOpacity(0.2)
              : Colors.blue.withOpacity(0.2),
        ),
        child: Center(
          child: Text(
            content,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.black,
              fontWeight: FontWeight.w500,
              fontFamily: 'Bebas',
            ),
          ),
        ),
      );
    }
  }

  FileType _getFileType(String filePath) {
    final fileExtension = filePath.split('.').last.toLowerCase();

    if (fileExtension == 'jpg' ||
        fileExtension == 'jpeg' ||
        fileExtension == 'png' ||
        fileExtension == 'gif' ||
        fileExtension == 'heic') {
      return FileType.image;
    } else {
      return FileType.other;
    }
  }
}

enum FileType { image, other }

class ImageWidget extends StatelessWidget {
  final String imagePath;

  const ImageWidget({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Image.file(File(imagePath));
  }
}

class FileWidget extends StatelessWidget {
  final String filePath;

  const FileWidget({super.key, required this.filePath});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      height: 70,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.grey.withOpacity(0.2),
      ),
      child: Center(
        child: Text(
          'File: $filePath',
          style: const TextStyle(
            fontSize: 18,
            color: Colors.black,
            fontWeight: FontWeight.w500,
            fontFamily: 'Bebas',
          ),
        ),
      ),
    );
  }
}
