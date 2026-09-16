import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/routes/app_routes.dart';
import '../data/ai_gateway.dart';

/// A frontend prototype of the tool-based Care Companion. It intentionally
/// guides users to app actions rather than pretending to diagnose or prescribe.
class CareAssistantScreen extends StatefulWidget {
  const CareAssistantScreen({super.key});

  @override
  State<CareAssistantScreen> createState() => _CareAssistantScreenState();
}

class _CareAssistantScreenState extends State<CareAssistantScreen> {
  static const _ai = AiGateway();
  final _controller = TextEditingController();
  bool _isThinking = false;
  _AssistantAction? _nextAction;
  final _messages = <_ChatMessage>[
    const _ChatMessage(false, 'Hi Ashmit — I can help organise care, find the right service, book appointments, or explain a report in simple language.'),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _ask(String text) async {
    final prompt = text.trim();
    if (prompt.isEmpty || _isThinking) return;
    final action = _actionFor(prompt);
    setState(() {
      _messages.add(_ChatMessage(true, prompt));
      _isThinking = true;
      _nextAction = null;
    });
    _controller.clear();
    final liveReply = await _ai.reply(prompt);
    await Future<void>.delayed(const Duration(milliseconds: 320));
    if (!mounted) return;
    setState(() {
      _messages.add(_ChatMessage(false, liveReply ?? _replyFor(prompt)));
      _isThinking = false;
      _nextAction = action;
    });
  }

  String _replyFor(String text) {
    final query = text.toLowerCase();
    if (query.contains('ambulance') || query.contains('emergency') || query.contains('chest')) {
      return 'If this may be an emergency, call 112 immediately. I can also open ApnaCare Emergency to share the patient’s location, emergency card, and contacts with the response team.';
    }
    if (query.contains('report') || query.contains('prescription')) {
      return 'Upload the document to the Health Vault and I’ll make a simple summary and a list of questions for the doctor. I do not diagnose conditions or change medicines.';
    }
    if (query.contains('appointment') || query.contains('doctor')) {
      return 'I can compare available doctors by specialty, fee, distance, language, and next slot. Your Care Circle will receive the booking and reminder automatically.';
    }
    return 'I can turn this into a care task, help choose a service, arrange a booking, or organise it in the patient’s Care Circle. What would you like to do?';
  }

  _AssistantAction _actionFor(String text) {
    final query = text.toLowerCase();
    if (query.contains('ambulance') || query.contains('emergency') || query.contains('chest')) {
      return const _AssistantAction(Icons.emergency_rounded, 'Open Emergency Care Room', AppRoutes.emergencyCommand);
    }
    if (query.contains('report') || query.contains('prescription')) {
      return const _AssistantAction(Icons.folder_shared_rounded, 'Open Health Vault', AppRoutes.careHub);
    }
    if (query.contains('appointment') || query.contains('doctor')) {
      return const _AssistantAction(Icons.calendar_month_rounded, 'Find a doctor', AppRoutes.doctors);
    }
    return const _AssistantAction(Icons.add_task_rounded, 'Create a care reminder', AppRoutes.careHub);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          surfaceTintColor: Colors.transparent,
          title: Row(children: [Container(width: 36, height: 36, decoration: const BoxDecoration(gradient: AppColors.primaryGradient, shape: BoxShape.circle), child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 20)), const SizedBox(width: 10), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Care Companion', style: AppTextStyles.bodySemiBold()), Text('Care navigation · safe fallback enabled', style: AppTextStyles.labelSmall(color: AppColors.textMuted))])]),
        ),
        body: SafeArea(
          child: Column(children: [
            Expanded(child: ListView(padding: const EdgeInsets.fromLTRB(20, 16, 20, 12), children: [
              const _SafetyNotice(),
              const SizedBox(height: 18),
              ..._messages.map((message) => _MessageBubble(message: message)),
              if (_isThinking) const _TypingBubble(),
              if (!_isThinking && _nextAction != null) _ActionCard(action: _nextAction!, onTap: () => Navigator.pushNamed(context, _nextAction!.route)),
              const SizedBox(height: 12),
              Wrap(spacing: 8, runSpacing: 8, children: [
                _PromptChip('Find a doctor', () => _ask('Help me find a doctor')),
                _PromptChip('Organise a report', () => _ask('I want to understand a report')),
                _PromptChip('Emergency help', () => _ask('I need ambulance emergency help')),
                _PromptChip('Create a reminder', () => _ask('Create a medicine reminder')),
              ]),
            ])),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: AppColors.cardBorder))),
              child: Row(children: [
                Expanded(
                  child: TextField(
                      controller: _controller, onSubmitted: _ask,
                      decoration: InputDecoration(
                          hintText: 'Ask about care, bookings, reports…',
                          hintStyle: AppTextStyles.label(color: AppColors.textHint),
                          filled: true,
                          fillColor: AppColors.primaryLight,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)))),
                const SizedBox(width: 10),
                IconButton(style: IconButton.styleFrom(backgroundColor: _isThinking ? AppColors.textMuted : AppColors.primary, foregroundColor: Colors.white), onPressed: _isThinking ? null : () => _ask(_controller.text), icon: Icon(_isThinking ? Icons.hourglass_top_rounded : Icons.arrow_upward_rounded)),
                // )
               ]
              ),
            ),
          ]),
        ),
      );
}

