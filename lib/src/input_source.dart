import 'dart:collection';

class InputSource<E> {
  UnmodifiableListView<E> _view;
  num _count;

  InputSource(Iterable<E> source) {
    _view = UnmodifiableListView(source);
    _count = -1;
  }

  /// return true if has next item
  bool hasNext() {
    return _count < _view.length - 1;
  }

  /// return null if there is no more item, or move the iterator and return next item
  E nextItem() {
    if (!hasNext()) {
      throw 'out of index error';
    }
    _count += 1;
    return _view.skip(_count).first;
  }

  /// move iterator back to previous `cnt` items.
  /// if `cnt` is greater then current position
  /// then move iterator to 0
  void backward(num cnt) {
    _count -= cnt;
    if (_count < -1) {
      _count = -1;
    }
  }

  void forward(num cnt) {
    _count += cnt;
  }

  InputSource<E> rest() {
    return InputSource(_view.skip(getConsumed()));
  }

  num getConsumed() {
    return _count + 1;
  }
}
