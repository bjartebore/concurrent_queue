// Port of lower_bound from https://en.cppreference.com/w/cpp/algorithm/lower_bound
// Used to compute insertion index to keep queue sorted after insertion
typedef int Comparator<T>(T a , T b);

int lowerBound<T>( List<T> array, T value, Comparator comparator) {
  int first = 0;
  int count = array.length;
  while (count > 0) {
    int step = ((count / 2).truncate() | 0);
    int it = first + step;

    if ( comparator(array[it], value) <= 0) {
      first = ++it;
      count -= step + 1;
    } else {
      count = step;
    }
  }
  return first;
}