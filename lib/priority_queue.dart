import 'lower_bounds.dart';
import 'queue.dart';

class _PriorityQueueOptions
 {
  _PriorityQueueOptions(this.priority, { this.run });

  int priority;

  RunFunction? run;
}

class PriorityQueue implements IQueue<RunFunction?, _PriorityQueueOptions>{
  @override
  int get size {
    return this._queue.length;
  }

  List<_PriorityQueueOptions> _queue = <_PriorityQueueOptions>[];

  @override
  void enqueue(run, { int priority = 0 }) {

    _PriorityQueueOptions element = _PriorityQueueOptions(
      priority,
      run: run,
    );

    if (size > 0 && _queue[size - 1].priority >= priority) {
      _queue.add(element);
      return;
    }

    int index = lowerBound<_PriorityQueueOptions>(
      _queue,
      element,
      (a, b) => b.priority - a.priority);

    _queue.insert(index, element);
  }


  @override
  dequeue() {
    _PriorityQueueOptions? item = _queue.isNotEmpty ?  _queue.removeAt(0) : null;
		return item?.run;
  }

  @override
  List<RunFunction?> filter(int priority) {
    return this._queue.where((element) => element.priority == priority).map((e) => e.run) as List<Future<dynamic> Function()?>;
  }

}