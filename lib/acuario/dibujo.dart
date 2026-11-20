import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'escena.dart';
import 'recursos.dart';

class FondoMarino extends CustomPainter {
  const FondoMarino(this.recursos);
  final Recursos recursos;

  @override
  void paint(Canvas canvas, Size size) {
    final foto = recursos.fondo;
    final original = Size(foto.width.toDouble(), foto.height.toDouble());
    final ajuste = applyBoxFit(BoxFit.cover, original, size);
    final origen = Alignment.center.inscribe(ajuste.source, Offset.zero & original);
    canvas.drawImageRect(foto, origen, Offset.zero & size, Paint()..filterQuality = FilterQuality.medium);
  }

  @override
  bool shouldRepaint(FondoMarino anterior) => recursos != anterior.recursos;
}

class VidaMarina extends CustomPainter {
  VidaMarina(this.escena, this.recursos, this.reloj,
      {required this.optimizada, required this.instante})
      : super(repaint: optimizada ? reloj : null);

  final Escena escena;
  final Recursos recursos;
  final Animation<double> reloj;
  final bool optimizada;
  final double instante;
  static const periodo = Duration(hours: 24);

  void _plantas(Canvas canvas, Size size, double t, Paint p) {
    for (final e in escena.plantas) {
      final x = size.width * e.x;
      final y = size.height * (.94 + .06 * e.y);
      final alto = size.height * (.036 + .086 * e.escala);
      final viento = math.sin(t * .74 + e.fase) * alto * .12;
      for (var j = -1; j <= 1; j++) {
        final dx = alto * .16 * j;
        final dy = alto * (1 - .15 * j.abs());
        final hoja = Path()..moveTo(x, y)
          ..cubicTo(x + dx, y - dy * .4, x + dx - viento, y - dy * .7, x + 2 * dx + viento, y - dy)
          ..quadraticBezierTo(x + dx + alto * .07, y - dy * .44, x, y)..close();
        p.color = j == 0 ? const Color(0xc73e7363) : const Color(0xbf295d55);
        canvas.drawPath(hoja, p);
      }
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final t = (optimizada ? reloj.value : instante) * periodo.inSeconds;
    final w = size.width, h = size.height;
    final p = Paint();
    for (final e in escena.particulas) {
      final x = (e.x + t * (.001 + e.rapidez * .002)) % 1;
      final y = .03 + e.y * .91 + .005 * math.sin(t + e.fase);
      p.color = const Color(0x5bc9e1dc);
      canvas.drawCircle(Offset(x * w, y * h), .35 + e.escala * .72, p);
    }
    _plantas(canvas, size, t, p);
    final largoReferencia = (w * .118).clamp(49.0, 114.0).toDouble();
    for (final i in escena.ordenPeces) {
      final e = escena.peces[i];
      final pez = recursos.especies[i % recursos.especies.length];
      final largo = largoReferencia * (.53 + .63 * e.escala);
      final escala = largo / pez.imagen.width;
      final alto = escala * pez.imagen.height;
      final faseNado = t * (4.7 + e.rapidez * 1.9) + e.fase;
      final fase = (faseNado / (2 * math.pi) * TexturaPez.fases).floor() % TexturaPez.fases;
      final avance = (e.x + t * (.016 + .025 * e.rapidez)) % 1;
      final derecha = i.isEven;
      final x = (derecha ? avance : 1.0 - avance) * (w + largo) - largo / 2;
      final y = h * (.13 + .61 * e.y + .026 * math.sin(t * .63 + e.fase));
      canvas.save();
      canvas.translate(x, y);
      canvas.scale(derecha ? 1.0 : -1.0, 1);
      canvas.rotate(.036 * math.cos(t * .63 + e.fase));
      canvas.translate(-largo / 2, -alto / 2);
      canvas.scale(escala, escala);
      pez.dibujar(canvas, fase, optimizada);
      canvas.restore();
    }
    for (final e in escena.burbujas) {
      final y = 1 - (e.y + t * (.03 + .042 * e.rapidez)) % 1;
      final centro = Offset(w * e.x + 4 * math.sin(t + e.fase), h * y);
      final radio = 1 + 2.3 * e.escala;
      p..style = PaintingStyle.stroke..strokeWidth = .62..color = const Color(0x6bbcf0ef);
      canvas.drawCircle(centro, radio, p);
      p..style = PaintingStyle.fill..color = const Color(0xa7d7fffa);
      canvas.drawCircle(centro + Offset(-radio * .30, -radio * .42), radio * .17, p);
    }
  }

  @override
  bool shouldRepaint(VidaMarina anterior) =>
      escena != anterior.escena || recursos != anterior.recursos ||
      optimizada != anterior.optimizada || reloj != anterior.reloj || instante != anterior.instante;
}
