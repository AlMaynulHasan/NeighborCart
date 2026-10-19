import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/format.dart';
import '../../services/pool_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import 'pool_details_screen.dart';

/// ASSUMPTION: "Create Pool" wasn't designed in Figma — a simple form in the
/// same style. The creator becomes the pool's first member and coordinator.
class CreatePoolScreen extends StatefulWidget {
  const CreatePoolScreen({super.key});

  @override
  State<CreatePoolScreen> createState() => _CreatePoolScreenState();
}

class _CreatePoolScreenState extends State<CreatePoolScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _pickupController = TextEditingController();
  late DateTime _deadline;
  String? _deadlineError;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _deadline = DateTime(now.year, now.month, now.day, 20).add(const Duration(days: 3));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _pickupController.dispose();
    super.dispose();
  }

  String? _required(String? v) => (v == null || v.trim().isEmpty) ? 'Required' : null;

  Future<void> _pickDeadline() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _deadline,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_deadline),
    );
    if (time == null || !mounted) return;
    setState(() {
      _deadline = DateTime(date.year, date.month, date.day, time.hour, time.minute);
      _deadlineError = null;
    });
  }

  Future<void> _create() async {
    final valid = _formKey.currentState!.validate();
    if (!_deadline.isAfter(DateTime.now())) {
      setState(() => _deadlineError = 'Pick a deadline in the future');
      return;
    }
    if (!valid) return;

    setState(() => _isSaving = true);
    try {
      final id = await PoolService.instance.createPool(
        name: _nameController.text.trim(),
        pickupLocation: _pickupController.text.trim(),
        deadline: _deadline,
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => PoolDetailsScreen(poolId: id)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not create the pool. Please try again.')),
      );
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(title: const Text('Create Pool')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Start a pool for your street or block. You will be its coordinator '
                  'and neighbors can join it from the Pools tab.',
                  style: AppTextStyles.bodySecondary,
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  label: 'Pool Name',
                  hint: 'e.g. Station Road Pool',
                  controller: _nameController,
                  validator: _required,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Pickup Location',
                  hint: 'e.g. Saidpur Govt College Gate',
                  controller: _pickupController,
                  validator: _required,
                ),
                const SizedBox(height: 16),
                Text('Order Deadline', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _pickDeadline,
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _deadlineError == null ? AppColors.border : AppColors.warning),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time_rounded, color: AppColors.warning),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '${formatDeadlineLong(_deadline)} • ${formatShortDate(_deadline)}',
                            style: AppTextStyles.body,
                          ),
                        ),
                        const Icon(Icons.edit_calendar_outlined, color: AppColors.textSecondary),
                      ],
                    ),
                  ),
                ),
                if (_deadlineError != null) ...[
                  const SizedBox(height: 6),
                  Text(_deadlineError!, style: AppTextStyles.caption.copyWith(color: AppColors.warning)),
                ],
                const SizedBox(height: 28),
                CustomButton(label: 'Create Pool', isLoading: _isSaving, onPressed: _create),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