class _ChatMessage {
  final bool fromUser;
  final String text;
  const _ChatMessage(this.fromUser, this.text);
}

class _MessageBubble extends StatelessWidget {
  final _ChatMessage message;
  const _MessageBubble({required this.message});
  @override
  Widget build(BuildContext context) => Align(
        alignment: message.fromUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 330),
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          decoration: BoxDecoration(color: message.fromUser ? AppColors.primary : Colors.white, borderRadius: BorderRadius.circular(18), border: message.fromUser ? null : Border.all(color: AppColors.cardBorder)),
          child: Text(message.text, style: AppTextStyles.bodyMedium(color: message.fromUser ? Colors.white : AppColors.textPrimary).copyWith(height: 1.35)),
        ),
      );
}

class _PromptChip extends StatelessWidget {
  final String label; final VoidCallback onTap;
  const _PromptChip(this.label, this.onTap);
  @override
  Widget build(BuildContext context) => ActionChip(label: Text(label), onPressed: onTap, backgroundColor: Colors.white, side: const BorderSide(color: AppColors.cardBorder), labelStyle: AppTextStyles.labelBold(color: AppColors.primaryDark));
}

class _AssistantAction {
  final IconData icon;
  final String label;
  final String route;
  const _AssistantAction(this.icon, this.label, this.route);
}

class _ActionCard extends StatelessWidget {
  final _AssistantAction action;
  final VoidCallback onTap;
  const _ActionCard({required this.action, required this.onTap});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
        ),
        child: Row(children: [
          Container(width: 36, height: 36, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle), child: Icon(action.icon, color: Colors.white, size: 19)),
          const SizedBox(width: 10),
          Expanded(child: Text(action.label, style: AppTextStyles.labelBold(color: AppColors.primaryDark))),
          TextButton.icon(onPressed: onTap, icon: const Icon(Icons.arrow_forward_rounded, size: 16), label: const Text('Open')),
        ]),
      );
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.cardBorder)),
          child: Text('Care Companion is preparing an action…', style: AppTextStyles.label(color: AppColors.textMuted)),
        ),
      );
}

class _SafetyNotice extends StatelessWidget {
  const _SafetyNotice();
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(13), decoration: BoxDecoration(color: AppColors.accentLight, borderRadius: BorderRadius.circular(15)), child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(Icons.info_outline_rounded, color: AppColors.accent), SizedBox(width: 9), Expanded(child: Text('For emergencies or severe symptoms, call 112. Care Companion supports navigation and organisation; it does not diagnose or prescribe.', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.35)))]));
}
