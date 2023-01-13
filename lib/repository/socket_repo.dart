import 'package:docs_clone/clients/socket_client.dart';
import 'package:socket_io_client/socket_io_client.dart';


class SocketRepo {
  final _socketClient = SocketClient.instance.socket!;

  Socket get socketClient => _socketClient;

  void joinRoom(String doucmentId) {
    _socketClient.emit("join", doucmentId);
  }

  void typing(Map<String, dynamic> data) {
    _socketClient.emit("typing", data);
  }

  void changeListner(Function(Map<String,dynamic>) func) {
    _socketClient.on("changes", (data) => func(data)); // passing in a function argument as socketRepo does not has access to the quill controller
  }

  void autoSave(Map<String, dynamic> data) {
    _socketClient.emit("save", data);
  }
}