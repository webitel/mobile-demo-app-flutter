import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:webitel_portal_sdk/src/backbone/logger.dart';

@LazySingleton()
class ImageCompressGateway {
  Logger logger = CustomLogger.getLogger();

  Future<Uint8List?> compressImage(
    Uint8List imageData,
    int qualityPercentage,
  ) async {
    try {
      Uint8List compressedData = await FlutterImageCompress.compressWithList(
        imageData,
        quality: qualityPercentage,
      );
      return compressedData;
    } catch (error, stackTrace) {
      logger.e(error, error: error, stackTrace: stackTrace);
      return null;
    }
  }
}
