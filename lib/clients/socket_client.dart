import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:docs_clone/constants.dart';

//singleton pattern implementation
class SocketClient {
  io.Socket? socket;
  static SocketClient? _instance;

  SocketClient._internal() {
    socket = io.io(host, <String, dynamic> {
      "transports" : ["websocket"],
      "autoConnect" : false
    });
    socket!.connect(); //want to connect manually
  }

  static SocketClient get instance {
    // if instacnce is null, i.e no object of this class exists --=> create one
    _instance??=SocketClient._internal();
    return _instance!;
  }
}