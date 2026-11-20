import 'package:flutter/material.dart';
import 'dibujo.dart';
import 'escena.dart';
import 'recursos.dart';

const _linea = Color(0xff32434b);
const _suave = Color(0xffb7c9ce);
const _menta = Color(0xffa4eed7);

class PantallaAcuario extends StatefulWidget {
  const PantallaAcuario({super.key});
  @override
  State<PantallaAcuario> createState() => _PantallaAcuarioState();
}

class _PantallaAcuarioState extends State<PantallaAcuario> with SingleTickerProviderStateMixin {
  late final AnimationController reloj;
  var escena = Escena(Carga.baja);
  var version = Version.base;
  var enMarcha = true;
  Recursos? recursos;
  bool fallo = false;

  @override
  void initState() {
    super.initState();
    reloj = AnimationController(vsync: this, duration: VidaMarina.periodo);
    cargar();
  }

  Future<void> cargar() async {
    if (fallo) setState(() => fallo = false);
    try {
      final paquete = await Recursos.cargar();
      if (!mounted) {
        paquete.dispose();
        return;
      }
      setState(() => recursos = paquete);
      if (enMarcha) reloj.repeat();
    } catch (error, stack) {
      debugPrint('Recursos del acuario: $error\n$stack');
      if (mounted) setState(() => fallo = true);
    }
  }

  @override
  void dispose() {
    reloj.dispose();
    recursos?.dispose();
    super.dispose();
  }

  void reiniciar() {
    reloj.reset();
    if (enMarcha && recursos != null) reloj.repeat();
  }

  void alternarPausa() {
    setState(() => enMarcha = !enMarcha);
    if (enMarcha && recursos != null) {
      reloj.repeat();
    } else {
      reloj.stop();
    }
  }

  Widget tanque() {
    final arte = recursos;
    if (arte == null) {
      return Center(child: fallo
        ? TextButton.icon(onPressed: cargar, icon: const Icon(Icons.refresh),
            label: const Text('Reintentar carga del arrecife'))
        : const CircularProgressIndicator(semanticsLabel: 'Cargando arrecife'));
    }
    if (version == Version.base) {
      return AnimatedBuilder(animation: reloj, builder: (context, _) => CustomPaint(
        painter: FondoMarino(arte),
        foregroundPainter: VidaMarina(escena, arte, reloj, optimizada: false, instante: reloj.value),
        child: const SizedBox.expand(),
      ));
    }
    return Stack(fit: StackFit.expand, children: [
      RepaintBoundary(child: CustomPaint(painter: FondoMarino(arte))),
      RepaintBoundary(child: CustomPaint(
        painter: VidaMarina(escena, arte, reloj, optimizada: true, instante: 0))),
    ]);
  }

  Widget visor(double ancho) {
    final carga = escena.carga;
    return DecoratedBox(
      decoration: BoxDecoration(color: const Color(0xff101f28),
        borderRadius: BorderRadius.circular(18), border: Border.all(color: _linea)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(17)),
          child: SizedBox(height: (ancho * .46).clamp(238.0, 485.0).toDouble(),
            child: Stack(fit: StackFit.expand, children: [
              Semantics(image: true, label: 'Arrecife con ${carga.peces} peces', child: tanque()),
              if (recursos != null)
                Positioned(left: 16, top: 16, child: DecoratedBox(
                  decoration: BoxDecoration(color: const Color(0xcc08252b),
                    borderRadius: BorderRadius.circular(24)),
                  child: Padding(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.circle, size: 8, color: enMarcha ? _menta : Colors.amber),
                      const SizedBox(width: 7),
                      Text(enMarcha ? 'En vivo' : 'En pausa',
                        style: const TextStyle(fontSize: 12, color: Colors.white)),
                    ])),
                )),
            ]),
          )),
        Padding(padding: const EdgeInsets.all(16), child: Wrap(spacing: 24, runSpacing: 10,
          children: [
            _dato(Icons.waves, '${carga.peces} peces'),
            _dato(Icons.bubble_chart_outlined, '${carga.burbujas} burbujas'),
            _dato(Icons.grass_outlined, '${carga.plantas} plantas'),
            _dato(Icons.scatter_plot_outlined, '${carga.particulas} partículas'),
          ])),
      ]),
    );
  }

  Widget _dato(IconData icono, String valor) => Row(mainAxisSize: MainAxisSize.min, children: [
    Icon(icono, size: 17, color: _menta), const SizedBox(width: 7),
    Text(valor, style: const TextStyle(fontSize: 13, color: _suave)),
  ]);

  Widget _grupo<T>(String titulo, List<T> valores, T actual, String Function(T) etiqueta,
      ValueChanged<T> cambiar) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(titulo, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _suave)),
    const SizedBox(height: 7),
    Wrap(spacing: 6, runSpacing: 4, children: [
      for (final valor in valores) ChoiceChip(
        label: Text(etiqueta(valor)), selected: actual == valor, showCheckmark: false,
        selectedColor: _menta, backgroundColor: const Color(0xff132630),
        labelStyle: TextStyle(fontWeight: FontWeight.w600,
          color: actual == valor ? const Color(0xff103d37) : const Color(0xffdfedee)),
        side: BorderSide(color: actual == valor ? _menta : _linea),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
        onSelected: (_) { if (actual != valor) cambiar(valor); },
      ),
    ]),
  ]);

  @override
  Widget build(BuildContext context) => Scaffold(body: SafeArea(
    child: LayoutBuilder(builder: (context, caja) {
      final margen = caja.maxWidth < 600 ? 16.0 : 36.0;
      return ListView(padding: EdgeInsets.fromLTRB(margen, 24, margen, 30), children: [
        Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1160),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const Row(children: [
              Icon(Icons.waves_rounded, color: _menta, size: 23), SizedBox(width: 9),
              Text('Acuario virtual', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ]),
            const SizedBox(height: 17), const Divider(color: _linea, height: 1),
            const SizedBox(height: 22),
            Text('Arrecife tropical', style: TextStyle(fontSize: caja.maxWidth < 600 ? 35 : 48,
              height: 1.1, letterSpacing: -1.4, fontWeight: FontWeight.w500, color: const Color(0xfff1f7ef))),
            const SizedBox(height: 17),
            LayoutBuilder(builder: (context, c) => visor(c.maxWidth)),
            const SizedBox(height: 18),
            Container(padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(color: const Color(0xff101e25),
                border: Border.all(color: _linea), borderRadius: BorderRadius.circular(16)),
              child: Wrap(spacing: 36, runSpacing: 18, crossAxisAlignment: WrapCrossAlignment.end, children: [
                _grupo('Carga gráfica', Carga.values, escena.carga, (v) => v.nombre, (v) {
                  setState(() => escena = Escena(v)); reiniciar();
                }),
                _grupo('Renderizado', Version.values, version,
                  (v) => v == Version.base ? 'Base' : 'Optimizada', (v) {
                    setState(() => version = v); reiniciar();
                  }),
                Wrap(spacing: 8, runSpacing: 5, children: [
                  FilledButton.tonalIcon(onPressed: alternarPausa,
                    icon: Icon(enMarcha ? Icons.pause_rounded : Icons.play_arrow_rounded),
                    label: Text(enMarcha ? 'Pausar' : 'Reanudar')),
                  IconButton.outlined(tooltip: 'Reiniciar escena',
                    onPressed: reiniciar, icon: const Icon(Icons.replay_rounded)),
                ]),
              ])),
          ]))),
      ]);
    }),
  ));
}
