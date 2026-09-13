import 'dart:io';

class AppConfig {
  final String host;
  final int porta;

  final String? videoDescanso;
  final int tempoDescansoSegundos;

  const AppConfig({
    required this.host,
    required this.porta,
    this.videoDescanso,
    this.tempoDescansoSegundos = 60,
  });

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    final hostJson = json['host']?.toString().trim();
    return AppConfig(
      host: hostJson != null && hostJson.isNotEmpty ? hostJson : hostPadrao,
      porta: int.tryParse(json['porta']?.toString() ?? '') ?? 8082,
      videoDescanso: json['videoDescanso']?.toString().trim(),

      tempoDescansoSegundos:
          int.tryParse(json['tempoDescansoSegundos']?.toString() ?? '') ?? 60,
    );
  }
  bool get possuiVideoDescanso {
    return videoDescanso != null && videoDescanso!.trim().isNotEmpty;
  }

  static String get hostPadrao {
    if (Platform.isWindows) {
      return '127.0.0.1';
    }

    return '127.0.0.1';
  }

  Map<String, dynamic> toJson() {
    return {'host': host, 'porta': porta};
  }

  factory AppConfig.padrao() {
    return AppConfig(host: hostPadrao, porta: 8082);
  }
}
