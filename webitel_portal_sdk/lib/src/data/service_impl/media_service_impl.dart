import 'dart:async';

import 'package:grpc/grpc.dart';
import 'package:injectable/injectable.dart';
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

  final StreamController<UploadMedia> _mediaRequestStream =
      StreamController<UploadMedia>.broadcast();
  final StreamController<MediaFileEntity> _mediaFileStream =
      StreamController<MediaFileEntity>.broadcast();

  MediaServiceImpl(
    this._grpcGateway,
    this._imageCompressGateway,
  );

  @override
  Future<Stream<MediaFileEntity>> uploadMedia({
    required String type,
    required String name,
    required List<int> data,
    int? compress,
  }) async {
    final request = UploadMedia(
      file: InputFile(
        type: type,
        name: name,
      ),
      data: data,
    );
    _mediaRequestStream.add(request);

    final file = await _grpcGateway.mediaStorageStub
        .uploadFile(_mediaRequestStream.stream);
    _grpcGateway.mediaStorageStub
        .getFile(GetFileRequest(fileId: file.id))
        .listen((media) {
      _mediaFileStream.add(
        MediaFileEntity(
          data: media.data,
          name: media.file.name,
          type: media.file.type,
          id: media.file.type,
        ),
      );
    });
    return _mediaFileStream.stream;
  }

  Future<void> listenToChannelStatus() async {
    _grpcGateway.stateStream.stream.listen((state) {
      connectionState = state;
    });
  }
}
