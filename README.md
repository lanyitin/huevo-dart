A basic compiler infrastructure for Learning how to create a compile without any compiler's compiler

## Features and bugs

[X] a parser combinator library for parsing text
[ ] a set of AST nodes that can represent basic arithmetic operations and boolean operations
[ ] a machine code generator for WebAssembly

Please file feature requests and bugs at the [https://github.com/lanyitin/huevo-dart/issues][tracker].

## Usage

A simple parser combinator example:

```dart
import 'package:huevo_dart/huevo_dart.dart';

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
```
