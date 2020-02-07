import 'package:tuple/tuple.dart';
import 'parser.dart';
import 'input_source.dart';
import 'predef.dart';

class SingleElementParser<E> extends Parser<E, E> {
  final E _element;
  SingleElementParser(this._element);

  @override
  E doParse(InputSource<E> inputSource) {
    if (!inputSource.hasNext()) {
      return null;
    }
    var item = inputSource.nextItem();
    if (item == _element) {
      return item;
    } else {
      return null;
    }
  }
}

class OrCombinator<E, R1, R2> extends Parser<E, Either<R1, R2>> {
  final Parser<E, R1> Function() _parser1;
  final Parser<E, R2> Function() _parser2;
  OrCombinator(this._parser1, this._parser2);

  @override
  Either<R1, R2> doParse(InputSource<E> inputSource) {
    var parseResult1 = _parser1().parse(inputSource);
    if (parseResult1 != null) {
      return Either.Left(parseResult1);
    } else {
      var parseResult2 = _parser2().parse(inputSource);
      if (parseResult2 != null) {
        return Either.Right(parseResult2);
      } else {
        return null;
      }
    }
  }
}

class AndCombinator<E, R1, R2> extends Parser<E, Tuple2<R1, R2>> {
  final Parser<E, R1> Function() _parser1;
  final Parser<E, R2> Function() _parser2;
  AndCombinator(this._parser1, this._parser2);

  @override
  Tuple2<R1, R2> doParse(InputSource<E> inputSource) {
    var parseResult1 = _parser1().parse(inputSource);
    var parseResult2 = _parser2().parse(inputSource);
    if (parseResult1 != null && parseResult2 != null) {
      return Tuple2<R1, R2>(parseResult1, parseResult2);
    } else {
      return null;
    }
  }
}

class TransformCombinator<E, R1, R2> extends Parser<E, R2> {
  final Parser<E, R1> Function() _original;
  final Transformer<R1, R2> _transformer;
  TransformCombinator(this._original, this._transformer);

  @override
  R2 doParse(InputSource<E> inputSource) {
    var parseResult = _original().parse(inputSource);
    if (parseResult == null) {
      return null;
    } else {
      return _transformer(parseResult);
    }
  }
}

class BindCombinator<E, R1, R2> extends Parser<E, R2> {
  final Parser<E, R1> Function() _original;
  final Transformer<R1, Parser<E, R2>> _transformer;
  BindCombinator(this._original, this._transformer);

  @override
  R2 doParse(InputSource<E> inputSource) {
    var parseResult = _original().parse(inputSource);
    if (parseResult == null) {
      return null;
    }
    return _transformer(parseResult).parse(inputSource);
  }
}

class RepeatCombinator<E, R> extends Parser<E, List<R>> {
  final Parser<E, R> Function() _original;
  final num _min;
  final num _max;
  RepeatCombinator(this._original, this._min, this._max);

  @override
  List<R> doParse(InputSource<E> inputSource) {
    var parseResult = _original().parse(inputSource);
    if (parseResult == null) {
      if (_min != 0) {
        return null;
      } else {
        return [];
      }
    }
    var result = [parseResult];
    while (result.length < _max && parseResult != null) {
      parseResult = _original().parse(inputSource);
      if (parseResult != null) {
        result.add(parseResult);
      }
    }
    return result;
  }
}

class EOIParser<E> extends Parser<E, bool> {
  @override
  bool doParse(InputSource<E> inputSource) {
    return !inputSource.hasNext();
  }
}

extension ParserCombinators<E, R> on Parser<E, R> {
  Parser<E, R2> map<R2>(Transformer<R, R2> transformer) {
    return TransformCombinator<E, R, R2>(() {
      return this;
    }, transformer);
  }

  Parser<E, R2> bind<R2>(Transformer<R, Parser<E, R2>> transformer) {
    return BindCombinator(() {
      return this;
    }, transformer);
  }

