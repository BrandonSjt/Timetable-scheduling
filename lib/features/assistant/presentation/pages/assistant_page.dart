import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/bottom_nav_bar.dart';
import '../../../travel_alarm/presentation/controllers/travel_alarm_controller.dart';
import '../controllers/assistant_controller.dart';
import '../controllers/assistant_conversation_controller.dart';
import '../widgets/assistant_composer.dart';
import '../widgets/assistant_conversation_timeline.dart';
import '../widgets/assistant_quick_actions.dart';
import '../widgets/assistant_voice_panel.dart';

class AssistantPage extends StatefulWidget {
  const AssistantPage({
    super.key,
    this.controller,
    this.alarmController,
    this.conversationController,
  });

  final AssistantController? controller;
  final TravelAlarmController? alarmController;
  final AssistantConversationController? conversationController;

  @override
  State<AssistantPage> createState() => _AssistantPageState();
}

class _AssistantPageState extends State<AssistantPage> {
  late final AssistantController _controller;
  late final bool _ownsController;
  late final TravelAlarmController _alarmController;
  late final bool _ownsAlarmController;
  late final AssistantConversationController _conversationController;
  late final bool _ownsConversationController;
  int _lastConsumedExchangeId = 0;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? AssistantController();
    _ownsAlarmController = widget.alarmController == null;
    _alarmController = widget.alarmController ?? TravelAlarmController();
    _ownsConversationController = widget.conversationController == null;
    _conversationController =
        widget.conversationController ??
        AssistantConversationController(alarmController: _alarmController);
    _lastConsumedExchangeId = _controller.completedExchangeId;
    _controller.addListener(_handleVoiceControllerChange);
    _conversationController.addListener(_handleConversationChange);
    _alarmController.addListener(_handleAlarmChange);
  }

  @override
  void dispose() {
    _controller.removeListener(_handleVoiceControllerChange);
    _conversationController.removeListener(_handleConversationChange);
    _alarmController.removeListener(_handleAlarmChange);
    _controller.cancelConversation();
    if (_controller.wakeWordEnabled) {
      _controller.toggleWakeWord(false);
    }
    if (_ownsController) {
      _controller.dispose();
    }
    if (_ownsConversationController) {
      _conversationController.dispose();
    }
    if (_ownsAlarmController) {
      _alarmController.dispose();
    }
    super.dispose();
  }

  void _handleVoiceControllerChange() {
    if (_controller.completedExchangeId > _lastConsumedExchangeId &&
        _controller.userTranscript != null &&
        _controller.assistantResponse != null) {
      _lastConsumedExchangeId = _controller.completedExchangeId;
      _conversationController.addVoiceExchange(
        transcript: _controller.userTranscript!,
        response: _controller.assistantResponse!,
      );
    }
    if (mounted) setState(() {});
  }

  void _handleConversationChange() {
    if (mounted) setState(() {});
  }

  void _handleAlarmChange() {
    if (mounted) setState(() {});
  }

  void _confirmRoute() {
    context.go(
      Uri(
        path: '/rute',
        queryParameters: const {
          'from': AssistantController.demoOrigin,
          'to': AssistantController.demoDestination,
        },
      ).toString(),
    );
  }

  void _cancelAlarms() {
    if (!_alarmController.state.hasAnyAlarm) return;
    _alarmController.cancelAllAlarms();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Alarm perjalanan dinonaktifkan')),
      );
  }

  VoidCallback? get _voiceAction {
    return switch (_controller.state) {
      AssistantInteractionState.ready ||
      AssistantInteractionState.confirmation ||
      AssistantInteractionState.error => _controller.startConversation,
      AssistantInteractionState.listening => _controller.cancelConversation,
      AssistantInteractionState.speaking => _controller.stopSpeaking,
      AssistantInteractionState.processing => null,
    };
  }

  String get _statusLabel {
    return switch (_controller.state) {
      AssistantInteractionState.ready => 'Siap membantu',
      AssistantInteractionState.listening => 'Mendengarkan',
      AssistantInteractionState.processing => 'Memproses',
      AssistantInteractionState.speaking => 'Berbicara',
      AssistantInteractionState.confirmation => 'Menunggu konfirmasi',
      AssistantInteractionState.error => 'Perlu dicoba lagi',
    };
  }

  Color get _statusColor {
    return switch (_controller.state) {
      AssistantInteractionState.error => AppColors.statusRed,
      AssistantInteractionState.listening => AppColors.accentOrange,
      AssistantInteractionState.processing => AppColors.statusAmber,
      _ => AppColors.statusGreen,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 16),
                    _buildWakeWordSetting(),
                    const SizedBox(height: 12),
                    AssistantVoicePanel(
                      state: _controller.state,
                      onTap: _voiceAction,
                    ),
                    if (_conversationController.items.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      AssistantConversationTimeline(
                        items: _conversationController.items,
                        alarmState: _alarmController.state,
                        onViewTicket: () => context.go('/tiket'),
                        onCancelAlarm: _cancelAlarms,
                        onFindTrip: () => context.go('/cari-stasiun'),
                        onConfirmRoute: _confirmRoute,
                        onRepeatRoute: _controller.repeatResponse,
                        onCancelRoute: _controller.cancelConversation,
                      ),
                    ],
                    const SizedBox(height: 20),
                    const Text(
                      'Tindakan cepat',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    AssistantQuickActions(
                      actions: [
                        AssistantQuickAction(
                          label: 'Rencanakan perjalanan',
                          icon: Icons.route_rounded,
                          onTap: () => context.go('/cari-stasiun'),
                        ),
                        AssistantQuickAction(
                          label: 'Kereta berikutnya',
                          icon: Icons.train_rounded,
                          onTap: () => context.go('/timetable'),
                        ),
                        AssistantQuickAction(
                          label: 'Tiket saya',
                          icon: Icons.confirmation_num_rounded,
                          onTap: () => context.go('/tiket'),
                        ),
                        AssistantQuickAction(
                          label: 'Bantuan petugas',
                          icon: Icons.support_agent_rounded,
                          onTap: () => context.go('/pusat-bantuan'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            AssistantComposer(
              onSubmit: _conversationController.submitText,
              onMicrophoneTap: _voiceAction,
            ),
            const AppBottomNavBar(currentIndex: 3),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primaryBlueLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.headset_mic_rounded,
            color: AppColors.primaryBlue,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Asisten Perjalanan',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 5),
              Semantics(
                liveRegion: true,
                label: 'Status asisten: $_statusLabel',
                child: ExcludeSemantics(
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 7),
                      Flexible(
                        child: Text(
                          _statusLabel,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWakeWordSetting() {
    final enabled = _controller.wakeWordEnabled;
    return Semantics(
      container: true,
      label: 'Mode kata pemicu Halo Asisten',
      value: enabled ? 'aktif' : 'nonaktif',
      toggled: enabled,
      onTap: () => _controller.toggleWakeWord(!enabled),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
        decoration: BoxDecoration(
          color: enabled
              ? AppColors.statusGreen.withValues(alpha: 0.08)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: enabled
                ? AppColors.statusGreen.withValues(alpha: 0.45)
                : AppColors.cardBorder,
          ),
        ),
        child: Row(
          children: [
            Icon(
              enabled ? Icons.hearing_rounded : Icons.hearing_disabled_rounded,
              color: enabled ? AppColors.statusGreen : AppColors.textSecondary,
              size: 22,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Dengarkan "Halo Asisten"',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    enabled
                        ? 'Kata pemicu aktif'
                        : 'Aktif hanya di halaman ini',
                    style: TextStyle(
                      color: enabled
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            ExcludeSemantics(
              child: Switch(
                key: const Key('wake-word-switch'),
                value: enabled,
                onChanged: _controller.toggleWakeWord,
                activeThumbColor: AppColors.statusGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
