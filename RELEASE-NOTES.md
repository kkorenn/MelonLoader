## What's Changed:
* Updated ``AsmResolver`` to ``6.0.0-beta.5``
* Updated ``Il2CppInterop`` to ``1.5.1-ci.845``
* Fixed an issue with ``[D]`` Debug Mode Identifier in Console Title not being appended when set with Game Information
* Fixed an issue with ``MelonUtils.SetConsoleTitle`` not working when ``DontSetTitle`` Console option is true
* Fixed an issue with ``Loader.cfg`` saving ``DebugMode`` as true when first launching with a Debug Build
* Implemented support for .NET Portable directories under ``<GAME>/dotnet`` and ``<GAME>/MelonLoader/Dependencies/dotnet``   [[#1062](<https://github.com/LavaGang/MelonLoader/pull/1062>)]
* Fixed compilation issues for MacOS
* Modified Il2Cpp Type Registration to be logged when in Debug Mode
* Fixed cross-compilation issues for Linux
* Fixed Initialization Issues with native Mono and Il2Cpp games on Linux
* Fixed an issue with Automatic Melon Harmony Patching looking for unannotated types
* Fixed UnityEngine.Il2CppAssetBundleManager to support Unity 6000+   [[#1122](<https://github.com/LavaGang/MelonLoader/pull/1122>)]
* Fixed NativeHook Functionality for Linux   [[#1123](<https://github.com/LavaGang/MelonLoader/pull/1123>)]
* Fixed AssemblyVerifier.IsNameValid to support Unicode Standard Annex 15   [[#1094](<https://github.com/LavaGang/MelonLoader/pull/1094>)]
* Fixed an issue with ``Loader.cfg`` having its values overwritten by defaults
* Fixed an issue with ``Loader.cfg`` not recreating missing options
* Fixed an issue with ArgumentException being thrown when parsing duplicate launch options
* Adjusted NuGet package to include package references   [[#1127](<https://github.com/LavaGang/MelonLoader/pull/1127>)]
* Fixed an issue with CoreClrDelegateFixer causing crashes under Wine/Proton
* Fixed NativeHook Backwards Compatibility
* Reverted BootstrapInterop NativeHook exports to utilize pointers again to work around recursive trampoline issue
* Fixed MelonUtils.TryPatchAll methods to allow returned list of generated patches
* Reimplemented warning for CoreClrDelegateFixer.SanityCheckDetour when reusing a pinned delegate
* Added ``0Harmony.dll`` to the list of assemblies to be force-resolved from the included file to fix resolve issues
* Fixed an issue with Warnings and Errors not having identifiers
* Aligned MelonUtils.TryPatchAll extensions to expected Harmony.PatchAll behavior
* Improved Il2CppInterop InjectionHelpers.Setup Fix
* Implemented Tomlet Mapping for Rect and RectInt
* Adjusted OnPreferencesSaved and OnPreferencesLoaded callbacks to fix an issue with them sometimes not being triggered
* Fixed Il2CppICallInjector to ignore shim methods that use GetPinnableReference
* Fixed an issue with MacOS Bootstrap not having the needed ``__interpose``   [[#1138](<https://github.com/LavaGang/MelonLoader/pull/1138>)]
* Added a Launch Script for easier MacOS installation   [[#1138](<https://github.com/LavaGang/MelonLoader/pull/1138>)]
* Fixed MacOS launch failures on Apple Silicon (``OS Error 0``) by ad-hoc re-signing game bundles with a broken code-signature seal or hardened runtime in the launch script
* Fixed an issue with Il2CppICallInjector not handling complete Method Signatures
* Fixed UnityEngine.Il2CppImageConversionManager to support Unity 6000+   [[#1144](<https://github.com/LavaGang/MelonLoader/pull/1144>)]
* Improved .NET Portable Directory loading
* Fixed an issue with Bootstrap Core Pathing being used before Initialization   [[#1163](<https://github.com/LavaGang/MelonLoader/pull/1163>)]
* Rewrote .NET Handling to better abide by overrides
* Implemented Portable .NET Runtime Fallback to help minimize HostFxr load failures
* Fixed an issue with .NET Handling not abiding by Base Directory

## Contributors:
* [JoShMiQueL](<https://github.com/JoShMiQueL>) made a contribution in [#1062](<https://github.com/LavaGang/MelonLoader/pull/1062>)
* [Javialonqv](<https://github.com/Javialonqv>) made a contribution in [#1122](<https://github.com/LavaGang/MelonLoader/pull/1122>) & [#1144](<https://github.com/LavaGang/MelonLoader/pull/1144>)
* [aldelaro5](<https://github.com/aldelaro5>) made a contribution in [#1123](<https://github.com/LavaGang/MelonLoader/pull/1123>)
* [kohanis](<https://github.com/kohanis>) made a contribution in [#1094](<https://github.com/LavaGang/MelonLoader/pull/1094>)
* [ds5678](<https://github.com/ds5678>) made a contribution in [#1127](<https://github.com/LavaGang/MelonLoader/pull/1127>)
* [Rukongai](<https://github.com/Rukongai>) made a contribution in [#1138](<https://github.com/LavaGang/MelonLoader/pull/1138>)
* [Squaduck](<https://github.com/Squaduck>) made a contribution in [#1163](<https://github.com/LavaGang/MelonLoader/pull/1163>)

**Full Changelog**: [CHANGELOG.md](<https://github.com/LavaGang/MelonLoader/blob/master/CHANGELOG.md>) | [v0.7.2...v0.7.3](<https://github.com/LavaGang/MelonLoader/compare/v0.7.2...v0.7.3>)
