import 'package:flutter/material.dart';

// 1. Colores
class AppColores {
  static const Color textoOscuro = Color(0xFF2B2B2B); // este va a ser nuestro "negro"
  static const Color fondo = Color(0xFFF6F3EF); // El color de fondo principal
  static const Color falsoBlanco = Color(0xFFFAF8F5); // tono más claro que fondo (F6F3EF)
  static const Color grisClaro = Color(0xFFACBABA); // para bordes inactivos
  static const Color grisPrimari = Color(0xFF718989); // para grises relacionados con los secundarios
  static const Color grisSecundari = Color(0xFFA6919A); // para grises relacionados con los primarios
  static const Color primariOscuro = Color(0xFF233C3C); // para tipografias, botones, un negro secundario
  static const Color primario = Color(0xFF1B5D60); // Color principal
  static const Color secundario = Color(0xFFA8547A); // Detalles y selecciones
  static const Color secundariOscuro = Color(0xFF7A3958); // versión oscura del secundario (calculado)
  static const Color error = Color(0xFF762B30); // Para los errores
  static const Color acierto = Color(0xFF305237); // Para Aciertos
}

//2. Tamaños
class AppTamanios {
  //usamos el 8 como base unitaria para respetar nuestra teoria de diseño
  static const double base = 8.0;
  static const double xs = base * 0.5; // 4.0
  static const double sm = base; // 8.0
  static const double md = base * 2; // 16.0
  static const double lg = base * 3; // 24.0
  static const double xl = base * 4; // 32.0
  static const double xxl = base * 5; // 40.0
  static const double xxxl = base * 6; // 48.0
}

// 3. Fuentes
class AppFonts {
  static const String mainFont = 'RedHatMono';
}

// 4. Estilo de Texto
class AppEstiloTexto {
  static const TextStyle titulo = TextStyle(
      fontFamily: AppFonts.mainFont,
      fontSize: AppTamanios.lg,
      fontWeight: FontWeight.bold,
      color: AppColores.textoOscuro,
      shadows: [
        Shadow(offset: Offset(.6, .6), color: AppColores.textoOscuro),
        Shadow(offset: Offset(-.6, .6), color: AppColores.textoOscuro),
        Shadow(offset: Offset(.6, -.6), color: AppColores.textoOscuro),
        Shadow(offset: Offset(-.6, -.6), color: AppColores.textoOscuro),
      ]); //hacemos variables de los diferentes estilos de texto.

  static const TextStyle subtitulo = TextStyle(
    fontFamily: AppFonts.mainFont,
    fontSize: AppTamanios.md,
    fontWeight: FontWeight.bold,
    color: AppColores.textoOscuro,
  );

  static const TextStyle boton = TextStyle(
    fontFamily: AppFonts.mainFont,
    fontSize: AppTamanios.lg,
    fontWeight: FontWeight.bold,
    color: AppColores.fondo,
    shadows: [
      Shadow(offset: Offset(1, 1), color: AppColores.grisClaro),
      Shadow(offset: Offset(-1, 1), color: AppColores.grisClaro),
      Shadow(offset: Offset(1, -1), color: AppColores.grisClaro),
      Shadow(offset: Offset(-1, -1), color: AppColores.grisClaro),
    ], //Para hacer el borde usamos la sombra porque no nos deja meter borde el TextStyle.
  );

  static const TextStyle cuerpo = TextStyle(
    fontFamily: AppFonts.mainFont,
    fontSize: AppTamanios.md,
    fontWeight: FontWeight.normal,
    color: AppColores.primario,
  );

  static const TextStyle notaXS = TextStyle(
    fontFamily: AppFonts.mainFont,
    fontSize: AppTamanios.xs * 3,
    fontWeight: FontWeight.w400,
    color: AppColores.primario,
  );
  static const TextStyle notaM = TextStyle(
    fontFamily: AppFonts.mainFont,
    fontSize: AppTamanios.md,
    fontWeight: FontWeight.w400,
    color: AppColores.primario,
  );

  static const TextStyle exito = TextStyle(
    fontFamily: AppFonts.mainFont,
    fontSize: AppTamanios.md,
    fontWeight: FontWeight.bold,
    color: AppColores.acierto,
  );

  static const TextStyle error = TextStyle(
    fontFamily: AppFonts.mainFont,
    fontSize: AppTamanios.md,
    fontWeight: FontWeight.bold,
    color: AppColores.error,
  );
}

// 5. Texto widget

