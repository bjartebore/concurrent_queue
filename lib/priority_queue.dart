import 'lower_bounds.dart';
import 'queue.dart';

class _PriorityQueueOptions
 {
  _PriorityQueueOptions(this.priority, { this.run, this.key });

  int priority;

  RunFunction? run;

  dynamic key;
}

class PriorityQueue implements IQueue<RunFunction?, _PriorityQueueOptions>{
  @override
  int get size {
    return this._queue.length;
  }

  List<_PriorityQueueOptions> _queue = <_PriorityQueueOptions>[];
  final _map = <dynamic, _PriorityQueueOptions>{};

  @override
  void enqueue(run, { int priority = 0, dynamic key }) {

    _PriorityQueueOptions element = _PriorityQueueOptions(
      priority,
      run: run,
      key: key,
    );

    if (key != null) {
      if (_map[key] != null) {
        throw Exception('keyed entry allready exists');
      }
      _map[key] = element;
    }

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
  RunFunction? dequeue({ dynamic key }) {
    _PriorityQueueOptions? item;

    if (key != null) {
      int idx = _map[key] != null ? _queue.indexOf(_map[key]!) : -1;
      item = idx >= 0 ? _queue.removeAt(idx) : null;
    } else {
      item = _queue.isNotEmpty
        ? _queue.removeAt(0)
        : null;
    }

    if (item?.key != null) {
      _map.remove(item?.key);
    }

    return item?.run;
  }

  int indexOf(dynamic key) {
    if (_map.containsKey(key)) {
      return _queue.indexOf(_map[key]!);
    }
    return -1;
  }

  @override
  List<RunFunction?> filter(int priority) {
    return this._queue.where((element) => element.priority == priority).map((e) => e.run) as List<Future<dynamic> Function()?>;
  }

}