import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/bottom_nav_bar.dart';
import '../../data/datasources/station_remote_data_source.dart';
import '../../data/repositories/station_repository_impl.dart';
import '../controllers/station_controller.dart';
import '../widgets/station_card.dart';

class SearchStationPage extends StatefulWidget {
  const SearchStationPage({super.key});

  @override
  State<SearchStationPage> createState() => _SearchStationPageState();
}

class _SearchStationPageState extends State<SearchStationPage> {
  final _search = TextEditingController();
  late final StationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = StationController(
      StationRepositoryImpl(StationRemoteDataSource()),
    )..load();
  }

  @override
  void dispose() {
    _search.dispose();
    _controller.dispose();
    super.dispose();
  }

  Color _statusColor(String? value) {
    final hex = value?.replaceFirst('#', '');
    return hex != null && hex.length == 6
        ? Color(int.parse('FF$hex', radix: 16))
        : AppColors.statusGreen;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final query = GoRouterState.of(context).uri.queryParameters;
    final fromStation = query['from'];
    final fromStationId = query['fromId'];
    final selectingDestination = query['action'] == 'select_destination';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListenableBuilder(
                listenable: _controller,
                builder: (context, _) {
                  final stations = _controller.filtered(
                    excludedName: selectingDestination ? fromStation : null,
                  );
                  return RefreshIndicator(
                    onRefresh: _controller.load,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                      children: [
                        _Header(
                          title: selectingDestination
                              ? l10n.selectDestination
                              : l10n.searchStationTitle,
                          onBack: () => context.go(
                            Uri(
                              path: '/',
                              queryParameters: {
                                'from': ?fromStation,
                                'fromId': ?fromStationId,
                              },
                            ).toString(),
                          ),
                        ),
                        if (selectingDestination && fromStation != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            l10n.startTripFrom(fromStation),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        TextField(
                          controller: _search,
                          onChanged: _controller.search,
                          decoration: InputDecoration(
                            hintText: l10n.searchStationHint,
                            prefixIcon: const Icon(Icons.search_rounded),
                            suffixIcon: _controller.query.isEmpty
                                ? null
                                : IconButton(
                                    onPressed: () {
                                      _search.clear();
                                      _controller.search('');
                                    },
                                    icon: const Icon(Icons.clear_rounded),
                                  ),
                            filled: true,
                            fillColor: AppColors.surface,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.cardBorder,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.serviceFilter,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _filter(l10n.all, 'all'),
                              _filter('LRT', 'LRT'),
                              _filter('KRL', 'KRL'),
                              _filter('MRT', 'MRT'),
                              _filter(l10n.accessible, 'accessible'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          l10n.quickResults,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (_controller.isLoading)
                          const Padding(
                            padding: EdgeInsets.all(40),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        else if (_controller.error != null)
                          _ErrorState(onRetry: _controller.load)
                        else if (stations.isEmpty)
                          Padding(
                            padding: const EdgeInsets.all(40),
                            child: Center(child: Text(l10n.stationNotFound)),
                          )
                        else
                          ...stations.map(
                            (station) => StationCard(
                              name: station.name,
                              code: station.codes,
                              lineInfo: station.lineInfo ?? station.services,
                              statusText: station.statusText ?? '',
                              statusColor: _statusColor(station.statusColor),
                              onTap: () => context.go(
                                Uri(
                                  path: '/',
                                  queryParameters: {
                                    'selected': station.name,
                                    'selectedId': station.slug,
                                    'from': ?fromStation,
                                    'fromId': ?fromStationId,
                                  },
                                ).toString(),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
            AppBottomNavBar(currentIndex: selectingDestination ? 0 : 1),
          ],
        ),
      ),
    );
  }

  Widget _filter(String label, String value) => Padding(
    padding: const EdgeInsets.only(right: 8),
    child: ServiceFilterChip(
      label: label,
      isSelected: _controller.filter == value,
      onTap: () => _controller.selectFilter(value),
    ),
  );
}

class _Header extends StatelessWidget {
  const _Header({required this.title, required this.onBack});
  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      TextButton(
        onPressed: onBack,
        child: const Icon(Icons.arrow_back_rounded),
      ),
      Expanded(
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      const CircleAvatar(
        backgroundColor: AppColors.a11yYellow,
        child: Text(
          'A11Y',
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
        ),
      ),
    ],
  );
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 32),
    child: Column(
      children: [
        const Text('Data stasiun belum dapat dimuat.'),
        const SizedBox(height: 8),
        OutlinedButton(onPressed: onRetry, child: const Text('Coba lagi')),
      ],
    ),
  );
}
