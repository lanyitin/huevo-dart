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
  final Parser<E, R1> _parser1;
  final Parser<E, R2> _parser2;
  OrCombinator(this._parser1, this._parser2);

  @override
  Either<R1, R2> doParse(InputSource<E> inputSource) {
    var parseResult1 = _parser1.parse(inputSource);
    if (parseResult1 != null) {
      return Either.Left(parseResult1);
    } else {
      var parseResult2 = _parser2.parse(inputSource);
      if (parseResult2 != null) {
        return Either.Right(parseResult2);
      } else {
        return null;
      }
    }
  }
}

class AndCombinator<E, R1, R2> extends Parser<E, Tuple2<R1, R2>> {
  final Parser<E, R1> _parser1;
  final Parser<E, R2> _parser2;
  AndCombinator(this._parser1, this._parser2);

  @override
  Tuple2<R1, R2> doParse(InputSource<E> inputSource) {
    var parseResult1 = _parser1.parse(inputSource);
    var parseResult2 = _parser2.parse(inputSource);
    if (parseResult1 != null && parseResult2 != null) {
      return Tuple2<R1, R2>.fromList([parseResult1, parseResult2]);
    } else {
      return null;
    }
  }
}

class TransformCombinator<E, R1, R2> extends Parser<E, R2> {
  final Parser<E, R1> _original;
  final Transformer<R1, R2> _transformer;
  TransformCombinator(this._original, this._transformer);

  @override
  R2 doParse(InputSource<E> inputSource) {
    var parseResult = _original.parse(inputSource);
    if (parseResult == null) {
      return null;
    } else {
      return _transformer(parseResult);
    }
  }
}

class BindCombinator<E, R1, R2> extends Parser<E, R2> {
  final Parser<E, R1> _original;
  final Transformer<R1, Parser<E, R2>> _transformer;
  BindCombinator(this._original, this._transformer);

  @override
  R2 doParse(InputSource<E> inputSource) {
    var parseResult = _original.parse(inputSource);
    if (parseResult == null) {
      return null;
    }
    return _transformer(parseResult).parse(inputSource);
  }
}

class RepeatCombinator<E, R> extends Parser<E, List<R>> {
  final Parser<E, R> _original;
  final num _min;
  final num _max;
  RepeatCombinator(this._original, this._min, this._max);

  @override
  List<R> doParse(InputSource<E> inputSource) {
    var parseResult = _original.parse(inputSource);
    if (parseResult == null) {
      if (_min != 0) {
        return null;
      } else {
        return [];
      }
    }
    var result = [parseResult];
    while (result.length < _max && parseResult != null) {
      parseResult = _original.parse(inputSource);
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
