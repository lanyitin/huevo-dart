import 'package:huevo/huevo.dart';
import 'predef.dart';
import 'input_source.dart';
import 'combinators.dart';

abstract class Parser<E, R> {
  Parser();

  R doParse(InputSource<E> inputSource);
  R parse(InputSource<E> inputSource) {
    var clonedInputSource = inputSource.rest();
    var result = doParse(clonedInputSource);
    if (result != null) {
      inputSource.forward(clonedInputSource.getConsumed());
    }
    return result;
  }

  static Parser<E, E> fromElement<E>(E e) {
    return SingleElementParser<E>(e);
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

  static Parser<E, List<R>> lazyJoin<E, R>(
      List<Parser<E, R> Function()> parsers,
      Parser<E, R> Function() delimeter) {
    return parsers.map((parser) {
      return parser.map((item) {
        return [item];
      });
    }).reduce((p1, p2) {
      return p1.bind((r1) {
        return delimeter().bind((w) {
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
