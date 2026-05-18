// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry/testing.dart';
import 'package:otel_vonage/otel_vonage.dart';
import 'package:test/test.dart';

void main() {
  late TestHarness harness;
  late InMemorySpanExporter spans;

  setUpAll(() async {
    harness = await maybeInitializeOtelForTest(serviceName: 'otel_vonage-test');
    spans = harness.spans;
  });

  setUp(() => harness.clear());

  Map<String, Object> attrsOf(Span s) =>
      {for (final a in s.attributes.toList()) a.key: a.value};

  test('sms.send records segment count + price', () async {
    await tracedVonage<String>(
      operation: 'sms.send',
      invoke: () async => const VonageCallResult(
        value: 'ok',
        result: VonageResult(
          api: 'sms',
          from: 'AppName',
          to: '+14155551212',
          countryCode: 'US',
          networkCode: '310410',
          messageStatus: 'accepted',
          smsCount: 2,
          smsPriceMicros: 7500,
          smsCurrency: 'EUR',
        ),
      ),
    );
    final a = attrsOf(spans.findSpanByName('vonage sms.send')!);
    expect(a['vonage.sms.count'], 2);
    expect(a['vonage.sms.price_micros'], 7500);
  });

  test('failed message sets span error', () async {
    await tracedVonage<String>(
      operation: 'messages.send',
      invoke: () async => const VonageCallResult(
        value: 'ok',
        result: VonageResult(messageStatus: 'failed'),
      ),
    );
    expect(
      spans.findSpanByName('vonage messages.send')!.status,
      SpanStatusCode.Error,
    );
  });

  test('verify request records channel + attempts', () async {
    await tracedVonage<String>(
      operation: 'verify.request',
      invoke: () async => const VonageCallResult(
        value: 'ok',
        result: VonageResult(
          api: 'verify',
          verifyRequestId: 'req_1',
          verifyStatus: 'pending',
          verifyChannel: 'sms',
          verifyAttempts: 1,
        ),
      ),
    );
    final a = attrsOf(spans.findSpanByName('vonage verify.request')!);
    expect(a['vonage.verify.channel'], 'sms');
    expect(a['vonage.verify.status'], 'pending');
  });

  test('suppression skips spans', () async {
    await runWithoutVonageInstrumentationAsync(() async {
      await tracedVonage<String>(
        operation: 'number_insight.basic',
        invoke: () async => const VonageCallResult(value: 'v'),
      );
    });
    expect(spans.findSpansStartingWith('vonage '), isEmpty);
  });
}
