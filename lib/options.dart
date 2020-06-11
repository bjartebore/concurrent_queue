

import 'queue.dart';

abstract class IQueueAddOptions {

}


abstract class IQueueOptions extends IQueueAddOptions {}

abstract class IQueueType extends IQueue<RunFunction, IQueueOptions> {}

typedef IQueueType QueueTypeFactory();

abstract class IOptions<IQueueType, IQueueOptions> {
  int concurrency;

  bool autoStart;

  QueueTypeFactory queueClass;

  int intervalCap;

  Duration interval;

  bool carryoverConcurrencyCount;

  Duration timeout;

  bool throwOnTimeout;
}

abstract class IDefaultAddOptions extends IQueueAddOptions {
  int priority;
}




class Options<IQueueType, IQueueOptions> extends IOptions<IQueueType, IQueueOptions> {
  Options() {
    autoStart = true;
    concurrency = 1<<32;
    interval = Duration.zero;
    intervalCap = 1<<32;
    carryoverConcurrencyCount = false;
  }
}