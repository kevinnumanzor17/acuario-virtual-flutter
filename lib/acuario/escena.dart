import 'dart:math';

enum Carga {
  baja('Baja', 8, 16, 6, 30),
  media('Media', 32, 64, 14, 120),
  alta('Alta', 96, 192, 30, 360);

  const Carga(this.nombre, this.peces, this.burbujas, this.plantas, this.particulas);
  final String nombre;
  final int peces;
  final int burbujas;
  final int plantas;
  final int particulas;
}

enum Version { base, optimizada }

/// Posición inicial, velocidad relativa, tamaño y fase de un elemento.
class Elemento {
  Elemento(Random azar)
      : x = azar.nextDouble(),
        y = azar.nextDouble(),
        rapidez = azar.nextDouble(),
        escala = azar.nextDouble(),
        fase = azar.nextDouble() * 2 * pi;
  final double x, y, rapidez, escala, fase;
}

class Escena {
  Escena(this.carga);
  final Carga carga;
  // Los peces lejanos (más pequeños) se dibujan primero.
  late final ordenPeces = List<int>.generate(peces.length, (i) => i)
    ..sort((a, b) => peces[a].escala.compareTo(peces[b].escala));
  // Una semilla por familia conserva los primeros elementos al aumentar la carga.
  late final peces = _crear(carga.peces, 901);
  late final burbujas = _crear(carga.burbujas, 902);
  late final plantas = _crear(carga.plantas, 903);
  late final particulas = _crear(carga.particulas, 904);

  static List<Elemento> _crear(int cantidad, int semilla) {
    final azar = Random(semilla);
    return List.generate(cantidad, (_) => Elemento(azar), growable: false);
  }
}
