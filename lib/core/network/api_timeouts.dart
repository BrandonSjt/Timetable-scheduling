/// Shared HTTP timeouts for free-tier / cold-start backends.
///
/// Free hosts can take longer than a typical LAN request on the first wake.
/// Keep a longer primary timeout so cold starts are not treated as empty data.
abstract final class ApiTimeouts {
  static const request = Duration(seconds: 25);
  static const health = Duration(seconds: 15);
}
