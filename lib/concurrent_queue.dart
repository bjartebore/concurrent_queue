library concurrent_queue;

import 'dart:async';

import 'priority_queue.dart';

export 'priority_queue.dart';

typedef Future<T> Task<T>();

typedef void ResolveFunction<T>();

void empty() {}

class ConcurrentQueue {

  ConcurrentQueue({
    bool autoStart = true,
    int concurrency = 1<<32,
    Duration interval = Duration.zero,
    int intervalCap = 1<<32,
    bool carryoverConcurrencyCount = false,
    Duration timeout = Duration.zero,
    bool throwOnTimeout = false,
  }) :
    _carryoverConcurrencyCount = carryoverConcurrencyCount,
    _isIntervalIgnored = intervalCap == double.infinity || interval == Duration.zero,
    _timeout = timeout,
    _throwOnTimeout = throwOnTimeout,
    _intervalCap = intervalCap,
    _interval = interval,
    _queue = PriorityQueue(),
    _concurrency = concurrency,
    _isPaused = autoStart == false;

  final bool _carryoverConcurrencyCount;

  final bool _isIntervalIgnored;

  int _intervalCount = 0;

  final int _intervalCap;

  Duration? _timeout;

  final bool _throwOnTimeout;

  final Duration _interval;

  DateTime? _intervalEnd;

  Timer? _intervalId;

  Timer? _timeoutId;

  late PriorityQueue _queue;

  int _pendingCount = 0;

  late int _concurrency;

  bool _isPaused;

  ResolveFunction _resolveEmpty = empty;

  ResolveFunction _resolveIdle = empty;

  bool get _doesIntervalAllowAnother {
    return _isIntervalIgnored || _intervalCount < _intervalCap;
  }

  bool get _doesConcurrentAllowAnother {
		return _pendingCount < _concurrency;
	}

  void _next() {
    _pendingCount -= 1;
    _tryToStartAnother();
  }

  void _resolvePromises() {
    _resolveEmpty();
    _resolveEmpty = empty;

    if (_pendingCount == 0) {
      _resolveIdle();
      _resolveIdle = empty;
      // emit('idle');
    }
  }

  void _onResumeInterval() {
    _onInterval();
    _initializeIntervalIfNeeded();
    _timeoutId = null;
  }

  bool _isIntervalPaused() {
    DateTime now = DateTime.now();

		if (_intervalId == null) {
			var delay = _intervalEnd != null ? _intervalEnd!.difference(now) : Duration.zero;
			if (delay.inMilliseconds <= 0) {
				// Act as the interval was done
				// We don't need to resume it here because it will be resumed on line 160
				_intervalCount = (_carryoverConcurrencyCount) ? _pendingCount : 0;
			} else {
				// Act as the interval is pending
				if (_timeoutId == null) {
          _timeoutId = Timer(delay, _onResumeInterval);
				}

				return true;
			}
		}

		return false;
  }

  bool _tryToStartAnother() {
    if (_queue.size == 0) {
      if (_intervalId != null) {
        _intervalId!.cancel();
        _intervalId = null;
      }
      _resolvePromises();
      return false;
    }
    if (!_isPaused) {

      bool canInitializeInterval = !_isIntervalPaused();
      if (_doesIntervalAllowAnother && _doesConcurrentAllowAnother) {
        //this.emit('active');
        final job = _queue.dequeue();

        if (job == null) {
          return false;
        }

        job();

				if (canInitializeInterval) {
					_initializeIntervalIfNeeded();
				}

				return true;
      }
    }
    return false;
  }

  void _initializeIntervalIfNeeded() {
    if (_isIntervalIgnored || _intervalId != null) {
			return;
		}
    _intervalId = Timer.periodic(_interval, (timer) {
      _onInterval();
    });


		_intervalEnd = DateTime.now().add(_interval);
  }

  void _onInterval() {

    if (_intervalCount == 0 && _pendingCount == 0 && _intervalId != null) {
      _intervalId!.cancel();
      _intervalId = null;
		}

		_intervalCount = _carryoverConcurrencyCount
      ? _pendingCount
      : 0;

		_processQueue();
  }

  void _processQueue() {
    while (_tryToStartAnother()) {}
  }

  int get concurrency {
    return _concurrency;
  }

  set concurrency(int newConcurrency) {
    _concurrency = newConcurrency;
    _processQueue();
  }

  set timeout(Duration timeout) {
    _timeout = timeout;
  }

  Duration get timeout => _timeout!;

  Future<List<T>> addAll<T>(
    List<Task<T>> tasks, {
      int priority = 0,
    }
  ) {
    final waitFor = tasks.map((task) {
      return add(task, priority: priority);
    }).toList();

    return Future.wait(waitFor);
  }

  Future<T> add<T>(
    Task<T> task, {
      int priority = 0,
    }) async {

    final c = Completer<T>();
    _queue.enqueue(() async {
      _pendingCount += 1;
      _intervalCount += 1;

      try {
        final operation = (_timeout == Duration.zero)
          ? task()
          : task().timeout(_timeout!,
            onTimeout: () {
              if (_throwOnTimeout) {
                throw TimeoutException('task timed out');
              }
              return null;
            } as FutureOr<T> Function()?
          );

        c.complete(await operation);
      } on TimeoutException catch (error) {
        c.completeError(error);
      } catch (error) {
        c.completeError(error);
      } finally {
        _next();
      }

    }, priority: priority);
    _tryToStartAnother();
    return c.future;
  }


  ConcurrentQueue start() {

    if (!_isPaused) {
      return this;
    }
    _isPaused = false;

    _processQueue();

    return this;

  }

  void pause() {
    _isPaused = true;
  }

  void clear() {
    _queue = PriorityQueue();
  }

  Future<void> onEmpty() {
    Completer c = Completer();
    if (_queue.size == 0) {
			c.complete();
		} else {
      var existingResolve = _resolveEmpty;
			_resolveEmpty = () {
				existingResolve();
				c.complete();
			};
    }
    return c.future;
  }

  Future<void> onIdle() {
    Completer c = Completer();
    if (_pendingCount == 0 && _queue.size == 0) {
			c.complete();
		} else {
      var existingResolve = _resolveIdle;
      _resolveIdle = () {
        existingResolve();
				c.complete();
      };
    }

    return c.future;
  }

  int get size {
    return _queue.size;
  }

  int get pending {
    return _pendingCount;
  }

  bool get isPaused {
    return _isPaused;
  }

}