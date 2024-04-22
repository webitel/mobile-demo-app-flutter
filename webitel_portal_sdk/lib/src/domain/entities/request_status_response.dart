enum RequestStatus { initial, success, error }

class RequestStatusResponse {
  final RequestStatus status;
  final String? message;

  RequestStatusResponse({required this.status, this.message});
}
