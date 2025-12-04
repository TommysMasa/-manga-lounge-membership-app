import 'package:flutter_test/flutter_test.dart';
import 'package:manga_lounge/core/models/country_code.dart';
import 'package:manga_lounge/shared/constants/country_codes.dart';

void main() {
  group('CountryCode US', () {
    late CountryCode us;

    setUp(() {
      us = const CountryCode(
        name: 'United States',
        isoCode: 'US',
        dialCode: '+1',
        flagEmoji: '🇺🇸',
        phoneLength: 10,
        formatHint: '(555) 123-4567',
      );
    });

    group('format()', () {
      test('formats empty string', () {
        expect(us.format(''), '');
      });

      test('formats 1-3 digits with opening parenthesis', () {
        expect(us.format('5'), '(5');
        expect(us.format('55'), '(55');
        expect(us.format('555'), '(555');
      });

      test('formats 4-6 digits with area code and space', () {
        expect(us.format('5551'), '(555) 1');
        expect(us.format('55512'), '(555) 12');
        expect(us.format('555123'), '(555) 123');
      });

      test('formats 7-10 digits with full format', () {
        expect(us.format('5551234'), '(555) 123-4');
        expect(us.format('55512345'), '(555) 123-45');
        expect(us.format('555123456'), '(555) 123-456');
        expect(us.format('5551234567'), '(555) 123-4567');
      });

      test('truncates digits beyond phoneLength', () {
        expect(us.format('55512345678'), '(555) 123-4567');
        expect(us.format('555123456789012'), '(555) 123-4567');
      });

      test('strips non-digit characters before formatting', () {
        expect(us.format('555-123-4567'), '(555) 123-4567');
        expect(us.format('(555) 123-4567'), '(555) 123-4567');
        expect(us.format('555 123 4567'), '(555) 123-4567');
      });
    });

    group('isValid()', () {
      test('returns true for valid 10-digit phone numbers', () {
        expect(us.isValid('5551234567'), true);
        expect(us.isValid('(555) 123-4567'), true);
        expect(us.isValid('555-123-4567'), true);
      });

      test('returns false for phone numbers with less than 10 digits', () {
        expect(us.isValid('555123456'), false);
        expect(us.isValid('12345'), false);
        expect(us.isValid(''), false);
      });

      test('returns false for phone numbers with more than 10 digits', () {
        expect(us.isValid('55512345678'), false);
      });
    });

    group('toE164()', () {
      test('converts formatted phone number to E.164', () {
        expect(us.toE164('(555) 123-4567'), '+15551234567');
      });

      test('converts various formats to E.164', () {
        expect(us.toE164('555-123-4567'), '+15551234567');
        expect(us.toE164('555.123.4567'), '+15551234567');
        expect(us.toE164('5551234567'), '+15551234567');
      });
    });

    test('displayText shows flag and dial code', () {
      expect(us.displayText, '🇺🇸 +1');
    });
  });

  group('CountryCode JP', () {
    late CountryCode jp;

    setUp(() {
      jp = const CountryCode(
        name: 'Japan',
        isoCode: 'JP',
        dialCode: '+81',
        flagEmoji: '🇯🇵',
        phoneLength: 10,
        formatHint: '80-1234-5678',
      );
    });

    group('format()', () {
      test('formats empty string', () {
        expect(jp.format(''), '');
      });

      test('formats 1-2 digits', () {
        expect(jp.format('8'), '8');
        expect(jp.format('80'), '80');
      });

      test('formats 3-6 digits with first hyphen', () {
        expect(jp.format('801'), '80-1');
        expect(jp.format('8012'), '80-12');
        expect(jp.format('80123'), '80-123');
        expect(jp.format('801234'), '80-1234');
      });

      test('formats 7-10 digits with full format', () {
        expect(jp.format('8012345'), '80-1234-5');
        expect(jp.format('80123456'), '80-1234-56');
        expect(jp.format('801234567'), '80-1234-567');
        expect(jp.format('8012345678'), '80-1234-5678');
      });

      test('truncates digits beyond phoneLength', () {
        expect(jp.format('80123456789'), '80-1234-5678');
        expect(jp.format('8012345678901'), '80-1234-5678');
      });

      test('strips non-digit characters before formatting', () {
        expect(jp.format('80-1234-5678'), '80-1234-5678');
        expect(jp.format('80 1234 5678'), '80-1234-5678');
      });
    });

    group('isValid()', () {
      test('returns true for valid 10-digit phone numbers', () {
        expect(jp.isValid('8012345678'), true);
        expect(jp.isValid('80-1234-5678'), true);
        expect(jp.isValid('80 1234 5678'), true);
      });

      test('returns false for phone numbers with less than 10 digits', () {
        expect(jp.isValid('801234567'), false);
        expect(jp.isValid('12345'), false);
        expect(jp.isValid(''), false);
      });

      test('returns false for phone numbers with more than 10 digits', () {
        expect(jp.isValid('80123456789'), false);
      });
    });

    group('toE164()', () {
      test('converts formatted phone number to E.164', () {
        expect(jp.toE164('80-1234-5678'), '+818012345678');
      });

      test('converts various formats to E.164', () {
        expect(jp.toE164('8012345678'), '+818012345678');
        expect(jp.toE164('80 1234 5678'), '+818012345678');
      });
    });

    test('displayText shows flag and dial code', () {
      expect(jp.displayText, '🇯🇵 +81');
    });
  });

  group('availableCountryCodes constants', () {
    test('has correct number of countries', () {
      expect(availableCountryCodes.length, 2);
    });

    test('contains US and JP', () {
      expect(availableCountryCodes.any((c) => c.isoCode == 'US'), true);
      expect(availableCountryCodes.any((c) => c.isoCode == 'JP'), true);
    });

    test('defaultCountryCode is first in list', () {
      expect(defaultCountryCode, availableCountryCodes.first);
    });

    test('defaultCountryCode is US', () {
      expect(defaultCountryCode.isoCode, 'US');
    });
  });

  group('Integration tests', () {
    test('format, validate, and convert to E.164 for US', () {
      const us = CountryCode(
        name: 'United States',
        isoCode: 'US',
        dialCode: '+1',
        flagEmoji: '🇺🇸',
        phoneLength: 10,
        formatHint: '(555) 123-4567',
      );

      const input = '5551234567';

      // Format for display
      final formatted = us.format(input);
      expect(formatted, '(555) 123-4567');

      // Validate
      expect(us.isValid(formatted), true);

      // Convert to E.164 for API
      final e164 = us.toE164(formatted);
      expect(e164, '+15551234567');
    });

    test('format, validate, and convert to E.164 for JP', () {
      const jp = CountryCode(
        name: 'Japan',
        isoCode: 'JP',
        dialCode: '+81',
        flagEmoji: '🇯🇵',
        phoneLength: 10,
        formatHint: '80-1234-5678',
      );

      const input = '8012345678';

      // Format for display
      final formatted = jp.format(input);
      expect(formatted, '80-1234-5678');

      // Validate
      expect(jp.isValid(formatted), true);

      // Convert to E.164 for API
      final e164 = jp.toE164(formatted);
      expect(e164, '+818012345678');
    });

    test('handle user input with partial entry', () {
      const us = CountryCode(
        name: 'United States',
        isoCode: 'US',
        dialCode: '+1',
        flagEmoji: '🇺🇸',
        phoneLength: 10,
        formatHint: '(555) 123-4567',
      );

      // User types: 5-5-5-1-2-3
      const partialInput = '555123';

      final formatted = us.format(partialInput);
      expect(formatted, '(555) 123');

      expect(us.isValid(formatted), false);
    });
  });
}
