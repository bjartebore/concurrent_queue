# concurrent_queue

> Priority queue with concurrency control

concurrent_queue is a dart implementation of Sindre Sorhus's [p-queue](https://github.com/sindresorhus/p-queue/)

Useful for rate-limiting async (or sync) operations. For example, when interacting with a REST API or when doing CPU/memory intensive tasks.

## Usage

```dart
import 'package:concurrent_queue/concurrent_queue.dart'

final queue = ConcurrentQueue(
  concurrency: 2
);

queue.add(() async {
  await Future.delayed(Duration(seconds: 5));
  print('Done waiting for 5 seconds');
});

queue.add(() async {
  await Future.delay(Duration(seconds: 2));
  print('Done waiting for 2 seconds');
});

```


## Advanced example

A more advanced example to help you understand the flow.

```dart

import 'package:concurrent_queue/concurrent_queue.dart'

Future delay(int milliseconds) async => Future.delayed(Duration(milliseconds: milliseconds));

final queue = ConcurrentQueue(
    concurrency: 2
);

(() async {
    await delay(200);

    print('8. Pending promises: ${queue.pending}');
    //=> '8. Pending promises: 0'

    (() async {
    await queue.add(() async => '🐙');
    print('11. Resolved 🐙');
    })();

    print('9. Added 🐙');

    print('10. Pending promises: ${queue.pending}');
    //=> '10. Pending promises: 1'

    await queue.onIdle();
    print('12. All work is done');
})();

(() async {
    await queue.add(() async => '🦄');
    print('5. Resolved 🦄');
})();

print('1. Added 🦄');

(() async {
    await queue.add(() async => '🐴');
    print('6. Resolved 🐴');
})();
print('2. Added 🐴');

(() async {
    await queue.onIdle();
    print('7. Queue is empty');
})();

print('3. Queue size: ${queue.size}');
//=> '3. Queue size: 1'

print('4. Pending promises: ${queue.pending}');
//=> '4. Pending promises: 1'

await delay(200);
```

```
$ node example.js
1. Added 🦄
2. Added 🐴
3. Queue size: 0
4. Pending promises: 2
5. Resolved 🦄
6. Resolved 🐴
7. Queue is empty
8. Pending promises: 0
9. Added 🐙
10. Pending promises: 1
11. Resolved 🐙
12. All work is done
```

## Custom QueueClass

For implementing more complex scheduling policies, you can provide a QueueClass in the options:

```js
class QueueClass {
	constructor() {
		this._queue = [];
	}

	enqueue(run, options) {
		this._queue.push(run);
	}

	dequeue() {
		return this._queue.shift();
	}

	get size() {
		return this._queue.length;
	}

	filter(options) {
		return this._queue;
	}
}

const queue = new PQueue({
	queueClass: QueueClass
});
```
