//  import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';

// Simulasi data monitoring
final _dummyData = {
  'suhu': '30°C',
  'kelembapan': '60%',
  'ph': '6.5',
  'prediksi_panen': '10 hari lagi'
};

class BackendServer {
  Handler get handler {
    final router = Router();

    router.get('/status', (Request request) {
      return Response.ok(_dummyData.toString());
    });

    return router.call;
  }

  Future<void> startServer() async {
    final server = await io.serve(handler, 'localhost', 8080);
    print('🚀 Server berjalan di http://${server.address.host}:${server.port}');
  }
}
