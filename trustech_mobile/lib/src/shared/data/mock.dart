/// UI-phase helpers for static mock data.
///
/// Screens read from Riverpod providers that return these mocks; swapping to the
/// real backend later only changes the provider body. Use [mockDelay] to demo
/// loading/skeleton states.
library;

Future<T> mockDelay<T>(T value, [Duration duration = const Duration(milliseconds: 600)]) {
  return Future.delayed(duration, () => value);
}
