// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';

import 'otel_vonage_suppression.dart';

const _tracerName = 'dartastic_otel_libs_vonage';

Tracer _tracer() => OTel.tracerProvider().getTracer(_tracerName);

class VonageResult {
  const VonageResult({
    this.api,
    this.applicationId,
    this.from,
    this.to,
    this.countryCode,
    this.networkCode,
    this.messageId,
    this.messageType,
    this.messageStatus,
    this.smsCount,
    this.smsPriceMicros,
    this.smsCurrency,
    this.callId,
    this.callDirection,
    this.callStatus,
    this.callRateMicros,
    this.callDurationSec,
    this.verifyRequestId,
    this.verifyStatus,
    this.verifyChannel,
    this.verifyAttempts,
    this.numberInsightLevel,
    this.errorCode,
    this.errorMessage,
    this.statusCode,
  });

  /// `sms`, `messages`, `voice`, `verify`, `verify_v2`, `number_insight`,
  /// `numbers`, `applications`, `subaccounts`, `audit`, `conversation`,
  /// `meetings`, `video`.
  final String? api;

  final String? applicationId;

  /// E.164 phone or alphanumeric sender id.
  final String? from;
  final String? to;

  /// ISO 3166-1 alpha-2 destination country.
  final String? countryCode;

  /// MCC+MNC of the destination mobile network.
  final String? networkCode;

  // ── Messaging ──────────────────────────────────────────────────
  final String? messageId;

  /// `sms`, `mms`, `whatsapp`, `viber`, `messenger`, `rcs`.
  final String? messageType;

  /// `accepted`, `delivered`, `failed`, `rejected`, `expired`, `seen`,
  /// `submitted`, `unknown`.
  final String? messageStatus;

  /// Number of SMS segments billed (160-char chunks for GSM-7).
  final int? smsCount;

  /// Per-segment SMS cost in millionths of the billing currency.
  final int? smsPriceMicros;

  /// Currency code (`EUR` is the Vonage default).
  final String? smsCurrency;

  // ── Voice ──────────────────────────────────────────────────────
  final String? callId;

  /// `inbound`, `outbound`.
  final String? callDirection;

  /// `started`, `ringing`, `answered`, `busy`, `cancelled`, `failed`,
  /// `rejected`, `timeout`, `unanswered`, `completed`.
  final String? callStatus;

  /// Per-minute call rate in millionths.
  final int? callRateMicros;

  final int? callDurationSec;

  // ── Verify ─────────────────────────────────────────────────────
  final String? verifyRequestId;

  /// `requested`, `pending`, `verified`, `failed`, `expired`, `cancelled`.
  final String? verifyStatus;

  /// `sms`, `voice`, `whatsapp`, `email`, `silent_auth`.
  final String? verifyChannel;
  final int? verifyAttempts;

  // ── Number Insight ─────────────────────────────────────────────
  /// `basic`, `standard`, `advanced`, `advanced_async`.
  final String? numberInsightLevel;

  /// Vonage error code (e.g. `1` throttled, `2` missing params,
  /// `3` invalid params, `4` invalid credentials, `5` internal error,
  /// `9` partner quota exceeded, `15` invalid number).
  final String? errorCode;
  final String? errorMessage;
  final int? statusCode;
}

class VonageCallResult<T> {
  const VonageCallResult({required this.value, this.result});
  final T value;
  final VonageResult? result;
}

