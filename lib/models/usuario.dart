/// Usuario de la sesión, tal como lo devuelve `GET /usuarios/me` — Sesión 8.
class Usuario {
  final int id;
  final String email;
  const Usuario({required this.id, required this.email});

  factory Usuario.fromJson(Map<String, dynamic> json) => Usuario(
        id: (json['id'] as num).toInt(),
        email: json['email'] as String,
      );
}
