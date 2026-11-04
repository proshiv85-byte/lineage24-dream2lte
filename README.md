# LineageOS 24.0 for the Samsung Galaxy S8+ (Exynos, SM-G955F `dream2lte`)

Unofficial LineageOS 24.0 (Android 17) on the Exynos 8895 Galaxy S8+, running
Samsung's 4.4 kernel with backports. It uses the same device trees, kernel,
vendor blobs and legacy-kernel patches as the
[AOSP 17 port](https://github.com/proshiv85-byte/aosp17-dream2lte); the device
tree and common tree are on their `lineage-24.0` branches.

## Status

Boots and works on an SM-G955F. Hardware support comes from the AOSP 17
port; see its README for the detailed status table. This is a `userdebug`
build: `adb root` works.

## Installing

Download the `-twrp.zip` from
[Releases](https://github.com/proshiv85-byte/lineage24-dream2lte/releases) and
flash it in TWRP (Install). It writes BOOT, SYSTEM and VENDOR and verifies each
one against the checksums in the zip. Your data is not touched:

- Coming from another ROM: after flashing, Wipe → Format Data (type `yes`),
  Wipe → Advanced → Cache, then reboot.
- Updating this ROM: flash, wipe Cache and reboot; apps and data stay.

Requirements:
- SM-G955F with TWRP.
- The Treble partition layout used by HadesROM (`VENDOR` = `sda18`,
  `SYSTEM` = `sda17`). Flashing stock firmware with Odin restores the stock
  layout.
- Back up your EFS partition (IMEI and radio calibration) before switching
  ROMs, and keep that backup private.

### Why not the `m bacon` zip?

`m bacon` builds a standard LineageOS OTA zip, but its `update-binary` is an
Android 17 static binary: its bionic aborts with
`arc4random data MADV_WIPEONFORK failed` on kernels without `MADV_WIPEONFORK`
(Linux 4.14+). The ROM kernel has it backported, but TWRP for this phone runs
an older 4.4 kernel, so the bacon zip fails in TWRP before writing anything.
`twrp/make-twrp-zip.sh` packs the same images with a shell installer and a
static `sparse_write` helper instead.

## Building

Needs a Linux host with about 300 GB free disk and a lot of memory: 32 GB RAM
plus about 36 GB swap was enough.

```sh
git clone https://github.com/proshiv85-byte/lineage24-dream2lte
cd lineage24-dream2lte
mkdir src && cd src
repo init -u https://github.com/LineageOS/android.git -b lineage-24.0 --depth=1
mkdir -p .repo/local_manifests
cp ../local_manifests/dream2lte.xml .repo/local_manifests/
cd ..
./sync.sh                     # repo sync with retries
./apply-patches.sh src
./build-lineage.sh            # m bacon; log in src/out/build-lineage.log
./twrp/make-twrp-zip.sh src release
```

`repo sync` resets the patched projects, so run `apply-patches.sh` again after
every sync. The TWRP zip ends up in `release/`.

## Patches

Changes to LineageOS's own projects are kept in [`patches/`](patches):

- **4.4 kernel support:** BPF loader and netd without BPF ring buffers and
  with the 5.10 requirement relaxed (Connectivity, system/bpf), the fscrypt v1
  session-keyring workaround and libkeyutils for init/vold (system/core,
  system/vold), and an optional BPF program in health (hardware/interfaces).
- **Build:** deduplicated partition file lists and OTA packages for devices
  without a recovery image (`TARGET_NO_RECOVERY` + `TARGET_RECOVERY_FSTAB`)
  in build/make, and a soft memory limit for soong_build in build/blueprint.
- **Features:** a large condensed AOD clock in SystemUI (frameworks/base) and
  a wallpaper blur option (WallpaperPicker2).

## Repositories

| Path | Repo | Branch |
|---|---|---|
| `device/samsung/dream2lte` | [android_device_samsung_dream2lte](https://github.com/proshiv85-byte/android_device_samsung_dream2lte) | `lineage-24.0` |
| `device/samsung/universal8895-common` | [android_device_samsung_universal8895-common](https://github.com/proshiv85-byte/android_device_samsung_universal8895-common) | `lineage-24.0` |
| `device/samsung/dream2lte-kernel` | [android_device_samsung_dream2lte-kernel](https://github.com/proshiv85-byte/android_device_samsung_dream2lte-kernel) | `dream2lte` |
| `device/samsung_slsi/sepolicy` | [android_device_samsung_slsi_sepolicy](https://github.com/proshiv85-byte/android_device_samsung_slsi_sepolicy) | `dream2lte` |
| `hardware/samsung` | [android_hardware_samsung](https://github.com/proshiv85-byte/android_hardware_samsung) | `dream2lte` |
| `hardware/google/pixel` | [android_hardware_google_pixel](https://github.com/proshiv85-byte/android_hardware_google_pixel) | `dream2lte` |
| `hardware/lineage/compat` | [android_hardware_lineage_compat](https://github.com/proshiv85-byte/android_hardware_lineage_compat) | `dream2lte` |
| `vendor/samsung` | [proprietary_vendor_samsung](https://github.com/proshiv85-byte/proprietary_vendor_samsung) | `dream2lte` |
| kernel source | [android_kernel_samsung_universal8895](https://github.com/proshiv85-byte/android_kernel_samsung_universal8895) | `aosp17` |

## Credits

- [LineageOS](https://github.com/LineageOS).
- The [universal8895](https://codeberg.org/universal8895) port (device trees,
  kernel, vendor blobs), including CakesTwix's kernel work.
- Samsung for the kernel source and vendor firmware.
