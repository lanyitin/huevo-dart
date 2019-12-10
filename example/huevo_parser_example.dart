import 'package:huevo_parser/huevo_parser.dart';

void main() {
      var inputSource = InputSource('This is A Parser Combinator'.split(''));
      var whiteSpace = Parser.fromElement(' ');
      var keywordThis = StringParser('This');
      var keywordis = StringParser('is');
      var keywordA = StringParser('A');
      var keywordParser = StringParser('Parser');
      var keywordCombinator = StringParser('Combinator');

      var sentanceParser = Parser.join(
          [keywordThis, keywordis, keywordA, keywordParser, keywordCombinator],
          whiteSpace).end();
      var result = sentanceParser.parse(inputSource);
      print(result);
}
