# Android Builds

## Table of contents
- [Introduction](#introduction)
- [Environment Variables/Parameters](#environment-variables)
  * [Targets](#targets)
- [Example Usage](#examples)
  * [aaos_environment.sh](#aaos_environment)
  * [aaos_initialise.sh](#aaos_initialise)
  * [aaos_build.sh](#aaos_build)
  * [aaos_avd_sdk.sh](#aaos_avd_sdk)
  * [aaos_storage.sh](#aaos_storage)
- [Known Issues](#known-issues)

## Introduction <a name="introduction"></a>

The following provides examples of the environment variables and Jenkins build parameters in order to build Android Automotive virtual devices, and platform targets. It also provides examples to run the scripts standalone on build instances.

This pipeline/scripts supports builds for:

*  [Android Virtual Devices](https://source.android.com/docs/automotive/start/avd/android_virtual_device) for use with [Android Studio](https://source.android.com/docs/automotive/start/avd/android_virtual_device#share-an-avd-image-with-android-studio-users)
* [Cuttlefish Virtual Devices](https://source.android.com/docs/devices/cuttlefish) for use with [CTS](https://source.android.com/docs/compatibility/cts) and emulators.
* Reference hardware platforms such as [RPi](https://github.com/raspberry-vanilla/android_local_manifest) and [Pixel Tablets](https://source.android.com/docs/automotive/start/pixelxl).

## Environment Variables/Parameters <a name="environment-variables"></a>

### AAOS_GERRIT_MANIFEST_URL

This provides the URL for the Android repo manifest. Such as:

* https://dev.horizon-sdv.scpmtk.com/android/platform/manifest (default)
* https://android.googlesource.com/platform/manifest

### AAOS_REVISION

The Android revision, i.e. branch or tag to build. Tested versions are below:

* horizon/android-14.0.0_r30 (ap1a - default)
* horizon/android-14.0.0_r74 (ap2a - refer to Known Issues)
* horizon/android-15.0.0_r4 (ap3a)
* android14-qpr1-automotiveos-release
* android-14.0.0_r22
* android-14.0.0_r30 (ap1a)
* android-14.0.0_r74 (ap2a, refer to Known Issues)
* android-15.0.0_r4 (ap3a)
* android-15.0.0_r10 (ap4a)

### AAOS_LUNCH_TARGET <a name="targets"></a>

The Android target to build Android cuttlefish, virtual devices, Pixel and RPi targets.

Reference: [Codenames, tags, and build numbers](https://source.android.com/docs/setup/reference/build-numbers)

Examples:

- Virtual Devices:
    -   `sdk_car_x86_64-userdebug`
    -   `sdk_car_x86_64-ap1a-userdebug`
    -   `sdk_car_x86_64-ap2a-userdebug`
    -   `sdk_car_x86_64-ap3a-userdebug`
    -   `sdk_car_x86_64-ap4a-userdebug`
    -   `sdk_car_arm64-userdebug`
    -   `sdk_car_arm64-ap1a-userdebug`
    -   `sdk_car_arm64-ap2a-userdebug`
    -   `sdk_car_arm64-ap3a-userdebug`
    -   `sdk_car_arm64-ap4a-userdebug`
    -   `aosp_cf_x86_64_auto-userdebug`
    -   `aosp_cf_x86_64_auto-ap1a-userdebug`
    -   `aosp_cf_x86_64_auto-ap2a-userdebug`
    -   `aosp_cf_x86_64_auto-ap3a-userdebug`
    -   `aosp_cf_x86_64_auto-ap4a-userdebug`
    -   `aosp_cf_arm64_auto-userdebug`
    -   `aosp_cf_arm64_auto-ap1a-userdebug`
    -   `aosp_cf_arm64_auto-ap2a-userdebug`
    -   `aosp_cf_arm64_auto-ap3a-userdebug`
    -   `aosp_cf_arm64_auto-ap4a-userdebug`
-   Pixel Devices:
    -   `aosp_tangorpro_car-ap1a-userdebug`
    -   `aosp_tangorpro_car-ap2a-userdebug`
    -   `aosp_tangorpro_car-ap3a-userdebug`
-   Raspberry Pi:
    -   `aosp_rpi5_car-ap3a-userdebug`

### ANDROID_VERSION

This is required for the SDK Car AVD builds so that the correct `devices.xml` and SDK Addon can be generated for use with Android Studio.

### POST_REPO_INITIALISE_COMMAND

This allows the user to include additional commands to run after the repo has been initialised.


### POST_REPO_SYNC_COMMAND

This allows the user to include additional commands to run after the repo has been synced.

### OVERRIDE_MAKE_COMMAND

This allows the user to override the default target make command.

### AAOS_CLEAN

Option to clean the build workspaace, either fully or simply for the `AAOS_LUNCH_TARGET` target defined.

### GERRIT_REPO_SYNC_JOBS

This is the value used for parallel jobs for `repo sync`, i.e. `-j <GERRIT_REPO_SYNC_JOBS>`.
The default is defined in system environment variable: `REPO_SYNC_JOBS`.
The minimum is 1 and the maximum is 24.

### INSTANCE_RETENTION_TIME

Keep the build VM instance and container running to allow user to connect to it. Useful for debugging build issues, determining target output archives etc.

Access using `kubectl` e.g. `kubectl exec -it -n jenkins <pod name> -- bash` from `bastion` host.

### AAOS_ARTIFACT_STORAGE_SOLUTION

Define storage solution used to push artifacts.

Currently `GCS_BUCKET` default pushes to GCS bucket, if empty then nothing will be stored.

### GERRIT_PROJECT / GERRIT_CHANGE_NUMBER / GERRIT_PATCHSET_NUMBER

These allow the user to fetch a specific Gerrit patchset.

## Example Usage <a name="examples"></a>

The following examples show how the scripts may be used standalone on build instances.

### `aaos_environment.sh` <a name="aaos_environment"></a>

This script is responsible for setting up the environment for the build scripts. It is included by all other scripts but can be run standalone to clean the build workspace and recreate.

`AAOS_CLEAN` can be set to either `CLEAN_BUILD`, `CLEAN_ALL` or `NO_CLEAN`.

Example 1: Delete the build `out` folder
```
AAOS_CLEAN=CLEAN_BUILD \
AAOS_LUNCH_TARGET=aosp_cf_x86_64_auto-ap1a-userdebug \
./workloads/android/pipelines/builds/aaos_builder/aaos_environment.sh
```

Example 2: Delete the full cache/build workspace
```
AAOS_CLEAN=CLEAN_ALL \
./workloads/android/pipelines/builds/aaos_builder/aaos_environment.sh
```

### `aaos_initialise.sh` <a name="aaos_initialise"></a>
This script is responsible for initialising the repos for the given manifest, branch and target.

Some targets have their own definitions for `POST_REPO_INITIALISE_COMMAND` and `POST_REPO_SYNC_COMMAND` but these can be overridden.

Example 1: Initialise the repos for `aosp_cf_x86_64_auto-ap1a-userdebug`
```
AAOS_GERRIT_MANIFEST_URL=https://dev.horizon-sdv.scpmtk.com/android/platform/manifest \
AAOS_REVISION=horizon/android-14.0.0_r30 \
AAOS_LUNCH_TARGET=aosp_cf_x86_64_auto-ap1a-userdebug \
./workloads/android/pipelines/builds/aaos_builder/aaos_initialise.sh
```

Example 2: Initialise the repos for `aosp_tangorpro_car-ap1a-userdebug` with Gerrit patch set.
```
AAOS_GERRIT_MANIFEST_URL=https://dev.horizon-sdv.scpmtk.com/android/platform/manifest \
AAOS_REVISION=horizon/android-14.0.0_r30 \
AAOS_LUNCH_TARGET=aosp_tangorpro_car-ap1a-userdebug \
GERRIT_CHANGE_NUMBER=82 \
GERRIT_PATCHSET_NUMBER=1 \
GERRIT_PROJECT=android/platform/packages/services/Car \
./workloads/android/pipelines/builds/aaos_builder/aaos_initialise.sh
```

### `aaos_build.sh` <a name="aaos_build"></a>
This script is responsible for building the given target.
```
AAOS_LUNCH_TARGET=sdk_car_x86_64-ap1a-userdebug \
./workloads/android/pipelines/builds/aaos_builder/aaos_build.sh
```

### `aaos_avd_sdk.sh` <a name="aaos_avd_sdk"></a>
This script creates the addon and devices files required for using AVD images with Android studio.

This is only applicable to AVD `sdk_car` based targets.

```
AAOS_LUNCH_TARGET=sdk_car_x86_64-ap1a-userdebug \
ANDROID_VERSION=14 \
./workloads/android/pipelines/builds/aaos_builder/aaos_avd_sdk.sh
```

### `aaos_storage.sh` <a name="aaos_storage"></a>
This for standalone is effectively a noop. Storage is currently dependent on Jenkins `BUILD_NUMBER`.
Developers may upload their build artifacts to their own storage solution.

```
AAOS_LUNCH_TARGET=sdk_car_x86_64-ap1a-userdebug \
./workloads/android/pipelines/builds/aaos_builder/aaos_storage.sh
```

## KNOWN ISSUES <a name="known-issues"></a>

### `android-qpr1-automotiveos-release` and Cuttlefish Virtual Devices:

-   Avoid using for Cuttlefish Virtual Devices. Use `android-14.0.0_r30` instead.
    -   Black Screen, unresponsive, sluggish UI issues.

### `android-14.0.0_r30` and `tangorpro_car-ap1a`:

-   Fix the audio crash:

    -   Take a patch (https://android-review.googlesource.com/c/platform/packages/services/Car/+/3037383):
        -  Build with the following parameters:
	    - `GERRIT_PROJECT=platform/packages/services/Car`
	    - `GERRIT_CHANGE_NUMBER=3037383`
	    - `GERRIT_PATCHSET_NUMBER=2`
    -   Reference: [Pixel Tablets](https://source.android.com/docs/automotive/start/pixelxl)

### `android-14.0.0_r74` and some earlier releases:

-   To avoid DEX build issues for AAOSP builds on standalone build instances:

    -   Build with `WITH_DEXPREOPT=false`, e.g. `m WITH_DEXPREOPT=false`

-   Avoid surround view automotive test issues breaking builds:

    -   i.e. Unknown installed file for module 'sv_2d_session_tests'/'sv_3d_session_tests'

    -   Either [Revert](https://android.googlesource.com/platform/platform_testing/+/b608b75b5f2a5f614bd75599023a45f3c321d4a9 "https://android.googlesource.com/platform/platform_testing/+/b608b75b5f2a5f614bd75599023a45f3c321d4a9") commit, or download the revert change from Gerrit review:
	    - `GERRIT_PROJECT=platform/platform_testing`
	    - `GERRIT_CHANGE_NUMBER=3183939`
	    - `GERRIT_PATCHSET_NUMBER=1`

	  or locally remove erroneous tests from native_test_list.mk:
	   -   `sed -i '/sv_2d_session_tests/,/sv_3d_session_tests/d' build/tasks/tests/native_test_list.mk`
       -   `sed -i 's/evsmanagerd_test \\/evsmanagerd_test/' build/tasks/tests/native_test_list.mk`

### `android-15.0.0_r10` and Cuttlefish Virtual Devices

-   Avoid multiple instances when running Cuttlefish. Instance 1 works fine, instance 2 and onwards do not work.
    -   `android-15.0.0_r4` is a more reliable release.

-   CTS (full) does not complete in timely manner:
    -   `android-15.0.0_r4`  : 43m29s
    -   `android-15.0.0_r10` : 3h and not completed (stuck in `CtsLibcoreOjTestCases` tests).
    -   `android-15.0.0_r10` : very new, latest and thus expect bugs.

### Cuttlefish and CTS

-   Some releases of Android have issues with launching cuttlefish virtual devices.
    `android-14.0.0_r30` is a more reliable release.
-   If using later releases than `android-14.0.0_r30`, consider tailoring the CTS Execution resources to suit those of
    the version under test. The number of instances, CPUs and Memory defaults are set up as default for `android-14.0.0_r30`.

### RPi Targets

-   [RPi](https://github.com/raspberry-vanilla/android_local_manifest) targets and branch names can change. Currently we define limited support in [aaos_environment.sh](#aaos_environment) but user may override the `repo init` command to include newer manifests and branch names that may not align with Google main branch. Simply update `POST_REPO_INITIALISE_COMMAND` with the RPi command that you prefer post `repo init`.

### Resource Limits (Pod)

-    The resource limits in the Jenkins Pod templates were chosen to give the optimal performance of builds. Higher values exposed issues with Jenkins kubernetes plugin and losing connection with the agent. e.g. The instance has 112 cores but some of those are required by Jenkins agent, 96 was most reliable to get the optimal performance.
