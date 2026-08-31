// class PdvPaths {
//   static const String root = r'D:\vmix\vmix';

//   static const String parametros = r'D:\vmix\vmix\param\parametros_pdv.xml';

//   static const String pictures = r'D:\vmix\vmix\pictures';
// }

import 'dart:io';

class PdvPaths {
  static String get root {
    if (Platform.isWindows) {
      return r'D:\vmix\vmix';
    }

    return '/vmix/vmix';
  }

  static String get parametros {
    if (Platform.isWindows) {
      return r'D:\vmix\vmix\param\parametros_pdv.xml';
    }

    return '/vmix/vmix/dataisp/linux/param/parametros_pdv.xml';
  }

  static String get pictures {
    if (Platform.isWindows) {
      return r'D:\vmix\vmix\pictures';
    }

    return '/vmix/vmix/pictures';
  }
}
