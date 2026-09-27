# borochid-corsair-virtuoso

Borochid device package for the **Corsair Virtuoso** headset family
(Virtuoso SE / XT / RGB Wireless, on the dongle or a USB cable).

This repo is **data only**: `corsair.virtuoso/manifest.json` and the
headset's picture, `corsair.virtuoso/images/virtuoso.png`. It is
published, signed, to the Borochid registry, and the service downloads it when
a matching headset is plugged in. The behaviour comes from the
[`corsair-v2w` driver](../borochid-driver-corsair-v2w), a system package
the GUI offers to install through PackageKit the first time it's needed.

## What's in the manifest

| Section | Purpose |
|---|---|
| `match` | USB IDs: five dongles, four cabled headsets, and `0a46`, the dongle while its headset is switched off (matched with `"channel": null`: recognised, never opened). |
| `channel` | HID, interface **4 then 3**. Standard models speak V2W on 4, and the Slipstream receiver only offers 3. Trying 3 first on a standard model opens fine, accepts writes and never replies. |
| `driver` | `corsair-v2w`, compatible versions, and the system package that provides it. |
| `audio` | Enables the service's audio service. Names are matched against sound cards and PipeWire nodes, and must stay specific: a loose term like "gaming" once matched a "G560 Gaming Speaker". |
| `v2w` | The model profile: which PIDs are wireless vs wired, LED zones in frame order (logo, battery, mic), and features and their timings. |
| `display_name` | Tidies the name the headset reports: `CORSAIR VIRTUOSO SE Wireless Gaming Headset` becomes **Corsair Virtuoso SE**. The model suffix is taken from the reported name, so XT and RGB models need no changes. |
| `category` | `headset`: the GUI's fallback icon when there is no picture. |
| `image` | The picture the GUI shows for the headset. PNG, at most 384×384 and 256 KiB; `make check` enforces it. |
| `battery` | Which driver state holds the battery level and charging flag, and the action behind the refresh button (offered while the headset is online). The GUI draws the battery icon. |
| `available` | The headset can be used while `link` is `online` or `wired`. With the headset off (`standby`) or not answering (`offline`), the GUI fades its picture, hides the battery and disables the settings. |
| `summary` | The one-line status in the device list ("Connected", "Headset off", …). |
| `ui` | The control panel the Borochid GUI renders. |

Every value is validated by `make check`: the Borochid schema plus the
driver's profile validator.

## Working on it

```sh
python3 -m venv --system-site-packages .venv
.venv/bin/pip install -e ../borochid/packages/common -e ../borochid/packages/service -e ../borochid-driver-corsair-v2w
make check
make install-local        # the service now uses this copy, no registry needed
```

## Publishing

```sh
make publish REGISTRY=../registry-out KEY=/path/to/publisher.key
```

The output is signed and ready for any static host. Users trust it by
pinning the publisher's public key in their registry config.

## Adding a model

Add its PIDs to `match` and `v2w.links`, adjust zones and features if they
differ, bump `version`, and add the PIDs to the driver's udev rule. Only the
udev rule needs a driver release, because installing device access needs
root.
