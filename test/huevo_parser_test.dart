import 'package:huevo/huevo.dart';
import 'package:test/test.dart';
import 'package:tuple/tuple.dart';

void main() {
  group('Conbinators', () {
    test('or combinator', () {
      var charParser1 = Parser.fromElement('a');
      var charParser2 = Parser.fromElement('b');
      var orCombinator = charParser1.or(charParser2);
      expect(orCombinator.parse(InputSource(['a'])), 'a');
      expect(orCombinator.parse(InputSource(['b'])), 'b');

      var inputSource = InputSource('ab'.split(''));
      expect(inputSource.getConsumed(), 0);
      expect(orCombinator.parse(inputSource), 'a');
      expect(inputSource.getConsumed(), 1);

      expect(orCombinator.parse(inputSource), 'b');
      expect(inputSource.getConsumed(), 2);
    });

    test('and combinator', () {
      var charParser1 = Parser.fromElement('a');
      var charParser2 = Parser.fromElement('b');
      var combinator = charParser1.and(charParser2);
      expect(combinator.parse(InputSource(['a'])), null);
      expect(combinator.parse(InputSource(['b'])), null);
      var inputSource = InputSource('ab'.split(''));
      var parseResult = combinator.parse(inputSource);
      expect(parseResult, Tuple2('a', 'b'));
      expect(inputSource.getConsumed(), 2);
    });

    test('transform combinator', () {
      var charParser = Parser.fromElement('a');
      var combinator = charParser.map((a) => a + 'b');
      var inputSource = InputSource('ab'.split(''));
      var parseResult = combinator.parse(inputSource);
      expect(parseResult, 'ab');
      expect(inputSource.getConsumed(), 1);
      expect(inputSource.nextItem(), 'b');
    });
    test('bind combinator', () {
      var charParser = Parser.fromElement('a');
      var combinator = charParser.bind((String char) {
        return Parser.fromElement('b').map((c2) {
          return char + c2;
        });
      });
      // expect(combinator.accept(InputSource(['a'])), true);
      var inputSource = InputSource('ab'.split(''));
      var parseResult = combinator.parse(inputSource);
      expect(parseResult, 'ab');
      expect(inputSource.getConsumed(), 2);
    });

    test('any', () {
      var parser = Parser.fromElement('a').any();
      // var inputSource = InputSource('bb'.split(''));
      expect(parser.parse(InputSource('bb'.split(''))), <String>[]);
      expect(parser.parse(InputSource('ab'.split(''))), ['a']);
      expect(parser.parse(InputSource('aa'.split(''))), ['a', 'a']);
    });

    test('oneOrMore', () {
      var parser = Parser.fromElement('a').oneOrMore();
      expect(parser.parse(InputSource('bb'.split(''))), null);
      expect(parser.parse(InputSource('ab'.split(''))), ['a']);
      expect(parser.parse(InputSource('aa'.split(''))), ['a', 'a']);
    });

    test('optional', () {
      var parser = Parser.fromElement('a').optional();
      expect(parser.parse(InputSource('bb'.split(''))), <String>[]);
      expect(parser.parse(InputSource('ab'.split(''))), ['a']);
      expect(parser.parse(InputSource('aa'.split(''))), ['a']);
    });
  });

  group('InputSource', () {
    test('return value of hasNext should be false when no elements in source',
        () {
      var source = InputSource(<String>[]);
      expect(source.hasNext(), false);
    });

    test(
        'return value of hasNext should be false while index is equal to lenght of source',
        () {
      var source = InputSource([null]);
      expect(source.hasNext(), true);
      expect(source.nextItem(), null);
      expect(source.hasNext(), false);
    });

    test('move back', () {
      var source = InputSource([null]);
      expect(source.hasNext(), true);
      expect(source.nextItem(), null);
      expect(source.hasNext(), false);

      source.backward(1);

      expect(source.hasNext(), true);
      expect(source.nextItem(), null);
      expect(source.hasNext(), false);
    });

    test('move than one element', () {
      var source = InputSource('ab'.split(''));
      expect(source.hasNext(), true);
      expect(source.nextItem(), 'a');
      expect(source.nextItem(), 'b');
    });
  });

  group('example', () {
    test('string paser', () {
      var inputSource = InputSource('This is A Parser Combinator'.split(''));
      var whiteSpace = Parser.fromElement(' ');
      var keywordThis = StringParser('This');
      var keywordis = StringParser('is');
      var keywordA = StringParser('A');
      var keywordParser = StringParser('Parser');
      var keywordCombinator = StringParser('Combinator');

      var sentanceParser = Parser.join([
        keywordThis,
        keywordis,
        keywordA,
        keywordParser,
        keywordCombinator
      ], whiteSpace)
          .end();
      var result = sentanceParser.parse(inputSource);
      expect(result != null, true);
      print(result);
    });
  });

  group('RegexParser Test', () {
    test('numeric: number only', () {
      var parser = RegexParser(RegExp('-?[1-9][0-9]*')).end();
      expect(parser.parse(InputSource('abcd'.split(''))), null);
      expect(parser.parse(InputSource('-'.split(''))), null);
      expect(parser.parse(InputSource('-1'.split(''))), '-1');
      var inputSource = InputSource('-1a'.split(''));
      expect(parser.parse(inputSource), null);
    });
    test('numeric', () {
      var parser = RegexParser(RegExp('-?[1-9][0-9]*'));
      expect(parser.parse(InputSource('abcd'.split(''))), null);
      expect(parser.parse(InputSource('-'.split(''))), null);
      expect(parser.parse(InputSource('-1'.split(''))), '-1');
      var inputSource = InputSource('-1a'.split(''));
      expect(parser.parse(inputSource), '-1');
      expect(inputSource.nextItem(), 'a');
    });
  });
}
