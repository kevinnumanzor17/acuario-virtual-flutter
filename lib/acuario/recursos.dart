import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';

const _carpeta = 'assets/arrecife';

/// Una textura por especie y una imagen para el paisaje.
class Recursos {
  Recursos(this.fondo, this.especies);
  final ui.Image fondo;
  final List<TexturaPez> especies;

  static Future<ui.Image> _imagen(String nombre) async {
    final bytes = await rootBundle.load('$_carpeta/$nombre');
    final codec = await ui.instantiateImageCodec(
      bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes),
    );
    try {
      return (await codec.getNextFrame()).image;
    } finally {
      codec.dispose();
    }
  }

  static Future<Recursos> cargar() async {
    final imagenes = await Future.wait([
      _imagen('arrecife.jpg'), _imagen('angel.png'),
      _imagen('mariposa.png'), _imagen('cirujano.png'),
    ], cleanUp: (imagen) => imagen.dispose());
    return Recursos(imagenes.first, imagenes.skip(1).map(TexturaPez.new).toList());
  }

  void dispose() {
    fondo.dispose();
    for (final pez in especies) {
      pez.dispose();
    }
  }
}

/// El movimiento ondula principalmente el último tercio del cuerpo (la cola).
/// Las dos versiones dibujan exactamente las mismas posturas discretas.
class TexturaPez {
  TexturaPez(this.imagen)
      : material = (ui.Paint()
          ..filterQuality = ui.FilterQuality.low
          ..shader = ui.ImageShader(imagen, ui.TileMode.clamp, ui.TileMode.clamp,
              Float64List.fromList([1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1])));
  final ui.Image imagen;
  final ui.Paint material;
  static const fases = 32;
  static const segmentos = 12;
  final Map<int, ui.Vertices> _cache = {};

  ui.Vertices _malla(int fase) {
    final puntos = <ui.Offset>[], textura = <ui.Offset>[];
    final w = imagen.width.toDouble(), h = imagen.height.toDouble();
    final angulo = fase * 2 * math.pi / fases;
    for (var i = 0; i <= segmentos; i++) {
      final u = i / segmentos;
      final cola = (1 - u) * (1 - u) * (1 - u);
      final desplazamiento = math.sin(angulo - u * 2.2) * cola;
      final x = u * w + (1 - math.cos(angulo)) * cola * .033 * w;
      final y = desplazamiento * h * .079;
      puntos.addAll([ui.Offset(x, y), ui.Offset(x, h + y)]);
      textura.addAll([ui.Offset(u * w, 0), ui.Offset(u * w, h)]);
    }
    return ui.Vertices(ui.VertexMode.triangleStrip, puntos, textureCoordinates: textura);
  }

  void dibujar(ui.Canvas lienzo, int fase, bool optimizada) {
    final malla = optimizada ? _cache.putIfAbsent(fase, () => _malla(fase)) : _malla(fase);
    lienzo.drawVertices(malla, ui.BlendMode.srcOver, material);
    if (!optimizada) malla.dispose();
  }

  void dispose() {
    for (final malla in _cache.values) {
      malla.dispose();
    }
    material.shader?.dispose();
    imagen.dispose();
  }
}
