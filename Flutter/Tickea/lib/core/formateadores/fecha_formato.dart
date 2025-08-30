import 'package:intl/intl.dart';

String fmtFecha(DateTime f) => DateFormat('dd_MM_yyyy').format(
      DateTime(f.year, f.month, f.day),
    );

DateTime formatoDia(DateTime d) => DateTime(d.year, d.month, d.day);
