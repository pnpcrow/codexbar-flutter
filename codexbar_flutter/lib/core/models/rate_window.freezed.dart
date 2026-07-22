// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'rate_window.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

RateWindow _$RateWindowFromJson(Map<String, dynamic> json) {
  return _RateWindow.fromJson(json);
}

/// @nodoc
mixin _$RateWindow {
  double get usedPercent => throw _privateConstructorUsedError;
  int? get windowMinutes => throw _privateConstructorUsedError;
  DateTime? get resetsAt => throw _privateConstructorUsedError;
  String? get resetDescription => throw _privateConstructorUsedError;
  double? get nextRegenPercent => throw _privateConstructorUsedError;
  bool get isSyntheticPlaceholder => throw _privateConstructorUsedError;

  /// Serializes this RateWindow to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RateWindow
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RateWindowCopyWith<RateWindow> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RateWindowCopyWith<$Res> {
  factory $RateWindowCopyWith(
    RateWindow value,
    $Res Function(RateWindow) then,
  ) = _$RateWindowCopyWithImpl<$Res, RateWindow>;
  @useResult
  $Res call({
    double usedPercent,
    int? windowMinutes,
    DateTime? resetsAt,
    String? resetDescription,
    double? nextRegenPercent,
    bool isSyntheticPlaceholder,
  });
}

/// @nodoc
class _$RateWindowCopyWithImpl<$Res, $Val extends RateWindow>
    implements $RateWindowCopyWith<$Res> {
  _$RateWindowCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RateWindow
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? usedPercent = null,
    Object? windowMinutes = freezed,
    Object? resetsAt = freezed,
    Object? resetDescription = freezed,
    Object? nextRegenPercent = freezed,
    Object? isSyntheticPlaceholder = null,
  }) {
    return _then(
      _value.copyWith(
            usedPercent: null == usedPercent
                ? _value.usedPercent
                : usedPercent // ignore: cast_nullable_to_non_nullable
                      as double,
            windowMinutes: freezed == windowMinutes
                ? _value.windowMinutes
                : windowMinutes // ignore: cast_nullable_to_non_nullable
                      as int?,
            resetsAt: freezed == resetsAt
                ? _value.resetsAt
                : resetsAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            resetDescription: freezed == resetDescription
                ? _value.resetDescription
                : resetDescription // ignore: cast_nullable_to_non_nullable
                      as String?,
            nextRegenPercent: freezed == nextRegenPercent
                ? _value.nextRegenPercent
                : nextRegenPercent // ignore: cast_nullable_to_non_nullable
                      as double?,
            isSyntheticPlaceholder: null == isSyntheticPlaceholder
                ? _value.isSyntheticPlaceholder
                : isSyntheticPlaceholder // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RateWindowImplCopyWith<$Res>
    implements $RateWindowCopyWith<$Res> {
  factory _$$RateWindowImplCopyWith(
    _$RateWindowImpl value,
    $Res Function(_$RateWindowImpl) then,
  ) = __$$RateWindowImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    double usedPercent,
    int? windowMinutes,
    DateTime? resetsAt,
    String? resetDescription,
    double? nextRegenPercent,
    bool isSyntheticPlaceholder,
  });
}

/// @nodoc
class __$$RateWindowImplCopyWithImpl<$Res>
    extends _$RateWindowCopyWithImpl<$Res, _$RateWindowImpl>
    implements _$$RateWindowImplCopyWith<$Res> {
  __$$RateWindowImplCopyWithImpl(
    _$RateWindowImpl _value,
    $Res Function(_$RateWindowImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RateWindow
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? usedPercent = null,
    Object? windowMinutes = freezed,
    Object? resetsAt = freezed,
    Object? resetDescription = freezed,
    Object? nextRegenPercent = freezed,
    Object? isSyntheticPlaceholder = null,
  }) {
    return _then(
      _$RateWindowImpl(
        usedPercent: null == usedPercent
            ? _value.usedPercent
            : usedPercent // ignore: cast_nullable_to_non_nullable
                  as double,
        windowMinutes: freezed == windowMinutes
            ? _value.windowMinutes
            : windowMinutes // ignore: cast_nullable_to_non_nullable
                  as int?,
        resetsAt: freezed == resetsAt
            ? _value.resetsAt
            : resetsAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        resetDescription: freezed == resetDescription
            ? _value.resetDescription
            : resetDescription // ignore: cast_nullable_to_non_nullable
                  as String?,
        nextRegenPercent: freezed == nextRegenPercent
            ? _value.nextRegenPercent
            : nextRegenPercent // ignore: cast_nullable_to_non_nullable
                  as double?,
        isSyntheticPlaceholder: null == isSyntheticPlaceholder
            ? _value.isSyntheticPlaceholder
            : isSyntheticPlaceholder // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RateWindowImpl implements _RateWindow {
  const _$RateWindowImpl({
    required this.usedPercent,
    this.windowMinutes,
    this.resetsAt,
    this.resetDescription,
    this.nextRegenPercent,
    this.isSyntheticPlaceholder = false,
  });

  factory _$RateWindowImpl.fromJson(Map<String, dynamic> json) =>
      _$$RateWindowImplFromJson(json);

  @override
  final double usedPercent;
  @override
  final int? windowMinutes;
  @override
  final DateTime? resetsAt;
  @override
  final String? resetDescription;
  @override
  final double? nextRegenPercent;
  @override
  @JsonKey()
  final bool isSyntheticPlaceholder;

  @override
  String toString() {
    return 'RateWindow(usedPercent: $usedPercent, windowMinutes: $windowMinutes, resetsAt: $resetsAt, resetDescription: $resetDescription, nextRegenPercent: $nextRegenPercent, isSyntheticPlaceholder: $isSyntheticPlaceholder)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RateWindowImpl &&
            (identical(other.usedPercent, usedPercent) ||
                other.usedPercent == usedPercent) &&
            (identical(other.windowMinutes, windowMinutes) ||
                other.windowMinutes == windowMinutes) &&
            (identical(other.resetsAt, resetsAt) ||
                other.resetsAt == resetsAt) &&
            (identical(other.resetDescription, resetDescription) ||
                other.resetDescription == resetDescription) &&
            (identical(other.nextRegenPercent, nextRegenPercent) ||
                other.nextRegenPercent == nextRegenPercent) &&
            (identical(other.isSyntheticPlaceholder, isSyntheticPlaceholder) ||
                other.isSyntheticPlaceholder == isSyntheticPlaceholder));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    usedPercent,
    windowMinutes,
    resetsAt,
    resetDescription,
    nextRegenPercent,
    isSyntheticPlaceholder,
  );

  /// Create a copy of RateWindow
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RateWindowImplCopyWith<_$RateWindowImpl> get copyWith =>
      __$$RateWindowImplCopyWithImpl<_$RateWindowImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RateWindowImplToJson(this);
  }
}

abstract class _RateWindow implements RateWindow {
  const factory _RateWindow({
    required final double usedPercent,
    final int? windowMinutes,
    final DateTime? resetsAt,
    final String? resetDescription,
    final double? nextRegenPercent,
    final bool isSyntheticPlaceholder,
  }) = _$RateWindowImpl;

  factory _RateWindow.fromJson(Map<String, dynamic> json) =
      _$RateWindowImpl.fromJson;

  @override
  double get usedPercent;
  @override
  int? get windowMinutes;
  @override
  DateTime? get resetsAt;
  @override
  String? get resetDescription;
  @override
  double? get nextRegenPercent;
  @override
  bool get isSyntheticPlaceholder;

  /// Create a copy of RateWindow
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RateWindowImplCopyWith<_$RateWindowImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

NamedRateWindow _$NamedRateWindowFromJson(Map<String, dynamic> json) {
  return _NamedRateWindow.fromJson(json);
}

/// @nodoc
mixin _$NamedRateWindow {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  RateWindow get window => throw _privateConstructorUsedError;
  bool get usageKnown => throw _privateConstructorUsedError;

  /// Serializes this NamedRateWindow to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NamedRateWindow
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NamedRateWindowCopyWith<NamedRateWindow> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NamedRateWindowCopyWith<$Res> {
  factory $NamedRateWindowCopyWith(
    NamedRateWindow value,
    $Res Function(NamedRateWindow) then,
  ) = _$NamedRateWindowCopyWithImpl<$Res, NamedRateWindow>;
  @useResult
  $Res call({String id, String title, RateWindow window, bool usageKnown});

  $RateWindowCopyWith<$Res> get window;
}

/// @nodoc
class _$NamedRateWindowCopyWithImpl<$Res, $Val extends NamedRateWindow>
    implements $NamedRateWindowCopyWith<$Res> {
  _$NamedRateWindowCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NamedRateWindow
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? window = null,
    Object? usageKnown = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            window: null == window
                ? _value.window
                : window // ignore: cast_nullable_to_non_nullable
                      as RateWindow,
            usageKnown: null == usageKnown
                ? _value.usageKnown
                : usageKnown // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }

  /// Create a copy of NamedRateWindow
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RateWindowCopyWith<$Res> get window {
    return $RateWindowCopyWith<$Res>(_value.window, (value) {
      return _then(_value.copyWith(window: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$NamedRateWindowImplCopyWith<$Res>
    implements $NamedRateWindowCopyWith<$Res> {
  factory _$$NamedRateWindowImplCopyWith(
    _$NamedRateWindowImpl value,
    $Res Function(_$NamedRateWindowImpl) then,
  ) = __$$NamedRateWindowImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String title, RateWindow window, bool usageKnown});

  @override
  $RateWindowCopyWith<$Res> get window;
}

/// @nodoc
class __$$NamedRateWindowImplCopyWithImpl<$Res>
    extends _$NamedRateWindowCopyWithImpl<$Res, _$NamedRateWindowImpl>
    implements _$$NamedRateWindowImplCopyWith<$Res> {
  __$$NamedRateWindowImplCopyWithImpl(
    _$NamedRateWindowImpl _value,
    $Res Function(_$NamedRateWindowImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of NamedRateWindow
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? window = null,
    Object? usageKnown = null,
  }) {
    return _then(
      _$NamedRateWindowImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        window: null == window
            ? _value.window
            : window // ignore: cast_nullable_to_non_nullable
                  as RateWindow,
        usageKnown: null == usageKnown
            ? _value.usageKnown
            : usageKnown // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$NamedRateWindowImpl implements _NamedRateWindow {
  const _$NamedRateWindowImpl({
    required this.id,
    required this.title,
    required this.window,
    this.usageKnown = true,
  });

  factory _$NamedRateWindowImpl.fromJson(Map<String, dynamic> json) =>
      _$$NamedRateWindowImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final RateWindow window;
  @override
  @JsonKey()
  final bool usageKnown;

  @override
  String toString() {
    return 'NamedRateWindow(id: $id, title: $title, window: $window, usageKnown: $usageKnown)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NamedRateWindowImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.window, window) || other.window == window) &&
            (identical(other.usageKnown, usageKnown) ||
                other.usageKnown == usageKnown));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, title, window, usageKnown);

  /// Create a copy of NamedRateWindow
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NamedRateWindowImplCopyWith<_$NamedRateWindowImpl> get copyWith =>
      __$$NamedRateWindowImplCopyWithImpl<_$NamedRateWindowImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$NamedRateWindowImplToJson(this);
  }
}

abstract class _NamedRateWindow implements NamedRateWindow {
  const factory _NamedRateWindow({
    required final String id,
    required final String title,
    required final RateWindow window,
    final bool usageKnown,
  }) = _$NamedRateWindowImpl;

  factory _NamedRateWindow.fromJson(Map<String, dynamic> json) =
      _$NamedRateWindowImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  RateWindow get window;
  @override
  bool get usageKnown;

  /// Create a copy of NamedRateWindow
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NamedRateWindowImplCopyWith<_$NamedRateWindowImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
