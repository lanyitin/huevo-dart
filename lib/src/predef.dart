typedef Transformer<I, O> = O Function(I input);

class Either<T1, T2> {
  T1 left;
  T2 right;
  bool isLeft;
  Either.Left(this.left) {
    isLeft = true;
  }
  Either.Right(this.right) {
    isLeft = false;
  }
}

abstract class SemiGroup<R> {
  bool equals(R arg1, R arg2);
  R concate(R arg1, R arg2);
  R unit();
}
class StringSemiGroup extends SemiGroup<String> {
  @override
  String concate(String arg1, String arg2) {
    return arg1 + arg2;
  }
  @override
  String unit() {
    return '';
  }
  @override
  bool equals(String arg1, String arg2) {
    return arg1 == arg2;
  }
}
