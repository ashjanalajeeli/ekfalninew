// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sponsor_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sponsorServiceHash() => r'd338c14c1adbefab1d256d6259d568f5111f53a3';

/// See also [sponsorService].
@ProviderFor(sponsorService)
final sponsorServiceProvider = AutoDisposeProvider<SponsorService>.internal(
  sponsorService,
  name: r'sponsorServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$sponsorServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SponsorServiceRef = AutoDisposeProviderRef<SponsorService>;
String _$sponsorNotifierHash() => r'474f45741dd137d6b292b310c2cff3ed021aeda1';

/// See also [SponsorNotifier].
@ProviderFor(SponsorNotifier)
final sponsorNotifierProvider =
    AutoDisposeNotifierProvider<SponsorNotifier, SponsorState>.internal(
  SponsorNotifier.new,
  name: r'sponsorNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$sponsorNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SponsorNotifier = AutoDisposeNotifier<SponsorState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
