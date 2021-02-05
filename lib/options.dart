import 'queue.dart';

abstract class IQueueType extends IQueue<RunFunction, IOptions> {}

typedef IQueueType QueueTypeFactory();


abstract class IOptions {
  IOptions({
    this.concurrency,
    this.autoStart,
    this.queueClass,
    this.intervalCap,
    this.interval,
    this.carryoverConcurrencyCount,
    this.timeout,
    this.throwOnTimeout,
  });
  
  final int concurrency;

  final bool autoStart;

  final QueueTypeFactory queueClass;

  final int intervalCap;

  final Duration interval;

  final bool carryoverConcurrencyCount;

  final Duration timeout;

  final bool throwOnTimeout;
}

class PQueueOptions extends IOptions {
  PQueueOptions({
    bool autoStart = true,
    int concurrency = 1<<32,
    Duration interval = Duration.zero,
    int intervalCap = 1<<32,
    bool carryoverConcurrencyCount = false,
    Duration timeout = Duration.zero,
    bool throwOnTimeout = false,
  }): super(
    autoStart: autoStart,
    concurrency: concurrency,
    interval: interval,
    intervalCap: intervalCap,
    carryoverConcurrencyCount: carryoverConcurrencyCount,
    throwOnTimeout: throwOnTimeout,
    timeout: timeout,
  );
}