class AppTexto {
  static Widget titulo(
    String texto, {
    TextAlign align = TextAlign.start,
    int maxLines = 1,
    TextOverflow overflow = TextOverflow.ellipsis,
    Color? color,
  }) {
    return Text(
      texto,
      textAlign: align,
      maxLines: maxLines,
      overflow: overflow,
      style: color != null
          ? AppEstiloTexto.titulo.copyWith(color: color, shadows: [
              Shadow(offset: const Offset(.6, .6), color: color),
              Shadow(offset: const Offset(-.6, .6), color: color),
              Shadow(offset: const Offset(.6, -.6), color: color),
              Shadow(offset: const Offset(-.6, -.6), color: color),
            ])
          : AppEstiloTexto.titulo,
    );
  }

  static Widget subtitulo(
    String texto, {
    TextAlign align = TextAlign.start,
    int maxLines = 1,
    TextOverflow overflow = TextOverflow.ellipsis,
    Color? color,
  }) {
    return Text(
      texto,
      textAlign: align,
      maxLines: maxLines,
      overflow: overflow,
      style: AppEstiloTexto.subtitulo.copyWith(
        color: color ?? AppEstiloTexto.subtitulo.color,
      ),
    );
  }

  static Widget textoBoton(
    String texto, {
    TextAlign align = TextAlign.center,
    int maxLines = 1,
    TextOverflow overflow = TextOverflow.ellipsis,
  }) {
    return Text(
      texto,
      textAlign: align,
      maxLines: maxLines,
      overflow: overflow,
      style: AppEstiloTexto.boton,
    );
  }

  static Widget textoCuerpo(
    String texto, {
    TextAlign align = TextAlign.start,
    int maxLines = 8,
    TextOverflow overflow = TextOverflow.ellipsis,
  }) {
    return Text(
      texto,
      textAlign: align,
      maxLines: maxLines,
      overflow: overflow,
      style: AppEstiloTexto.cuerpo,
    );
  }

  static Widget textoNotaXS(
    String texto, {
    TextAlign align = TextAlign.start,
    int maxLines = 8,
    TextOverflow overflow = TextOverflow.ellipsis,
  }) {
    return Text(
      texto,
      textAlign: align,
      maxLines: maxLines,
      overflow: overflow,
      style: AppEstiloTexto.notaXS,
    );
  }

  static Widget textoNotaM(
    String texto, {
    TextAlign align = TextAlign.start,
    int maxLines = 8,
    TextOverflow overflow = TextOverflow.ellipsis,
  }) {
    return Text(
      texto,
      textAlign: align,
      maxLines: maxLines,
      overflow: overflow,
      style: AppEstiloTexto.notaM,
    );
  }

  static Widget textoExito(
    String texto, {
    TextAlign align = TextAlign.start,
    int maxLines = 8,
    TextOverflow overflow = TextOverflow.ellipsis,
  }) {
    return Text(
      texto,
      textAlign: align,
      maxLines: maxLines,
      overflow: overflow,
      style: AppEstiloTexto.exito,
    );
  }

  static Widget textoError(
    String texto, {
    TextAlign align = TextAlign.start,
    int maxLines = 8,
    TextOverflow overflow = TextOverflow.ellipsis,
  }) {
    return Text(
      texto,
      textAlign: align,
      maxLines: maxLines,
      overflow: overflow,
      style: AppEstiloTexto.error,
    );
  }
}

// 6. Nagrita (esta fuente no tiene negrita, asi que vamos a forzarla)

class AppExtraBold {
  static List<Shadow> extraBold(Color color, double grosor) {
    return [
      Shadow(
        offset: Offset(grosor, grosor),
        color: color,
      ),
      Shadow(
        offset: Offset(-grosor, grosor),
        color: color,
      ),
      Shadow(
        offset: Offset(grosor, -grosor),
        color: color,
      ),
      Shadow(
        offset: Offset(-grosor, -grosor),
        color: color,
      ),
    ];
  }
}

// 7. Sombra dinamica:

class AppSombra {
  static List<BoxShadow> contenedores({
    Color? color = AppColores.primariOscuro,
    double? ejeH = .5,
    double? ejeV = .5,
    double? opacidad = .5,
    double? difuminado = 4,
    BlurStyle? direccion = BlurStyle.normal,
  }) {
    return [
      BoxShadow(
        offset: Offset(ejeH!, ejeV!),
        color: color!.withOpacity(opacidad!),
        blurRadius: difuminado!,
        blurStyle: direccion!,
      ),
    ];
  }
}
