// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'usage_snapshot.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ProviderIdentitySnapshot _$ProviderIdentitySnapshotFromJson(
  Map<String, dynamic> json,
) {
  return _ProviderIdentitySnapshot.fromJson(json);
}

/// @nodoc
mixin _$ProviderIdentitySnapshot {
  String? get providerID => throw _privateConstructorUsedError;
  String? get accountEmail => throw _privateConstructorUsedError;
  String? get accountOrganization => throw _privateConstructorUsedError;
  String? get loginMethod => throw _privateConstructorUsedError;
  String? get accountID => throw _privateConstructorUsedError;

  /// Serializes this ProviderIdentitySnapshot to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProviderIdentitySnapshot
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProviderIdentitySnapshotCopyWith<ProviderIdentitySnapshot> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProviderIdentitySnapshotCopyWith<$Res> {
  factory $ProviderIdentitySnapshotCopyWith(
    ProviderIdentitySnapshot value,
    $Res Function(ProviderIdentitySnapshot) then,
  ) = _$ProviderIdentitySnapshotCopyWithImpl<$Res, ProviderIdentitySnapshot>;
  @useResult
  $Res call({
    String? providerID,
    String? accountEmail,
    String? accountOrganization,
    String? loginMethod,
    String? accountID,
  });
}

/// @nodoc
class _$ProviderIdentitySnapshotCopyWithImpl<
  $Res,
  $Val extends ProviderIdentitySnapshot
>
    implements $ProviderIdentitySnapshotCopyWith<$Res> {
  _$ProviderIdentitySnapshotCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProviderIdentitySnapshot
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? providerID = freezed,
    Object? accountEmail = freezed,
    Object? accountOrganization = freezed,
    Object? loginMethod = freezed,
    Object? accountID = freezed,
  }) {
    return _then(
      _value.copyWith(
            providerID: freezed == providerID
                ? _value.providerID
                : providerID // ignore: cast_nullable_to_non_nullable
                      as String?,
            accountEmail: freezed == accountEmail
                ? _value.accountEmail
                : accountEmail // ignore: cast_nullable_to_non_nullable
                      as String?,
            accountOrganization: freezed == accountOrganization
                ? _value.accountOrganization
                : accountOrganization // ignore: cast_nullable_to_non_nullable
                      as String?,
            loginMethod: freezed == loginMethod
                ? _value.loginMethod
                : loginMethod // ignore: cast_nullable_to_non_nullable
                      as String?,
            accountID: freezed == accountID
                ? _value.accountID
                : accountID // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ProviderIdentitySnapshotImplCopyWith<$Res>
    implements $ProviderIdentitySnapshotCopyWith<$Res> {
  factory _$$ProviderIdentitySnapshotImplCopyWith(
    _$ProviderIdentitySnapshotImpl value,
    $Res Function(_$ProviderIdentitySnapshotImpl) then,
  ) = __$$ProviderIdentitySnapshotImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? providerID,
    String? accountEmail,
    String? accountOrganization,
    String? loginMethod,
    String? accountID,
  });
}

/// @nodoc
class __$$ProviderIdentitySnapshotImplCopyWithImpl<$Res>
    extends
        _$ProviderIdentitySnapshotCopyWithImpl<
          $Res,
          _$ProviderIdentitySnapshotImpl
        >
    implements _$$ProviderIdentitySnapshotImplCopyWith<$Res> {
  __$$ProviderIdentitySnapshotImplCopyWithImpl(
    _$ProviderIdentitySnapshotImpl _value,
    $Res Function(_$ProviderIdentitySnapshotImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProviderIdentitySnapshot
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? providerID = freezed,
    Object? accountEmail = freezed,
    Object? accountOrganization = freezed,
    Object? loginMethod = freezed,
    Object? accountID = freezed,
  }) {
    return _then(
      _$ProviderIdentitySnapshotImpl(
        providerID: freezed == providerID
            ? _value.providerID
            : providerID // ignore: cast_nullable_to_non_nullable
                  as String?,
        accountEmail: freezed == accountEmail
            ? _value.accountEmail
            : accountEmail // ignore: cast_nullable_to_non_nullable
                  as String?,
        accountOrganization: freezed == accountOrganization
            ? _value.accountOrganization
            : accountOrganization // ignore: cast_nullable_to_non_nullable
                  as String?,
        loginMethod: freezed == loginMethod
            ? _value.loginMethod
            : loginMethod // ignore: cast_nullable_to_non_nullable
                  as String?,
        accountID: freezed == accountID
            ? _value.accountID
            : accountID // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ProviderIdentitySnapshotImpl implements _ProviderIdentitySnapshot {
  const _$ProviderIdentitySnapshotImpl({
    this.providerID,
    this.accountEmail,
    this.accountOrganization,
    this.loginMethod,
    this.accountID,
  });

  factory _$ProviderIdentitySnapshotImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProviderIdentitySnapshotImplFromJson(json);

  @override
  final String? providerID;
  @override
  final String? accountEmail;
  @override
  final String? accountOrganization;
  @override
  final String? loginMethod;
  @override
  final String? accountID;

  @override
  String toString() {
    return 'ProviderIdentitySnapshot(providerID: $providerID, accountEmail: $accountEmail, accountOrganization: $accountOrganization, loginMethod: $loginMethod, accountID: $accountID)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProviderIdentitySnapshotImpl &&
            (identical(other.providerID, providerID) ||
                other.providerID == providerID) &&
            (identical(other.accountEmail, accountEmail) ||
                other.accountEmail == accountEmail) &&
            (identical(other.accountOrganization, accountOrganization) ||
                other.accountOrganization == accountOrganization) &&
            (identical(other.loginMethod, loginMethod) ||
                other.loginMethod == loginMethod) &&
            (identical(other.accountID, accountID) ||
                other.accountID == accountID));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    providerID,
    accountEmail,
    accountOrganization,
    loginMethod,
    accountID,
  );

  /// Create a copy of ProviderIdentitySnapshot
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProviderIdentitySnapshotImplCopyWith<_$ProviderIdentitySnapshotImpl>
  get copyWith =>
      __$$ProviderIdentitySnapshotImplCopyWithImpl<
        _$ProviderIdentitySnapshotImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProviderIdentitySnapshotImplToJson(this);
  }
}

abstract class _ProviderIdentitySnapshot implements ProviderIdentitySnapshot {
  const factory _ProviderIdentitySnapshot({
    final String? providerID,
    final String? accountEmail,
    final String? accountOrganization,
    final String? loginMethod,
    final String? accountID,
  }) = _$ProviderIdentitySnapshotImpl;

  factory _ProviderIdentitySnapshot.fromJson(Map<String, dynamic> json) =
      _$ProviderIdentitySnapshotImpl.fromJson;

  @override
  String? get providerID;
  @override
  String? get accountEmail;
  @override
  String? get accountOrganization;
  @override
  String? get loginMethod;
  @override
  String? get accountID;

  /// Create a copy of ProviderIdentitySnapshot
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProviderIdentitySnapshotImplCopyWith<_$ProviderIdentitySnapshotImpl>
  get copyWith => throw _privateConstructorUsedError;
}

ProviderCostSnapshot _$ProviderCostSnapshotFromJson(Map<String, dynamic> json) {
  return _ProviderCostSnapshot.fromJson(json);
}

/// @nodoc
mixin _$ProviderCostSnapshot {
  double? get totalCost => throw _privateConstructorUsedError;
  double? get monthlyBudget => throw _privateConstructorUsedError;
  String? get currency => throw _privateConstructorUsedError;

  /// Serializes this ProviderCostSnapshot to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProviderCostSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProviderCostSnapshotCopyWith<ProviderCostSnapshot> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProviderCostSnapshotCopyWith<$Res> {
  factory $ProviderCostSnapshotCopyWith(
    ProviderCostSnapshot value,
    $Res Function(ProviderCostSnapshot) then,
  ) = _$ProviderCostSnapshotCopyWithImpl<$Res, ProviderCostSnapshot>;
  @useResult
  $Res call({double? totalCost, double? monthlyBudget, String? currency});
}

/// @nodoc
class _$ProviderCostSnapshotCopyWithImpl<
  $Res,
  $Val extends ProviderCostSnapshot
>
    implements $ProviderCostSnapshotCopyWith<$Res> {
  _$ProviderCostSnapshotCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProviderCostSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalCost = freezed,
    Object? monthlyBudget = freezed,
    Object? currency = freezed,
  }) {
    return _then(
      _value.copyWith(
            totalCost: freezed == totalCost
                ? _value.totalCost
                : totalCost // ignore: cast_nullable_to_non_nullable
                      as double?,
            monthlyBudget: freezed == monthlyBudget
                ? _value.monthlyBudget
                : monthlyBudget // ignore: cast_nullable_to_non_nullable
                      as double?,
            currency: freezed == currency
                ? _value.currency
                : currency // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ProviderCostSnapshotImplCopyWith<$Res>
    implements $ProviderCostSnapshotCopyWith<$Res> {
  factory _$$ProviderCostSnapshotImplCopyWith(
    _$ProviderCostSnapshotImpl value,
    $Res Function(_$ProviderCostSnapshotImpl) then,
  ) = __$$ProviderCostSnapshotImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double? totalCost, double? monthlyBudget, String? currency});
}

/// @nodoc
class __$$ProviderCostSnapshotImplCopyWithImpl<$Res>
    extends _$ProviderCostSnapshotCopyWithImpl<$Res, _$ProviderCostSnapshotImpl>
    implements _$$ProviderCostSnapshotImplCopyWith<$Res> {
  __$$ProviderCostSnapshotImplCopyWithImpl(
    _$ProviderCostSnapshotImpl _value,
    $Res Function(_$ProviderCostSnapshotImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProviderCostSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalCost = freezed,
    Object? monthlyBudget = freezed,
    Object? currency = freezed,
  }) {
    return _then(
      _$ProviderCostSnapshotImpl(
        totalCost: freezed == totalCost
            ? _value.totalCost
            : totalCost // ignore: cast_nullable_to_non_nullable
                  as double?,
        monthlyBudget: freezed == monthlyBudget
            ? _value.monthlyBudget
            : monthlyBudget // ignore: cast_nullable_to_non_nullable
                  as double?,
        currency: freezed == currency
            ? _value.currency
            : currency // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ProviderCostSnapshotImpl implements _ProviderCostSnapshot {
  const _$ProviderCostSnapshotImpl({
    this.totalCost,
    this.monthlyBudget,
    this.currency,
  });

  factory _$ProviderCostSnapshotImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProviderCostSnapshotImplFromJson(json);

  @override
  final double? totalCost;
  @override
  final double? monthlyBudget;
  @override
  final String? currency;

  @override
  String toString() {
    return 'ProviderCostSnapshot(totalCost: $totalCost, monthlyBudget: $monthlyBudget, currency: $currency)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProviderCostSnapshotImpl &&
            (identical(other.totalCost, totalCost) ||
                other.totalCost == totalCost) &&
            (identical(other.monthlyBudget, monthlyBudget) ||
                other.monthlyBudget == monthlyBudget) &&
            (identical(other.currency, currency) ||
                other.currency == currency));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, totalCost, monthlyBudget, currency);

  /// Create a copy of ProviderCostSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProviderCostSnapshotImplCopyWith<_$ProviderCostSnapshotImpl>
  get copyWith =>
      __$$ProviderCostSnapshotImplCopyWithImpl<_$ProviderCostSnapshotImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ProviderCostSnapshotImplToJson(this);
  }
}

abstract class _ProviderCostSnapshot implements ProviderCostSnapshot {
  const factory _ProviderCostSnapshot({
    final double? totalCost,
    final double? monthlyBudget,
    final String? currency,
  }) = _$ProviderCostSnapshotImpl;

  factory _ProviderCostSnapshot.fromJson(Map<String, dynamic> json) =
      _$ProviderCostSnapshotImpl.fromJson;

  @override
  double? get totalCost;
  @override
  double? get monthlyBudget;
  @override
  String? get currency;

  /// Create a copy of ProviderCostSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProviderCostSnapshotImplCopyWith<_$ProviderCostSnapshotImpl>
  get copyWith => throw _privateConstructorUsedError;
}

UsageSnapshot _$UsageSnapshotFromJson(Map<String, dynamic> json) {
  return _UsageSnapshot.fromJson(json);
}

/// @nodoc
mixin _$UsageSnapshot {
  RateWindow? get primary => throw _privateConstructorUsedError;
  RateWindow? get secondary => throw _privateConstructorUsedError;
  RateWindow? get tertiary => throw _privateConstructorUsedError;
  List<NamedRateWindow>? get extraRateWindows =>
      throw _privateConstructorUsedError;
  ProviderCostSnapshot? get providerCost => throw _privateConstructorUsedError;
  DateTime? get subscriptionExpiresAt => throw _privateConstructorUsedError;
  DateTime? get subscriptionRenewsAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  ProviderIdentitySnapshot? get identity => throw _privateConstructorUsedError;
  UsageDataConfidence get dataConfidence => throw _privateConstructorUsedError;

  /// Serializes this UsageSnapshot to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UsageSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UsageSnapshotCopyWith<UsageSnapshot> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UsageSnapshotCopyWith<$Res> {
  factory $UsageSnapshotCopyWith(
    UsageSnapshot value,
    $Res Function(UsageSnapshot) then,
  ) = _$UsageSnapshotCopyWithImpl<$Res, UsageSnapshot>;
  @useResult
  $Res call({
    RateWindow? primary,
    RateWindow? secondary,
    RateWindow? tertiary,
    List<NamedRateWindow>? extraRateWindows,
    ProviderCostSnapshot? providerCost,
    DateTime? subscriptionExpiresAt,
    DateTime? subscriptionRenewsAt,
    DateTime updatedAt,
    ProviderIdentitySnapshot? identity,
    UsageDataConfidence dataConfidence,
  });

  $RateWindowCopyWith<$Res>? get primary;
  $RateWindowCopyWith<$Res>? get secondary;
  $RateWindowCopyWith<$Res>? get tertiary;
  $ProviderCostSnapshotCopyWith<$Res>? get providerCost;
  $ProviderIdentitySnapshotCopyWith<$Res>? get identity;
}

/// @nodoc
class _$UsageSnapshotCopyWithImpl<$Res, $Val extends UsageSnapshot>
    implements $UsageSnapshotCopyWith<$Res> {
  _$UsageSnapshotCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UsageSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? primary = freezed,
    Object? secondary = freezed,
    Object? tertiary = freezed,
    Object? extraRateWindows = freezed,
    Object? providerCost = freezed,
    Object? subscriptionExpiresAt = freezed,
    Object? subscriptionRenewsAt = freezed,
    Object? updatedAt = null,
    Object? identity = freezed,
    Object? dataConfidence = null,
  }) {
    return _then(
      _value.copyWith(
            primary: freezed == primary
                ? _value.primary
                : primary // ignore: cast_nullable_to_non_nullable
                      as RateWindow?,
            secondary: freezed == secondary
                ? _value.secondary
                : secondary // ignore: cast_nullable_to_non_nullable
                      as RateWindow?,
            tertiary: freezed == tertiary
                ? _value.tertiary
                : tertiary // ignore: cast_nullable_to_non_nullable
                      as RateWindow?,
            extraRateWindows: freezed == extraRateWindows
                ? _value.extraRateWindows
                : extraRateWindows // ignore: cast_nullable_to_non_nullable
                      as List<NamedRateWindow>?,
            providerCost: freezed == providerCost
                ? _value.providerCost
                : providerCost // ignore: cast_nullable_to_non_nullable
                      as ProviderCostSnapshot?,
            subscriptionExpiresAt: freezed == subscriptionExpiresAt
                ? _value.subscriptionExpiresAt
                : subscriptionExpiresAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            subscriptionRenewsAt: freezed == subscriptionRenewsAt
                ? _value.subscriptionRenewsAt
                : subscriptionRenewsAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            identity: freezed == identity
                ? _value.identity
                : identity // ignore: cast_nullable_to_non_nullable
                      as ProviderIdentitySnapshot?,
            dataConfidence: null == dataConfidence
                ? _value.dataConfidence
                : dataConfidence // ignore: cast_nullable_to_non_nullable
                      as UsageDataConfidence,
          )
          as $Val,
    );
  }

  /// Create a copy of UsageSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RateWindowCopyWith<$Res>? get primary {
    if (_value.primary == null) {
      return null;
    }

    return $RateWindowCopyWith<$Res>(_value.primary!, (value) {
      return _then(_value.copyWith(primary: value) as $Val);
    });
  }

  /// Create a copy of UsageSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RateWindowCopyWith<$Res>? get secondary {
    if (_value.secondary == null) {
      return null;
    }

    return $RateWindowCopyWith<$Res>(_value.secondary!, (value) {
      return _then(_value.copyWith(secondary: value) as $Val);
    });
  }

  /// Create a copy of UsageSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RateWindowCopyWith<$Res>? get tertiary {
    if (_value.tertiary == null) {
      return null;
    }

    return $RateWindowCopyWith<$Res>(_value.tertiary!, (value) {
      return _then(_value.copyWith(tertiary: value) as $Val);
    });
  }

  /// Create a copy of UsageSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ProviderCostSnapshotCopyWith<$Res>? get providerCost {
    if (_value.providerCost == null) {
      return null;
    }

    return $ProviderCostSnapshotCopyWith<$Res>(_value.providerCost!, (value) {
      return _then(_value.copyWith(providerCost: value) as $Val);
    });
  }

  /// Create a copy of UsageSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ProviderIdentitySnapshotCopyWith<$Res>? get identity {
    if (_value.identity == null) {
      return null;
    }

    return $ProviderIdentitySnapshotCopyWith<$Res>(_value.identity!, (value) {
      return _then(_value.copyWith(identity: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$UsageSnapshotImplCopyWith<$Res>
    implements $UsageSnapshotCopyWith<$Res> {
  factory _$$UsageSnapshotImplCopyWith(
    _$UsageSnapshotImpl value,
    $Res Function(_$UsageSnapshotImpl) then,
  ) = __$$UsageSnapshotImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    RateWindow? primary,
    RateWindow? secondary,
    RateWindow? tertiary,
    List<NamedRateWindow>? extraRateWindows,
    ProviderCostSnapshot? providerCost,
    DateTime? subscriptionExpiresAt,
    DateTime? subscriptionRenewsAt,
    DateTime updatedAt,
    ProviderIdentitySnapshot? identity,
    UsageDataConfidence dataConfidence,
  });

  @override
  $RateWindowCopyWith<$Res>? get primary;
  @override
  $RateWindowCopyWith<$Res>? get secondary;
  @override
  $RateWindowCopyWith<$Res>? get tertiary;
  @override
  $ProviderCostSnapshotCopyWith<$Res>? get providerCost;
  @override
  $ProviderIdentitySnapshotCopyWith<$Res>? get identity;
}

/// @nodoc
class __$$UsageSnapshotImplCopyWithImpl<$Res>
    extends _$UsageSnapshotCopyWithImpl<$Res, _$UsageSnapshotImpl>
    implements _$$UsageSnapshotImplCopyWith<$Res> {
  __$$UsageSnapshotImplCopyWithImpl(
    _$UsageSnapshotImpl _value,
    $Res Function(_$UsageSnapshotImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UsageSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? primary = freezed,
    Object? secondary = freezed,
    Object? tertiary = freezed,
    Object? extraRateWindows = freezed,
    Object? providerCost = freezed,
    Object? subscriptionExpiresAt = freezed,
    Object? subscriptionRenewsAt = freezed,
    Object? updatedAt = null,
    Object? identity = freezed,
    Object? dataConfidence = null,
  }) {
    return _then(
      _$UsageSnapshotImpl(
        primary: freezed == primary
            ? _value.primary
            : primary // ignore: cast_nullable_to_non_nullable
                  as RateWindow?,
        secondary: freezed == secondary
            ? _value.secondary
            : secondary // ignore: cast_nullable_to_non_nullable
                  as RateWindow?,
        tertiary: freezed == tertiary
            ? _value.tertiary
            : tertiary // ignore: cast_nullable_to_non_nullable
                  as RateWindow?,
        extraRateWindows: freezed == extraRateWindows
            ? _value._extraRateWindows
            : extraRateWindows // ignore: cast_nullable_to_non_nullable
                  as List<NamedRateWindow>?,
        providerCost: freezed == providerCost
            ? _value.providerCost
            : providerCost // ignore: cast_nullable_to_non_nullable
                  as ProviderCostSnapshot?,
        subscriptionExpiresAt: freezed == subscriptionExpiresAt
            ? _value.subscriptionExpiresAt
            : subscriptionExpiresAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        subscriptionRenewsAt: freezed == subscriptionRenewsAt
            ? _value.subscriptionRenewsAt
            : subscriptionRenewsAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        identity: freezed == identity
            ? _value.identity
            : identity // ignore: cast_nullable_to_non_nullable
                  as ProviderIdentitySnapshot?,
        dataConfidence: null == dataConfidence
            ? _value.dataConfidence
            : dataConfidence // ignore: cast_nullable_to_non_nullable
                  as UsageDataConfidence,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UsageSnapshotImpl implements _UsageSnapshot {
  const _$UsageSnapshotImpl({
    this.primary,
    this.secondary,
    this.tertiary,
    final List<NamedRateWindow>? extraRateWindows,
    this.providerCost,
    this.subscriptionExpiresAt,
    this.subscriptionRenewsAt,
    required this.updatedAt,
    this.identity,
    this.dataConfidence = UsageDataConfidence.unknown,
  }) : _extraRateWindows = extraRateWindows;

  factory _$UsageSnapshotImpl.fromJson(Map<String, dynamic> json) =>
      _$$UsageSnapshotImplFromJson(json);

  @override
  final RateWindow? primary;
  @override
  final RateWindow? secondary;
  @override
  final RateWindow? tertiary;
  final List<NamedRateWindow>? _extraRateWindows;
  @override
  List<NamedRateWindow>? get extraRateWindows {
    final value = _extraRateWindows;
    if (value == null) return null;
    if (_extraRateWindows is EqualUnmodifiableListView)
      return _extraRateWindows;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final ProviderCostSnapshot? providerCost;
  @override
  final DateTime? subscriptionExpiresAt;
  @override
  final DateTime? subscriptionRenewsAt;
  @override
  final DateTime updatedAt;
  @override
  final ProviderIdentitySnapshot? identity;
  @override
  @JsonKey()
  final UsageDataConfidence dataConfidence;

  @override
  String toString() {
    return 'UsageSnapshot(primary: $primary, secondary: $secondary, tertiary: $tertiary, extraRateWindows: $extraRateWindows, providerCost: $providerCost, subscriptionExpiresAt: $subscriptionExpiresAt, subscriptionRenewsAt: $subscriptionRenewsAt, updatedAt: $updatedAt, identity: $identity, dataConfidence: $dataConfidence)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UsageSnapshotImpl &&
            (identical(other.primary, primary) || other.primary == primary) &&
            (identical(other.secondary, secondary) ||
                other.secondary == secondary) &&
            (identical(other.tertiary, tertiary) ||
                other.tertiary == tertiary) &&
            const DeepCollectionEquality().equals(
              other._extraRateWindows,
              _extraRateWindows,
            ) &&
            (identical(other.providerCost, providerCost) ||
                other.providerCost == providerCost) &&
            (identical(other.subscriptionExpiresAt, subscriptionExpiresAt) ||
                other.subscriptionExpiresAt == subscriptionExpiresAt) &&
            (identical(other.subscriptionRenewsAt, subscriptionRenewsAt) ||
                other.subscriptionRenewsAt == subscriptionRenewsAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.identity, identity) ||
                other.identity == identity) &&
            (identical(other.dataConfidence, dataConfidence) ||
                other.dataConfidence == dataConfidence));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    primary,
    secondary,
    tertiary,
    const DeepCollectionEquality().hash(_extraRateWindows),
    providerCost,
    subscriptionExpiresAt,
    subscriptionRenewsAt,
    updatedAt,
    identity,
    dataConfidence,
  );

  /// Create a copy of UsageSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UsageSnapshotImplCopyWith<_$UsageSnapshotImpl> get copyWith =>
      __$$UsageSnapshotImplCopyWithImpl<_$UsageSnapshotImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UsageSnapshotImplToJson(this);
  }
}

abstract class _UsageSnapshot implements UsageSnapshot {
  const factory _UsageSnapshot({
    final RateWindow? primary,
    final RateWindow? secondary,
    final RateWindow? tertiary,
    final List<NamedRateWindow>? extraRateWindows,
    final ProviderCostSnapshot? providerCost,
    final DateTime? subscriptionExpiresAt,
    final DateTime? subscriptionRenewsAt,
    required final DateTime updatedAt,
    final ProviderIdentitySnapshot? identity,
    final UsageDataConfidence dataConfidence,
  }) = _$UsageSnapshotImpl;

  factory _UsageSnapshot.fromJson(Map<String, dynamic> json) =
      _$UsageSnapshotImpl.fromJson;

  @override
  RateWindow? get primary;
  @override
  RateWindow? get secondary;
  @override
  RateWindow? get tertiary;
  @override
  List<NamedRateWindow>? get extraRateWindows;
  @override
  ProviderCostSnapshot? get providerCost;
  @override
  DateTime? get subscriptionExpiresAt;
  @override
  DateTime? get subscriptionRenewsAt;
  @override
  DateTime get updatedAt;
  @override
  ProviderIdentitySnapshot? get identity;
  @override
  UsageDataConfidence get dataConfidence;

  /// Create a copy of UsageSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UsageSnapshotImplCopyWith<_$UsageSnapshotImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
