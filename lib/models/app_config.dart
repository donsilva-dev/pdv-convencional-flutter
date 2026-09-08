class AppConfig {
  final String host;
  final int porta;

  const AppConfig({required this.host, required this.porta});

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    final hostJson = json['host']?.toString().trim();

    return AppConfig(
      host: hostJson != null && hostJson.isNotEmpty ? hostJson : '127.0.0.1',
      porta: int.tryParse(json['porta']?.toString() ?? '') ?? 8082,
    );
  }

  Map<String, dynamic> toJson() {
    return {'host': host, 'porta': porta};
  }

  factory AppConfig.padrao() {
    return const AppConfig(host: '127.0.0.1', porta: 8082);
  }
}
