import 'dart:async';

import 'package:grpc/grpc.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:webitel_portal_sdk/src/backbone/logger.dart';
import 'package:webitel_portal_sdk/src/data/gateway/grpc_gateway.dart';
import 'package:webitel_portal_sdk/src/data/gateway/image_compress_gateway.dart';
import 'package:webitel_portal_sdk/src/domain/entities/media_file.dart';
import 'package:webitel_portal_sdk/src/domain/services/media_service.dart';
import 'package:webitel_portal_sdk/src/generated/portal/media.pb.dart';

@LazySingleton(as: MediaService)
class MediaServiceImpl implements MediaService {
  final GrpcGateway _grpcGateway;
  final ImageCompressGateway _imageCompressGateway;
  ConnectionState? connectionState;
  Logger logger = CustomLogger.getLogger();

  final StreamController<UploadMedia> _mediaRequestStream =
      StreamController<UploadMedia>.broadcast();
  final StreamController<MediaFileEntity> _mediaFileStream =
      StreamController<MediaFileEntity>.broadcast();

  MediaServiceImpl(
    this._grpcGateway,
    this._imageCompressGateway,
  );

  Future<void> listenToChannelStatus() async {
    _grpcGateway.stateStream.stream.listen((state) {
      connectionState = state;
    });
  }

  Stream<UploadMedia> stream({
    required Stream<List<int>> data,
    required String name,
    required String type,
  }) async* {
    yield UploadMedia(file: InputFile(name: name, type: type));

    data.map((bytes) async* {
      yield UploadMedia(data: bytes);
    });
  }

  @override
  Future<MediaFileEntity> uploadMedia({
    required String type,
    required String name,
    required Stream<List<int>> data,
    int? compress,
  }) async {
    try {
      final file = await _grpcGateway.mediaStorageStub.uploadFile(
        stream(data: data, name: name, type: type),
      );
      print(file.id);
      return MediaFileEntity(
        name: file.name,
        type: file.type,
        id: file.id,
      );
    } catch (error, stackTrace) {
      logger.e(error, error: error, stackTrace: stackTrace);
      return MediaFileEntity(
        name: error.toString(),
        type: 'error',
        id: '',
      );
    }
  }
}
