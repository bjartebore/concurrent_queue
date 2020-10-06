import 'lower_bounds.dart';
import 'queue.dart';

class PriorityQueueOptions {
  PriorityQueueOptions(this.priority, { this.run });
  @override
  int priority;

  @override
  RunFunction run;
}

class PriorityQueue implements IQueue<RunFunction, PriorityQueueOptions>{
  @override
  int get size {
    return this._queue.length;
  }

  List<PriorityQueueOptions> _queue = <PriorityQueueOptions>[];

  @override
  dequeue() {
    PriorityQueueOptions item = _queue.isNotEmpty ?  _queue.removeAt(0) : null;
		return item?.run;
  }

  @override
  void enqueue(run, PriorityQueueOptions options) {
    // ensure priority
    int priority = options.priority ?? 0;

    PriorityQueueOptions element = PriorityQueueOptions(
      priority,
      run: run,
    );

    if (size > 0 && _queue[size - 1].priority >= priority) {
      _queue.add(element);
      return;
    }

    int index = lowerBound<PriorityQueueOptions>(
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