typedef Future<dynamic> RunFunction();

abstract class IQueue<IRunFunction, IOptions> {
  int get size;
  List<IRunFunction> filter(int priority);
  IRunFunction dequeue({ dynamic? key });
  void enqueue(IRunFunction run, {
    int priority,
    dynamic? key
  });
  int indexOf(dynamic key);
}