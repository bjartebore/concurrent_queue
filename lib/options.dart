import 'queue.dart';

abstract class IQueueType extends IQueue<RunFunction, IOptions> {}

typedef IQueueType QueueTypeFactory();

abstract class IOptions {
  int concurrency;

  bool autoStart;

  QueueTypeFactory queueClass;

  int intervalCap;

  Duration interval;

  bool carryoverConcurrencyCount;

  Duration timeout;

  bool throwOnTimeout;
}

class PQueueOptions extends IOptions {
  PQueueOptions({
    bool autoStart = true,
    int concurrency = 1<<32,
    Duration interval = Duration.zero,
    int intervalCap = 1<<32,
    bool carryoverConcurrencyCount = false,
  }) {
    autoStart = autoStart;
    concurrency = concurrency;
    interval = interval;
    intervalCap = intervalCap;
    carryoverConcurrencyCount = carryoverConcurrencyCount;
  }
}