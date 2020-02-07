import 'package:huevo/huevo.dart';
import 'package:tuple/tuple.dart';
import 'predef.dart';
import 'input_source.dart';
import 'combinators.dart';

abstract class Parser<E, R> {
  Parser();

  static Parser<E, E> fromElement<E>(E e) {
    return SingleElementParser<E>(e);
  }

  R doParse(InputSource<E> inputSource);
  R parse(InputSource<E> inputSource) {
    var clonedInputSource = inputSource.rest();
    var result = doParse(clonedInputSource);
    if (result != null) {
      inputSource.forward(clonedInputSource.getConsumed());
    }
    return result;
  }

  Parser<E, R2> map<R2>(Transformer<R, R2> transformer) {
    return TransformCombinator<E, R, R2>(this, transformer);
  }

  Parser<E, R2> bind<R2>(Transformer<R, Parser<E, R2>> transformer) {
    return BindCombinator(this, transformer);
  }

  Parser<E, R> or<R2 extends R>(Parser<E, R2> another) {
    return OrCombinator(this, another).map((result) {
      if (result.isLeft) {
        return result.left;
      } else {
        return result.right;
      }
    });
  }

  Parser<E, Either<R, R2>> either<R2>(Parser<E, R2> another) {
    return OrCombinator(this, another);
  }

  Parser<E, R> sequence<R2 extends R>(
      Parser<E, R2> another, SemiGroup<R> algorithm) {
    return AndCombinator(this, another).map((result) {
      return result.toList().fold(algorithm.unit(), (arg1, arg2) {
        return algorithm.concate(arg1, arg2);
      });
    });
  }

  Parser<E, Tuple2<R, R2>> and<R2>(Parser<E, R2> another) {
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

  static Parser<E, List<R>> join<E, R>(
      List<Parser<E, R>> parsers, Parser<E, R> delimeter) {
    return parsers.map((parser) {
      return parser.map((item) {
        return [item];
      });
    }).reduce((p1, p2) {
      return p1.bind((r1) {
        return delimeter.bind((w) {
          return p2.map((r2) {
            r1.addAll(r2);
            return r1;
          });
        });
      });
    });
  }
}

class SemiGroupParser<R> extends Parser<R, R> {
  final R _target;
  final SemiGroup<R> _algorithm;
  SemiGroupParser(this._target, this._algorithm);

  @override
  R doParse(InputSource<R> inputSource) {
    var result = _algorithm.unit();
    while (!_algorithm.equals(result, _target) && inputSource.hasNext()) {
      result = _algorithm.concate(result, inputSource.nextItem());
    }
    if (_algorithm.equals(result, _target)) {
      return result;
    } else {
      return null;
    }
  }
}

class StringParser extends SemiGroupParser<String> {
  StringParser(String target) : super(target, StringSemiGroup());
}

class RegexParser extends Parser<String, String> {
  final RegExp _regexp;
  RegexParser(this._regexp);
  @override
  String doParse(InputSource<String> inputSource) {
    var buffer = StringBuffer();
    var clonedInputSource = inputSource.rest();
    while (clonedInputSource.hasNext()) {
      buffer.write(clonedInputSource.nextItem());
    }
    var rest = buffer.toString();
    var matcher = _regexp.firstMatch(rest);
    if (matcher == null || matcher.start != 0) {
      return null;
    }
    inputSource.forward(matcher.end - matcher.start);
    return rest.substring(matcher.start, matcher.end);
  }
}
