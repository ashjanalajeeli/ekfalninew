// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'donation_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$donationListHash() => r'369f2d025357ea6a64629a443aaaf30c630e7dad';

/// See also [DonationList].
@ProviderFor(DonationList)
final donationListProvider =
    AutoDisposeAsyncNotifierProvider<DonationList, List<Donation>>.internal(
  DonationList.new,
  name: r'donationListProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$donationListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$DonationList = AutoDisposeAsyncNotifier<List<Donation>>;
String _$userDonationsHash() => r'ffb54ffbcd712b4a8d1dcf7f91acb99b9c4106fe';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$UserDonations
    extends BuildlessAutoDisposeAsyncNotifier<List<Donation>> {
  late final String userId;

  FutureOr<List<Donation>> build(
    String userId,
  );
}

/// See also [UserDonations].
@ProviderFor(UserDonations)
const userDonationsProvider = UserDonationsFamily();

/// See also [UserDonations].
class UserDonationsFamily extends Family<AsyncValue<List<Donation>>> {
  /// See also [UserDonations].
  const UserDonationsFamily();

  /// See also [UserDonations].
  UserDonationsProvider call(
    String userId,
  ) {
    return UserDonationsProvider(
      userId,
    );
  }

  @override
  UserDonationsProvider getProviderOverride(
    covariant UserDonationsProvider provider,
  ) {
    return call(
      provider.userId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'userDonationsProvider';
}

/// See also [UserDonations].
class UserDonationsProvider extends AutoDisposeAsyncNotifierProviderImpl<
    UserDonations, List<Donation>> {
  /// See also [UserDonations].
  UserDonationsProvider(
    String userId,
  ) : this._internal(
          () => UserDonations()..userId = userId,
          from: userDonationsProvider,
          name: r'userDonationsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$userDonationsHash,
          dependencies: UserDonationsFamily._dependencies,
          allTransitiveDependencies:
              UserDonationsFamily._allTransitiveDependencies,
          userId: userId,
        );

  UserDonationsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.userId,
  }) : super.internal();

  final String userId;

  @override
  FutureOr<List<Donation>> runNotifierBuild(
    covariant UserDonations notifier,
  ) {
    return notifier.build(
      userId,
    );
  }

  @override
  Override overrideWith(UserDonations Function() create) {
    return ProviderOverride(
      origin: this,
      override: UserDonationsProvider._internal(
        () => create()..userId = userId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        userId: userId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<UserDonations, List<Donation>>
      createElement() {
    return _UserDonationsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UserDonationsProvider && other.userId == userId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, userId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin UserDonationsRef on AutoDisposeAsyncNotifierProviderRef<List<Donation>> {
  /// The parameter `userId` of this provider.
  String get userId;
}

class _UserDonationsProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<UserDonations,
        List<Donation>> with UserDonationsRef {
  _UserDonationsProviderElement(super.provider);

  @override
  String get userId => (origin as UserDonationsProvider).userId;
}

String _$categoryDonationsHash() => r'5516cc4c583734ce6011fd054b8dabc630ef734d';

abstract class _$CategoryDonations
    extends BuildlessAutoDisposeAsyncNotifier<List<Donation>> {
  late final String category;

  FutureOr<List<Donation>> build(
    String category,
  );
}

/// See also [CategoryDonations].
@ProviderFor(CategoryDonations)
const categoryDonationsProvider = CategoryDonationsFamily();

/// See also [CategoryDonations].
class CategoryDonationsFamily extends Family<AsyncValue<List<Donation>>> {
  /// See also [CategoryDonations].
  const CategoryDonationsFamily();

  /// See also [CategoryDonations].
  CategoryDonationsProvider call(
    String category,
  ) {
    return CategoryDonationsProvider(
      category,
    );
  }

  @override
  CategoryDonationsProvider getProviderOverride(
    covariant CategoryDonationsProvider provider,
  ) {
    return call(
      provider.category,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'categoryDonationsProvider';
}

/// See also [CategoryDonations].
class CategoryDonationsProvider extends AutoDisposeAsyncNotifierProviderImpl<
    CategoryDonations, List<Donation>> {
  /// See also [CategoryDonations].
  CategoryDonationsProvider(
    String category,
  ) : this._internal(
          () => CategoryDonations()..category = category,
          from: categoryDonationsProvider,
          name: r'categoryDonationsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$categoryDonationsHash,
          dependencies: CategoryDonationsFamily._dependencies,
          allTransitiveDependencies:
              CategoryDonationsFamily._allTransitiveDependencies,
          category: category,
        );

  CategoryDonationsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.category,
  }) : super.internal();

  final String category;

  @override
  FutureOr<List<Donation>> runNotifierBuild(
    covariant CategoryDonations notifier,
  ) {
    return notifier.build(
      category,
    );
  }

  @override
  Override overrideWith(CategoryDonations Function() create) {
    return ProviderOverride(
      origin: this,
      override: CategoryDonationsProvider._internal(
        () => create()..category = category,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        category: category,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<CategoryDonations, List<Donation>>
      createElement() {
    return _CategoryDonationsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CategoryDonationsProvider && other.category == category;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, category.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CategoryDonationsRef
    on AutoDisposeAsyncNotifierProviderRef<List<Donation>> {
  /// The parameter `category` of this provider.
  String get category;
}

class _CategoryDonationsProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<CategoryDonations,
        List<Donation>> with CategoryDonationsRef {
  _CategoryDonationsProviderElement(super.provider);

  @override
  String get category => (origin as CategoryDonationsProvider).category;
}

String _$donationStatisticsHash() =>
    r'fa794f02f1f630225423c892b1c47dbd741600bf';

/// See also [DonationStatistics].
@ProviderFor(DonationStatistics)
final donationStatisticsProvider = AutoDisposeAsyncNotifierProvider<
    DonationStatistics, Map<String, dynamic>>.internal(
  DonationStatistics.new,
  name: r'donationStatisticsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$donationStatisticsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$DonationStatistics = AutoDisposeAsyncNotifier<Map<String, dynamic>>;
String _$donationFormHash() => r'b485c95a584db4b61cc01ba312e621b56d179fad';

/// See also [DonationForm].
@ProviderFor(DonationForm)
final donationFormProvider =
    AutoDisposeNotifierProvider<DonationForm, Map<String, dynamic>>.internal(
  DonationForm.new,
  name: r'donationFormProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$donationFormHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$DonationForm = AutoDisposeNotifier<Map<String, dynamic>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
