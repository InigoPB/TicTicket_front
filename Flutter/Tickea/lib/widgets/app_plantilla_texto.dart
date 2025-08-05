import 'package:flutter/cupertino.dart';
import 'package:tickea/core/theme/app_styles.dart';

class AppTexto {
  static Widget titulo(
    String texto, {
    TextAlign align = TextAlign.start,
    int maxLines = 1,
    TextOverflow overflow = TextOverflow.ellipsis,
  }) {
    return Text(
      texto,
      textAlign: align,
      maxLines: maxLines,
      overflow: overflow,
      style: AppEstiloTexto.titulo,
    );
  }

  static Widget subtitulo(
    String texto, {
    TextAlign align = TextAlign.start,
    int maxLines = 1,
    TextOverflow overflow = TextOverflow.ellipsis,
  }) {
    return Text(
      texto,
      textAlign: align,
      maxLines: maxLines,
      overflow: overflow,
      style: AppEstiloTexto.subtitulo,
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
