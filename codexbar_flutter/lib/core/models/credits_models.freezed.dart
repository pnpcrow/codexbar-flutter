// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'credits_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CreditsSnapshot _$CreditsSnapshotFromJson(Map<String, dynamic> json) {
  return _CreditsSnapshot.fromJson(json);
}

/// @nodoc
mixin _$CreditsSnapshot {
  double? get remaining => throw _privateConstructorUsedError;
  double? get total => throw _privateConstructorUsedError;
  String? get currency => throw _privateConstructorUsedError;
  double? get codexCreditLimitRemaining => throw _privateConstructorUsedError;
  double? get codexCreditLimitTotal => throw _privateConstructorUsedError;

  /// Serializes this CreditsSnapshot to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CreditsSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreditsSnapshotCopyWith<CreditsSnapshot> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreditsSnapshotCopyWith<$Res> {
  factory $CreditsSnapshotCopyWith(
    CreditsSnapshot value,
    $Res Function(CreditsSnapshot) then,
  ) = _$CreditsSnapshotCopyWithImpl<$Res, CreditsSnapshot>;
  @useResult
  $Res call({
    double? remaining,
    double? total,
    String? currency,
    double? codexCreditLimitRemaining,
    double? codexCreditLimitTotal,
  });
}

/// @nodoc
class _$CreditsSnapshotCopyWithImpl<$Res, $Val extends CreditsSnapshot>
    implements $CreditsSnapshotCopyWith<$Res> {
  _$CreditsSnapshotCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreditsSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? remaining = freezed,
    Object? total = freezed,
    Object? currency = freezed,
    Object? codexCreditLimitRemaining = freezed,
    Object? codexCreditLimitTotal = freezed,
  }) {
    return _then(
      _value.copyWith(
            remaining: freezed == remaining
                ? _value.remaining
                : remaining // ignore: cast_nullable_to_non_nullable
                      as double?,
            total: freezed == total
                ? _value.total
                : total // ignore: cast_nullable_to_non_nullable
                      as double?,
            currency: freezed == currency
                ? _value.currency
                : currency // ignore: cast_nullable_to_non_nullable
                      as String?,
            codexCreditLimitRemaining: freezed == codexCreditLimitRemaining
                ? _value.codexCreditLimitRemaining
                : codexCreditLimitRemaining // ignore: cast_nullable_to_non_nullable
                      as double?,
            codexCreditLimitTotal: freezed == codexCreditLimitTotal
                ? _value.codexCreditLimitTotal
                : codexCreditLimitTotal // ignore: cast_nullable_to_non_nullable
                      as double?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CreditsSnapshotImplCopyWith<$Res>
    implements $CreditsSnapshotCopyWith<$Res> {
  factory _$$CreditsSnapshotImplCopyWith(
    _$CreditsSnapshotImpl value,
    $Res Function(_$CreditsSnapshotImpl) then,
  ) = __$$CreditsSnapshotImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    double? remaining,
    double? total,
    String? currency,
    double? codexCreditLimitRemaining,
    double? codexCreditLimitTotal,
  });
}

/// @nodoc
class __$$CreditsSnapshotImplCopyWithImpl<$Res>
    extends _$CreditsSnapshotCopyWithImpl<$Res, _$CreditsSnapshotImpl>
    implements _$$CreditsSnapshotImplCopyWith<$Res> {
  __$$CreditsSnapshotImplCopyWithImpl(
    _$CreditsSnapshotImpl _value,
    $Res Function(_$CreditsSnapshotImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CreditsSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? remaining = freezed,
    Object? total = freezed,
    Object? currency = freezed,
    Object? codexCreditLimitRemaining = freezed,
    Object? codexCreditLimitTotal = freezed,
  }) {
    return _then(
      _$CreditsSnapshotImpl(
        remaining: freezed == remaining
            ? _value.remaining
            : remaining // ignore: cast_nullable_to_non_nullable
                  as double?,
        total: freezed == total
            ? _value.total
            : total // ignore: cast_nullable_to_non_nullable
                  as double?,
        currency: freezed == currency
            ? _value.currency
            : currency // ignore: cast_nullable_to_non_nullable
                  as String?,
        codexCreditLimitRemaining: freezed == codexCreditLimitRemaining
            ? _value.codexCreditLimitRemaining
            : codexCreditLimitRemaining // ignore: cast_nullable_to_non_nullable
                  as double?,
        codexCreditLimitTotal: freezed == codexCreditLimitTotal
            ? _value.codexCreditLimitTotal
            : codexCreditLimitTotal // ignore: cast_nullable_to_non_nullable
                  as double?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CreditsSnapshotImpl implements _CreditsSnapshot {
  const _$CreditsSnapshotImpl({
    this.remaining,
    this.total,
    this.currency,
    this.codexCreditLimitRemaining,
    this.codexCreditLimitTotal,
  });

  factory _$CreditsSnapshotImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreditsSnapshotImplFromJson(json);

  @override
  final double? remaining;
  @override
  final double? total;
  @override
  final String? currency;
  @override
  final double? codexCreditLimitRemaining;
  @override
  final double? codexCreditLimitTotal;

  @override
  String toString() {
    return 'CreditsSnapshot(remaining: $remaining, total: $total, currency: $currency, codexCreditLimitRemaining: $codexCreditLimitRemaining, codexCreditLimitTotal: $codexCreditLimitTotal)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreditsSnapshotImpl &&
            (identical(other.remaining, remaining) ||
                other.remaining == remaining) &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(
                  other.codexCreditLimitRemaining,
                  codexCreditLimitRemaining,
                ) ||
                other.codexCreditLimitRemaining == codexCreditLimitRemaining) &&
            (identical(other.codexCreditLimitTotal, codexCreditLimitTotal) ||
                other.codexCreditLimitTotal == codexCreditLimitTotal));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    remaining,
    total,
    currency,
    codexCreditLimitRemaining,
    codexCreditLimitTotal,
  );

  /// Create a copy of CreditsSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreditsSnapshotImplCopyWith<_$CreditsSnapshotImpl> get copyWith =>
      __$$CreditsSnapshotImplCopyWithImpl<_$CreditsSnapshotImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CreditsSnapshotImplToJson(this);
  }
}

abstract class _CreditsSnapshot implements CreditsSnapshot {
  const factory _CreditsSnapshot({
    final double? remaining,
    final double? total,
    final String? currency,
    final double? codexCreditLimitRemaining,
    final double? codexCreditLimitTotal,
  }) = _$CreditsSnapshotImpl;

  factory _CreditsSnapshot.fromJson(Map<String, dynamic> json) =
      _$CreditsSnapshotImpl.fromJson;

  @override
  double? get remaining;
  @override
  double? get total;
  @override
  String? get currency;
  @override
  double? get codexCreditLimitRemaining;
  @override
  double? get codexCreditLimitTotal;

  /// Create a copy of CreditsSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreditsSnapshotImplCopyWith<_$CreditsSnapshotImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AccountInfo _$AccountInfoFromJson(Map<String, dynamic> json) {
  return _AccountInfo.fromJson(json);
}

/// @nodoc
mixin _$AccountInfo {
  String? get email => throw _privateConstructorUsedError;
  String? get plan => throw _privateConstructorUsedError;
  String? get organization => throw _privateConstructorUsedError;

  /// Serializes this AccountInfo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AccountInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AccountInfoCopyWith<AccountInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AccountInfoCopyWith<$Res> {
  factory $AccountInfoCopyWith(
    AccountInfo value,
    $Res Function(AccountInfo) then,
  ) = _$AccountInfoCopyWithImpl<$Res, AccountInfo>;
  @useResult
  $Res call({String? email, String? plan, String? organization});
}

/// @nodoc
class _$AccountInfoCopyWithImpl<$Res, $Val extends AccountInfo>
    implements $AccountInfoCopyWith<$Res> {
  _$AccountInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AccountInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? email = freezed,
    Object? plan = freezed,
    Object? organization = freezed,
  }) {
    return _then(
      _value.copyWith(
            email: freezed == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String?,
            plan: freezed == plan
                ? _value.plan
                : plan // ignore: cast_nullable_to_non_nullable
                      as String?,
            organization: freezed == organization
                ? _value.organization
                : organization // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AccountInfoImplCopyWith<$Res>
    implements $AccountInfoCopyWith<$Res> {
  factory _$$AccountInfoImplCopyWith(
    _$AccountInfoImpl value,
    $Res Function(_$AccountInfoImpl) then,
  ) = __$$AccountInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? email, String? plan, String? organization});
}

/// @nodoc
class __$$AccountInfoImplCopyWithImpl<$Res>
    extends _$AccountInfoCopyWithImpl<$Res, _$AccountInfoImpl>
    implements _$$AccountInfoImplCopyWith<$Res> {
  __$$AccountInfoImplCopyWithImpl(
    _$AccountInfoImpl _value,
    $Res Function(_$AccountInfoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AccountInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? email = freezed,
    Object? plan = freezed,
    Object? organization = freezed,
  }) {
    return _then(
      _$AccountInfoImpl(
        email: freezed == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String?,
        plan: freezed == plan
            ? _value.plan
            : plan // ignore: cast_nullable_to_non_nullable
                  as String?,
        organization: freezed == organization
            ? _value.organization
            : organization // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AccountInfoImpl implements _AccountInfo {
  const _$AccountInfoImpl({this.email, this.plan, this.organization});

  factory _$AccountInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$AccountInfoImplFromJson(json);

  @override
  final String? email;
  @override
  final String? plan;
  @override
  final String? organization;

  @override
  String toString() {
    return 'AccountInfo(email: $email, plan: $plan, organization: $organization)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AccountInfoImpl &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.plan, plan) || other.plan == plan) &&
            (identical(other.organization, organization) ||
                other.organization == organization));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, email, plan, organization);

  /// Create a copy of AccountInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AccountInfoImplCopyWith<_$AccountInfoImpl> get copyWith =>
      __$$AccountInfoImplCopyWithImpl<_$AccountInfoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AccountInfoImplToJson(this);
  }
}

abstract class _AccountInfo implements AccountInfo {
  const factory _AccountInfo({
    final String? email,
    final String? plan,
    final String? organization,
  }) = _$AccountInfoImpl;

  factory _AccountInfo.fromJson(Map<String, dynamic> json) =
      _$AccountInfoImpl.fromJson;

  @override
  String? get email;
  @override
  String? get plan;
  @override
  String? get organization;

  /// Create a copy of AccountInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AccountInfoImplCopyWith<_$AccountInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