  Parser<E, R> or(Parser<E, R> another) {
    return lazyOr(() {
      return another;
    });
  }

  Parser<E, R> lazyOr(Parser<E, R> Function() another) {
    return OrCombinator(() {
      return this;
    }, another)
        .map((result) {
      if (result.isLeft) {
        return result.left;
      } else {
        return result.right;
      }
    });
  }

  Parser<E, Either<R, R2>> either<R2>(Parser<E, R2> another) {
    return lazyEither(() {
      return another;
    });
  }

  Parser<E, Either<R, R2>> lazyEither<R2>(Parser<E, R2> Function() another) {
    return OrCombinator(() {
      return this;
    }, another);
  }

  Parser<E, R> sequence<R2 extends R>(
      Parser<E, R2> another, SemiGroup<R> algorithm) {
    return lazySequence(() {
      return another;
    }, algorithm);
  }

  Parser<E, R> lazySequence<R2 extends R>(
      Parser<E, R2> Function() another, SemiGroup<R> algorithm) {
    return AndCombinator(() {
      return this;
    }, another)
        .map((result) {
      return [result.item1, result.item2].fold(algorithm.unit(), (arg1, arg2) {
        return algorithm.concate(arg1, arg2);
      });
    });
  }

  Parser<E, Tuple2<R, R2>> and<R2>(Parser<E, R2> another) {
    return lazyAnd(() {
      return another;
    });
  }

  Parser<E, Tuple2<R, R2>> lazyAnd<R2>(Parser<E, R2> Function() another) {
    return AndCombinator(() {
      return this;
    }, another);
  }

  Parser<E, List<R>> optional() {
    return RepeatCombinator(() {
      return this;
    }, 0, 1);
  }

  Parser<E, List<R>> oneOrMore() {
    return RepeatCombinator(() {
      return this;
    }, 1, 65535);
  }

  Parser<E, List<R>> any() {
    return RepeatCombinator(() {
      return this;
    }, 0, 65535);
  }

  Parser<E, R> end() {
    return bind((result) {
      return EOIParser<E>().map((inEnd) {
        if (inEnd) {
          return result;
        } else {
          return null;
        }
      });
    });
  }
}

extension LazyParserCombinators<E, R> on Parser<E, R> Function() {
  Parser<E, R2> map<R2>(Transformer<R, R2> transformer) {
    return TransformCombinator<E, R, R2>(this, transformer);
  }

  Parser<E, R2> bind<R2>(Transformer<R, Parser<E, R2>> transformer) {
    return BindCombinator(this, transformer);
  }

  Parser<E, R> or(Parser<E, R> Function() another) {
    return OrCombinator(this, another).map((result) {
      if (result.isLeft) {
        return result.left;
      } else {
        return result.right;
      }
    });
  }

  Parser<E, Either<R, R2>> either<R2>(Parser<E, R2> Function() another) {
    return OrCombinator(this, another);
  }

  Parser<E, R> sequence<R2 extends R>(
      Parser<E, R2> Function() another, SemiGroup<R> algorithm) {
    return AndCombinator(this, another).map((result) {
      return [result.item1, result.item2].fold(algorithm.unit(), (arg1, arg2) {
        return algorithm.concate(arg1, arg2);
      });
    });
  }

  Parser<E, Tuple2<R, R2>> and<R2>(Parser<E, R2> Function() another) {
    return AndCombinator(this, another);
  }

  Parser<E, List<R>> optional() {
    return RepeatCombinator(this, 0, 1);
  }

  Parser<E, List<R>> oneOrMore() {
    return RepeatCombinator(this, 1, 65535);
  }

  Parser<E, List<R>> any() {
    return RepeatCombinator(this, 0, 65535);
  }

  Parser<E, R> end() {
    return bind((result) {
      return EOIParser<E>().map((inEnd) {
        if (inEnd) {
          return result;
        } else {
          return null;
        }
      });
    });
  }
}
