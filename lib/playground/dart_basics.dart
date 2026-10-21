void main() {
  ejercicioVariables();
  // TODO(sesion-02): borra la línea de abajo y descomenta el bloque completo.
  print(
    '--- Control de flujo: pendiente (descomenta ejercicioControlDeFlujo) ---',
  );
  ejercicioControlDeFlujo();
  // TODO(sesion-02): borra la línea de abajo y descomenta el bloque completo.
  print('--- Bucles: pendiente (descomenta ejercicioBucles) ---');
  ejercicioBucles();
  // TODO(sesion-02): borra la línea de abajo y descomenta el bloque completo.
  print('--- Null safety: pendiente (descomenta ejercicioNullSafety) ---');
  ejercicioNullSafety();
  // TODO(sesion-02): borra la línea de abajo y descomenta el bloque completo.
  print('--- Funciones: pendiente (descomenta ejercicioFunciones) ---');
  ejercicioFunciones();
  // TODO(sesion-02): borra la línea de abajo y descomenta el bloque completo.
  print('--- Colecciones: pendiente (descomenta ejercicioColecciones) ---');
  ejercicioColecciones();
  // TODO(sesion-02): borra la línea de abajo y descomenta el bloque completo.
  print('--- Clases y herencia: pendiente (descomenta ejercicioClases) ---');
  ejercicioClases();
}

void ejercicioVariables() {
  var nombre = 'ExploraEC';
  final creado = DateTime.now();
  const version = '1.0.0';
  print('App: $nombre v$version — creado: $creado');
}

// TODO(sesion-02): borra la línea de abajo y descomenta el bloque completo.
void ejercicioControlDeFlujo() {
  String categorizarDistancia(double metros) {
    if (metros < 500) {
      return 'Muy cerca';
    } else if (metros < 2000) {
      return 'Cerca';
    } else {
      return 'Lejos';
    }
  }

  print(categorizarDistancia(300));
  print(categorizarDistancia(1200));
  print(categorizarDistancia(5000));
}

// TODO(sesion-02): borra la línea de abajo y descomenta el bloque completo.
void ejercicioBucles() {
  final nombresDeEjemplo = ['Parque Ejido', 'Café Central', 'Museo'];
  for (final nombre in nombresDeEjemplo) {
    print('Lugar: $nombre');
  }
  //
  var contador = 0;
  while (contador < 3) {
    print('Vuelta número $contador');
    contador++;
  }
}

// TODO(sesion-02): borra la línea de abajo y descomenta el bloque completo.
void ejercicioNullSafety() {
  String? apodo;
  print('Apodo antes de asignar: ${apodo ?? "(sin apodo)"}');
  apodo = 'Explo';
  print('Apodo ya asignado, longitud: ${apodo.length}');
}

// TODO(sesion-02): borra la línea de abajo y descomenta el bloque completo.
void ejercicioFunciones() {
  String saludar(
    String nombre, {
    String saludo = 'Hola',
    bool mayusculas = false,
  }) {
    final texto = '$saludo, $nombre';
    return mayusculas ? texto.toUpperCase() : texto;
  }

  //
  print(saludar('Ana'));
  print(saludar('Ana', saludo: 'Bienvenida', mayusculas: true));
}

// TODO(sesion-02): borra la línea de abajo y descomenta el bloque completo.
void ejercicioColecciones() {
  final categorias = <String>{'Parque', 'Cafetería', 'Museo'};
  print('Categorías únicas: $categorias');
  //
  final distancias = <String, double>{'Parque Ejido': 300, 'Museo': 1800};
  print('Distancia al Museo: ${distancias['Museo']} m');
  print('Distancia a un lugar inexistente: ${distancias['Playa']}');
  //
  final nombres = ['Café Central', 'Parque Ejido', 'Museo'];
  final conCafe = nombres.where((n) => n.contains('Café')).toList();
  print('Lugares con "Café": $conCafe');
}

// TODO(sesion-02): borra la línea de abajo y descomenta el bloque completo.
void ejercicioClases() {
  final ana = Persona('Ana', 28);
  print(ana.presentarse());
  //
  final consola = Consola();
  consola.notificar('Lugar agregado con éxito');
}

//
class Persona {
  final String nombre;
  final int edad;

  Persona(this.nombre, this.edad);
  String presentarse() => 'Soy $nombre y tengo $edad años';
}

//
abstract class Notificable {
  void notificar(String mensaje);
}

//
class Consola extends Notificable {
  void notificar(String mensaje) => print('Aviso: $mensaje');
}
