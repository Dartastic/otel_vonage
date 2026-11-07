// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_vonage/otel_vonage.dart';

/// Traces Vonage calls with OpenTelemetry.
///
/// `otel_vonage` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each Vonage call in
/// [tracedVonage]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'vonage-example');

  // Wraps a Vonage API call in a CLIENT span.
  final vonageId = await tracedVonage<String>(
    operation: 'voice.create',
    invoke: () async {
      // Make the Vonage call here, then report what it returned.
      const id = 'vonage_8f3a2c';
      return const VonageCallResult(
          value: id,
          result: VonageResult(
              api: 'sms',
              applicationId: 'application_8f3a2c',
              from: 'example',
              to: 'example',
              countryCode: 'example',
              networkCode: 'example',
              messageId: 'message_8f3a2c',
              messageType: 'sms',
              messageStatus: 'accepted',
              smsCount: 3,
              smsPriceMicros: 120,
              smsCurrency: 'EUR',
              callId: 'call_8f3a2c',
              callDirection: 'inbound',
              callStatus: 'started',
              callRateMicros: 1,
              callDurationSec: 120,
              verifyRequestId: 'verifyrequest_8f3a2c',
              verifyStatus: 'requested',
              verifyChannel: 'sms',
              verifyAttempts: 1,
              numberInsightLevel: 'basic',
              errorCode: '1',
              errorMessage: 'example',
              statusCode: 201));
    },
  );
  OTelLog.info('tracedVonage voice.create returned $vonageId');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutVonageInstrumentationAsync.
  await runWithoutVonageInstrumentationAsync(
    () => tracedVonage<String>(
      operation: 'voice.create',
      invoke: () async {
        const id = 'vonage_8f3a2c';
        return const VonageCallResult(
            value: id,
            result: VonageResult(
                api: 'sms',
                applicationId: 'application_8f3a2c',
                from: 'example',
                to: 'example',
                countryCode: 'example',
                networkCode: 'example',
                messageId: 'message_8f3a2c',
                messageType: 'sms',
                messageStatus: 'accepted',
                smsCount: 3,
                smsPriceMicros: 120,
                smsCurrency: 'EUR',
                callId: 'call_8f3a2c',
                callDirection: 'inbound',
                callStatus: 'started',
                callRateMicros: 1,
                callDurationSec: 120,
                verifyRequestId: 'verifyrequest_8f3a2c',
                verifyStatus: 'requested',
                verifyChannel: 'sms',
                verifyAttempts: 1,
                numberInsightLevel: 'basic',
                errorCode: '1',
                errorMessage: 'example',
                statusCode: 201));
      },
    ),
  );

  await OTel.shutdown();
}
