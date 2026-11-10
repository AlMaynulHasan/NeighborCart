import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/pool_model.dart';
import '../../models/user_model.dart';
import '../../services/pool_service.dart';
import '../../services/report_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/stream_view.dart';

/// ASSUMPTION: no Figma design — a simple complaint form (consumer protection).
class ReportProblemScreen extends StatefulWidget {
  final UserModel user;
  const ReportProblemScreen({super.key, required this.user});

  @override
  State<ReportProblemScreen> createState() => _ReportProblemScreenState();
}

class _ReportProblemScreenState extends State<ReportProblemScreen> {
  static const _categories = [
    'Missing or wrong item',
    'Quality or expiry problem',
    'Payment problem',
    'Coordinator or pickup issue',
    'Something else',
  ];

  final _messageController = TextEditingController();
  String _category = _categories.first;
  PoolModel? _pool;
  String? _error;
  bool _sending = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_messageController.text.trim().isEmpty) {
      setState(() => _error = 'Please describe the problem');
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    setState(() {
      _error = null;
      _sending = true;
    });
    try {
      final id = await ReportService.instance.submit(
        category: _category,
        message: _messageController.text,
        poolId: _pool?.id,
        poolName: _pool?.name,
      );
      messenger.showSnackBar(SnackBar(content: Text('Report sent. Reference ${id.substring(0, 6).toUpperCase()}.')));
      navigator.pop();
    } catch (_) {
      messenger.showSnackBar(const SnackBar(content: Text('Could not send the report. Please try again.')));
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(title: const Text('Report a Problem')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('What went wrong?', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _category,
                items: [for (final c in _categories) DropdownMenuItem(value: c, child: Text(c))],
                onChanged: (v) => setState(() => _category = v ?? _category),
              ),
              const SizedBox(height: 16),
              Text('Related pool (optional)', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              StreamView<List<PoolModel>>(
                create: () => PoolService.instance.watchPools(),
                builder: (context, pools) {
                  final mine = pools.where((p) => widget.user.joinedPoolIds.contains(p.id)).toList();
                  return DropdownButtonFormField<String?>(
                    initialValue: _pool?.id,
                    items: [
                      const DropdownMenuItem<String?>(value: null, child: Text('No specific pool')),
                      for (final p in mine) DropdownMenuItem<String?>(value: p.id, child: Text(p.name)),
                    ],
                    onChanged: (id) => setState(() {
                      _pool = id == null ? null : mine.firstWhere((p) => p.id == id);
                    }),
                  );
                },
              ),
              const SizedBox(height: 16),
              Text('Details', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              TextField(
                controller: _messageController,
                maxLines: 5,
                maxLength: 1000,
                decoration: InputDecoration(hintText: 'Tell us what happened', errorText: _error),
              ),
              const SizedBox(height: 16),
              CustomButton(label: 'Send Report', isLoading: _sending, onPressed: _send),
            ],
          ),
        ),
      ),
    );
  }
}
