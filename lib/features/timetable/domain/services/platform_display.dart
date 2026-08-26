/// Display helpers for schedule platform / Peron values.
///
/// Empty, dash, and placeholder API values must never be shown as a real
/// platform number. Users are always reminded to confirm on-station boards.
abstract final class PlatformDisplay {
  static bool isAvailable(String? platform) {
    final value = platform?.trim() ?? '';
    if (value.isEmpty) return false;
    final normalized = value.toLowerCase();
    return normalized != '-' &&
        normalized != 'n/a' &&
        normalized != 'na' &&
        normalized != 'null';
  }

  static String label(String? platform) {
    if (!isAvailable(platform)) return 'Peron belum tersedia';
    return 'Peron ${platform!.trim()}';
  }

  static const checkBoardHint = 'Cek papan informasi stasiun';
}
