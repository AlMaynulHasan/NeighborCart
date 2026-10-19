import 'dart:async';

/// Emits whenever either stream emits, once both have emitted at least once.
Stream<R> combineLatest2<A, B, R>(
  Stream<A> a,
  Stream<B> b,
  R Function(A, B) combiner,
) {
  late StreamController<R> controller;
  StreamSubscription<A>? subA;
  StreamSubscription<B>? subB;
  A? lastA;
  B? lastB;
  var hasA = false;
  var hasB = false;

  void emit() {
    if (hasA && hasB) controller.add(combiner(lastA as A, lastB as B));
  }

  controller = StreamController<R>(
    onListen: () {
      subA = a.listen((v) {
        lastA = v;
        hasA = true;
        emit();
      }, onError: controller.addError);
      subB = b.listen((v) {
        lastB = v;
        hasB = true;
        emit();
      }, onError: controller.addError);
    },
    onCancel: () async {
      await subA?.cancel();
      await subB?.cancel();
    },
  );
  return controller.stream;
}

Stream<R> combineLatest3<A, B, C, R>(
  Stream<A> a,
  Stream<B> b,
  Stream<C> c,
  R Function(A, B, C) combiner,
) {
  return combineLatest2<(A, B), C, R>(
    combineLatest2<A, B, (A, B)>(a, b, (x, y) => (x, y)),
    c,
    (ab, z) => combiner(ab.$1, ab.$2, z),
  );
}

/// Like asyncExpand, but cancels the previous inner stream whenever the
/// source emits (needed so "active pool changed" re-subscribes properly).
Stream<R> switchMap<T, R>(Stream<T> source, Stream<R> Function(T) mapper) {
  late StreamController<R> controller;
  StreamSubscription<T>? outer;
  StreamSubscription<R>? inner;

  controller = StreamController<R>(
    onListen: () {
      outer = source.listen((event) {
        inner?.cancel();
        inner = mapper(event).listen(controller.add, onError: controller.addError);
      }, onError: controller.addError);
    },
    onCancel: () async {
      await inner?.cancel();
      await outer?.cancel();
    },
  );
  return controller.stream;
}
