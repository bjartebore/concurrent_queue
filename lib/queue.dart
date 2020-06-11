typedef Future<dynamic> RunFunction();

abstract class IQueue<IElement, IOptions> {
  int get size;
  List<IElement> filter(IOptions options);
  IElement dequeue();
  void enqueue(IElement run, IOptions options );
}