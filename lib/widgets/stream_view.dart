import 'package:flutter/material.dart';
import '../core/theme/app_text_styles.dart';

/// Subscribes to a stream once (created lazily from [create]) and handles
/// loading/error states, so screens only describe the "data" layout.
class StreamView<T> extends StatefulWidget {
  final Stream<T> Function() create;
  final Widget Function(BuildContext context, T data) builder;

  const StreamView({super.key, required this.create, required this.builder});

  @override
  State<StreamView<T>> createState() => _StreamViewState<T>();
}

class _StreamViewState<T> extends State<StreamView<T>> {
  late final Stream<T> _stream = widget.create();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<T>(
      stream: _stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Something went wrong loading data.\n${snapshot.error}',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySecondary,
              ),
            ),
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        return widget.builder(context, snapshot.data as T);
      },
    );
  }
}
