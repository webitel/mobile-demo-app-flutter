import 'package:webitel_sdk_package/src/generated/google/protobuf/any.pb.dart';
import 'package:webitel_sdk_package/src/generated/portal/connect.pb.dart'
    as portal;

class PortalRequestBuilder {
  late String path;
  late Any data;
  late String id;

  PortalRequestBuilder setPath(String path) {
    this.path = path;
    return this;
  }

  PortalRequestBuilder setData(Any data) {
    this.data = data;
    return this;
  }

  PortalRequestBuilder setId(String id) {
    this.id = id;
    return this;
  }

  portal.Request build() {
    return portal.Request(
      path: path,
      data: data,
      id: id,
    );
  }
}
