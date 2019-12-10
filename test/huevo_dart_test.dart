import 'package:huevo_dart/huevo_dart.dart';
import 'package:test/test.dart';

void main() {
  group('InputSource', () {
    test('return value of hasNext should be false when no elements in source', () {
      var source = InputSource([]);
      expect(source.hasNext(), false);
    });

    test('return value of hasNext should be false while index is equal to lenght of source', () {
      var source = InputSource([null]);
      expect(source.hasNext(), true);
      expect(source.nextItem(), null);
      expect(source.peek(), null);
      expect(source.hasNext(), false);
    });

    test('move back', () {
      var source = InputSource([null]);
      expect(source.hasNext(), true);
      expect(source.nextItem(), null);
      expect(source.peek(), null);
      expect(source.hasNext(), false);

      source.moveBack(1);

      expect(source.hasNext(), true);
      expect(source.nextItem(), null);
      expect(source.peek(), null);
      expect(source.hasNext(), false);
    });
  });
}
