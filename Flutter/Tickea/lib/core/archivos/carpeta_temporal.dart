import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<Directory> obtenerOCrearCarpetaTemporal(String strFecha) async {
  final baseTmp = await getTemporaryDirectory();
  final dir = Directory('${baseTmp.path}/$strFecha');

  if (await dir.exists()) return dir;
  return dir.create(recursive: true);
}
