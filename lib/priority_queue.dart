import 'lower_bounds.dart';
import 'options.dart';
import 'queue.dart';

abstract class IPriorityQueueOptions extends IQueueAddOptions {
  int priority; 
  RunFunction run;
}

class PriorityQueueOptions implements IPriorityQueueOptions {
  PriorityQueueOptions(this.priority, { this.run });
  @override
  int priority;

  @override
  RunFunction run;
}

class PriorityQueue implements IQueue<RunFunction, IPriorityQueueOptions>{
  @override
  int get size {
    return this._queue.length;
  }

  List<IPriorityQueueOptions> _queue = <IPriorityQueueOptions>[];

  @override
  dequeue() {
    IPriorityQueueOptions item = _queue.isNotEmpty ?  _queue.removeAt(0) : null;
		return item?.run;
  }

  @override
  void enqueue(run, IPriorityQueueOptions options) {
    // ensure priority
    int priority = options.priority ?? 0;

    IPriorityQueueOptions element = PriorityQueueOptions(
      priority,
      run: run,
    );

    if (size > 0 && _queue[size - 1].priority >= priority) {
      _queue.add(element);
      return;
    }

    int index = lowerBound<IPriorityQueueOptions>(
      _queue, 
      element, 
      (a, b) => b.priority - a.priority);

    _queue.insert(index, element);
  }

  @override
  List<RunFunction> filter(options) {
    return this._queue.where((element) => element.priority == options.priority).map((e) => e.run);
  }

} 