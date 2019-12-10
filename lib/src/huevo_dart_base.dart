import 'dart:collection';
class InputSource<E> {

  UnmodifiableListView<E> _view;
  num _count;

  InputSource(Iterable<E> source) {
    _view = UnmodifiableListView(source);
    _count = 0;
  }

  /// return true if has next item
  bool hasNext() {
    return _count < _view.length;
  }

  /// peek the element that iterator pointed at
  E peek() {
    return _view.skip(_count).iterator.current; 
  }

  /// return null if there is no more item, or move the iterator and return next item
  E nextItem() {
    if (!hasNext()) {
      return null;
    }
    _count += 1;
    return peek();
  }

  /// move iterator back to previous `cnt` items.
  /// if `cnt` is greater then current position
  /// then move iterator to 0
  void moveBack(num cnt) {
    _count -= cnt;
    if (_count < 0) {
      _count = 0;
    }
  }

  Iterable<E> rest() {
    return _view.skip(_count);
  }
}