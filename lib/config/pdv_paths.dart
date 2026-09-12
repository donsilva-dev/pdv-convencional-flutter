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

  static String get lottie {
    if (Platform.isWindows) {
      return r'D:\vmix\vmix\pictures\data\lottie';
    }

    return '/vmix/vmix/pictures/data/lottie';
  }

  static String get pictures {
    if (Platform.isWindows) {
      return r'D:\vmix\vmix\pictures';
    }

    return '/vmix/vmix/pictures';
  }

  static String get vmixConfig {
    if (Platform.isWindows) {
      return r'D:\vmix\vmix\vmix.cfg';
    }

    return '/vmix/vmix/vmix.cfg';
  }

  static String get svg {
    if (Platform.isWindows) {
      return r'D:\vmix\vmix\pictures\data\assets\icons';
    }
    return '/vmix/vmix/pictures/data/assets/icons';
  }

  static String imagem(String nomeArquivo) {
    return '$pictures${Platform.pathSeparator}$nomeArquivo';
  }

  // Pasta onde o executável Flutter está rodando.
  static String get bundle {
    return File(Platform.resolvedExecutable).parent.path;
  }

  // /bundle/logs
  static String get logs {
    return '$bundle${Platform.pathSeparator}logs';
  }

  // /bundle/config.json
  static String get config {
    if (Platform.isWindows) {
      return r'D:\vmix\vmix\config.json';
    }

    return '$bundle${Platform.pathSeparator}config.json';
  }
}
