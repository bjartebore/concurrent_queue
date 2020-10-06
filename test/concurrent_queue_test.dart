import 'dart:math';
import 'package:concurrent_queue/options.dart';
import 'package:concurrent_queue/priority_queue.dart';
import 'package:test/test.dart';

import 'package:concurrent_queue/concurrent_queue.dart';

final _random = new Random();

int randRange(int min, int max) => min + _random.nextInt(max - min);

void main() {
  test('.add()', () async {
    Options<PriorityQueue, IQueueOptions> options = Options();
    var queue = new PQueue(options);

    Future future = queue.add<int>(() async => 123);

    expect(queue.size, equals(0));
    expect(queue.pending, equals(1));
    expect(future, completion(equals(123)));
  });


  test('.add() - limited concurrency',() async {
    Options<PriorityQueue, IQueueOptions> options = Options()
      ..concurrency = 2;
    int fixture = 123;
    var queue = new PQueue(options);
    var promise = queue.add( () async => fixture);
    var promise2 = queue.add(() async {
      await Future.delayed(Duration(milliseconds: 300));
      return fixture;
    });
    var promise3 = queue.add(() async => fixture);

    expect(queue.size, equals(1));
    expect(queue.pending, equals(2));
    expect(promise, completion(equals(fixture)));
    expect(promise2, completion(equals(fixture)));
    expect(promise3, completion(equals(fixture)));

  });

  test('.add() - concurrency: 1', () async {
    var input = [
      [10, 300],
      [20, 200],
      [30, 100]
    ];
    Options<PriorityQueue, IQueueOptions> options = Options()
      ..concurrency = 1;
    var queue = new PQueue(options);

    Future<void> mapper (value) => queue.add(() async {
      await Future.delayed(Duration( milliseconds: value[1]));
      return value[0];
    });

    var all = Future.wait(input.map(mapper));

    expect(all, completion(equals([10, 20, 30])));

  });


  test('.add() - concurrency: 5', () async {
    int concurrency = 5;
    Options<PriorityQueue, IQueueOptions> options = Options()
      ..concurrency = 5;
    var queue = new PQueue(options);
    int running = 0;

    
    var input = List.filled(100, 0).map((val) async {
      queue.add(() async {
        running++;
        expect(running, lessThanOrEqualTo(concurrency));
        expect(queue.pending, lessThanOrEqualTo(concurrency));
        await Future.delayed(Duration(milliseconds: randRange(30, 200)));
        running--;
      });
    });

    await Future.wait(input);
  });


  test('.add() - update concurrency', () async {
    int concurrency = 5;
        Options<PriorityQueue, IQueueOptions> options = Options()
      ..concurrency = concurrency;
    var queue = new PQueue(options);

    
    int running = 0;

    var input = List.filled(100, 0).asMap().keys.map((index) async => queue.add(() async {
      running++;
      expect(running, lessThanOrEqualTo(concurrency));
      expect(queue.pending, lessThanOrEqualTo(concurrency));


      int ms = randRange(30, 200);
      await Future.delayed(Duration(milliseconds: ms));
      running--;

      if (index % 30 == 0) {
        queue.concurrency = --concurrency;
        expect(queue.concurrency, concurrency);
      }
    }));

    await Future.wait(input);
  });


  test('.add() - priority', () async {
    List<int> result = <int>[];
    Options<PriorityQueue, IQueueOptions> options = Options()
      ..concurrency = 1;
    var queue = new PQueue(options);

    queue.add(() async => result.add(1), options: PriorityQueueOptions(1) );
    queue.add(() async => result.add(0), options: PriorityQueueOptions(0));
    queue.add(() async => result.add(1), options: PriorityQueueOptions(1));
    queue.add(() async => result.add(2), options: PriorityQueueOptions(1));
    queue.add(() async => result.add(3), options: PriorityQueueOptions(2));
    queue.add(() async => result.add(0), options: PriorityQueueOptions(-1));
    await queue.onEmpty();

    expect(result, equals([1, 3, 1, 2, 0, 0]));
  });


  test('.onEmpty()', () async{

    Options<PriorityQueue, IQueueOptions> options = Options()
      ..concurrency = 1;
    var queue = new PQueue(options);



    queue.add(() async => 0);
    queue.add(() async => 0);

    expect(queue.size, equals(1));
    expect(queue.pending, equals(1));

    await queue.onEmpty();
    expect(queue.size, equals(0));

    queue.add(() async => 0);
    queue.add(() async => 0);

    expect(queue.size, equals(1));
    expect(queue.pending, equals(1));
    await queue.onEmpty();
    expect(queue.size, equals(0));

    // Test an empty queue
    await queue.onEmpty();
    expect(queue.size, equals(0));
  });

  test('async .onIdle', () async {

    Options<PriorityQueue, IQueueOptions> options = Options()
      // ..autoStart = true
      ..concurrency = 2;
    var queue = new PQueue(options);

    List<int> result = [];

    for (int i = 0; i < 4; i += 1) {
      queue.add(() async {
        await Future.delayed(Duration(milliseconds: 60));
        result.add(i);
      });
    }

    queue.start();

    await queue.onIdle();
    expect(result.length, equals(4));
    expect(result, equals([0,1,2,3]));
    expect(queue.size, equals(0));
  });

}


