typedef Future<dynamic> RunFunction();

abstract class IQueue<IRunFunction, IOptions> {
  int get size;
  List<IRunFunction> filter(int priority);
  IRunFunction dequeue();
  void enqueue(IRunFunction run, {
    int priority
  });
}