/// Wraps a Vonage API call in a CLIENT span. [operation] is one of
/// `sms.send`, `sms.searchInboundMessages`, `messages.send`,
/// `messages.searchByPhone`, `voice.create`, `voice.get`, `voice.update`,
/// `voice.transferCall`, `voice.playStream`, `voice.stopStream`,
/// `voice.playDtmf`, `voice.playTalk`, `voice.stopTalk`,
/// `voice.earmuffOn`, `voice.earmuffOff`, `voice.muteOn`,
/// `voice.muteOff`, `voice.hangup`, `verify.request`, `verify.check`,
/// `verify.cancel`, `verify.searchRequest`, `verify_v2.startVerification`,
/// `verify_v2.checkCode`, `verify_v2.cancelVerification`,
/// `number_insight.basic`, `number_insight.standard`,
/// `number_insight.advanced`, `numbers.list`, `numbers.buy`,
/// `numbers.cancel`, `numbers.update`, `applications.create`,
/// `applications.list`, `applications.update`, `applications.delete`,
/// `audit.events`, `conversation.create`, `conversation.send`,
/// `conversation.invite`, `meetings.createRoom`, `meetings.listRooms`,
/// `video.startSession`, `video.startArchive`, `video.stopArchive`.
Future<T> tracedVonage<T>({
  required String operation,
  required Future<VonageCallResult<T>> Function() invoke,
}) async {
  if (vonageInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final m = <String, Object>{
    'rpc.system': 'vonage',
    'rpc.method': operation,
    'vonage.operation': operation,
  };

  final span = _tracer().startSpan(
    'vonage $operation',
    kind: SpanKind.client,
    attributes: OTel.attributesFromMap(m),
  );
  try {
    final r = await invoke();
    if (r.result != null) {
      final res = r.result!;
      final extras = <Attribute<Object>>[];
      if (res.api != null) {
        extras.add(OTel.attributeString('vonage.api', res.api!));
      }
      if (res.applicationId != null) {
        extras.add(OTel.attributeString(
          'vonage.application.id',
          res.applicationId!,
        ));
      }
      if (res.from != null) {
        extras.add(OTel.attributeString('vonage.from', res.from!));
      }
      if (res.to != null) {
        extras.add(OTel.attributeString('vonage.to', res.to!));
      }
      if (res.countryCode != null) {
        extras.add(OTel.attributeString(
          'vonage.country_code',
          res.countryCode!,
        ));
      }
      if (res.networkCode != null) {
        extras.add(OTel.attributeString(
          'vonage.network_code',
          res.networkCode!,
        ));
      }
      if (res.messageId != null) {
        extras.add(OTel.attributeString(
          'vonage.message.id',
          res.messageId!,
        ));
      }
      if (res.messageType != null) {
        extras.add(OTel.attributeString(
          'vonage.message.type',
          res.messageType!,
        ));
      }
      if (res.messageStatus != null) {
        extras.add(OTel.attributeString(
          'vonage.message.status',
          res.messageStatus!,
        ));
        if (res.messageStatus == 'failed' ||
            res.messageStatus == 'rejected' ||
            res.messageStatus == 'expired') {
          span.setStatus(
            SpanStatusCode.Error,
            'Vonage message ${res.messageStatus}',
          );
        }
      }
      if (res.smsCount != null) {
        extras.add(OTel.attributeInt('vonage.sms.count', res.smsCount!));
      }
      if (res.smsPriceMicros != null) {
        extras.add(OTel.attributeInt(
          'vonage.sms.price_micros',
          res.smsPriceMicros!,
        ));
      }
      if (res.smsCurrency != null) {
        extras.add(OTel.attributeString(
          'vonage.sms.currency',
          res.smsCurrency!,
        ));
      }
      if (res.callId != null) {
        extras.add(OTel.attributeString('vonage.call.id', res.callId!));
      }
      if (res.callDirection != null) {
        extras.add(OTel.attributeString(
          'vonage.call.direction',
          res.callDirection!,
        ));
      }
      if (res.callStatus != null) {
        extras.add(OTel.attributeString(
          'vonage.call.status',
          res.callStatus!,
        ));
        if (res.callStatus == 'failed' || res.callStatus == 'rejected') {
          span.setStatus(
            SpanStatusCode.Error,
            'Vonage call ${res.callStatus}',
          );
        }
      }
      if (res.callRateMicros != null) {
        extras.add(OTel.attributeInt(
          'vonage.call.rate_micros',
          res.callRateMicros!,
        ));
      }
      if (res.callDurationSec != null) {
        extras.add(OTel.attributeInt(
          'vonage.call.duration_sec',
          res.callDurationSec!,
        ));
      }
      if (res.verifyRequestId != null) {
        extras.add(OTel.attributeString(
          'vonage.verify.request_id',
          res.verifyRequestId!,
        ));
      }
      if (res.verifyStatus != null) {
        extras.add(OTel.attributeString(
          'vonage.verify.status',
          res.verifyStatus!,
        ));
        if (res.verifyStatus == 'failed' || res.verifyStatus == 'expired') {
          span.setStatus(
            SpanStatusCode.Error,
            'Vonage verify ${res.verifyStatus}',
          );
        }
      }
      if (res.verifyChannel != null) {
        extras.add(OTel.attributeString(
          'vonage.verify.channel',
          res.verifyChannel!,
        ));
      }
      if (res.verifyAttempts != null) {
        extras.add(OTel.attributeInt(
          'vonage.verify.attempts',
          res.verifyAttempts!,
        ));
      }
      if (res.numberInsightLevel != null) {
        extras.add(OTel.attributeString(
          'vonage.number_insight.level',
          res.numberInsightLevel!,
        ));
      }
      if (res.errorCode != null) {
        extras.add(OTel.attributeString(
          'vonage.error.code',
          res.errorCode!,
        ));
        span.setStatus(SpanStatusCode.Error, 'Vonage ${res.errorCode}');
      }
      if (res.errorMessage != null) {
        extras.add(OTel.attributeString(
          'vonage.error.message',
          res.errorMessage!,
        ));
      }
      if (res.statusCode != null) {
        extras.add(OTel.attributeInt(
          'http.response.status_code',
          res.statusCode!,
        ));
        if (res.statusCode! >= 400) {
          span.setStatus(SpanStatusCode.Error, 'Vonage HTTP ${res.statusCode}');
        }
      }
      if (extras.isNotEmpty) span.addAttributes(OTel.attributes(extras));
    }
    return r.value;
  } catch (e, st) {
    span.addAttributes(OTel.attributes([
      OTel.attributeString(
        ErrorResource.errorType.key,
        e.runtimeType.toString(),
      ),
    ]));
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
