# borochid-corsair-virtuoso

Borochid device packages for the **Corsair Virtuoso** headset family
(Virtuoso SE / XT / RGB Wireless, on the dongle or a USB cable).

As in iCUE, the dongle and the headset are two devices, each with its own
package:

* `corsair.virtuoso`: the headset, on its cable or behind its dongle, with
  its settings. The dongle's driver announces it while it answers.
* `corsair.virtuoso-receiver`: the dongle, whose card says whether the
  headset is connected and shows its firmware. Users who don't need it can
  hide it (card menu → Hide).

This repo is **data only**: the two manifests and the pictures of the
headset (`corsair.virtuoso/images/virtuoso.png`) and the dongle
(`corsair.virtuoso-receiver/images/receiver.png`). It is
published, signed, to the Borochid registry, and the service downloads it when
a matching headset is plugged in. The behaviour comes from the
[`corsair-v2w` driver](../borochid-driver-corsair-v2w), a system package
the GUI offers to install through PackageKit the first time it's needed.

**License:** Apache-2.0, except the pictures of the headset and the dongle,
which are not covered by it. See [NOTICE](NOTICE).

## What's in the headset's manifest

| Section | Purpose |
|---|---|
| `match` | USB IDs: four cabled headsets, and the five dongles with `"paired": true`, which matches the headset the dongle's driver announces, never the dongle itself. |
| `channel` | HID, interface **4 then 3**. Standard models speak V2W on 4, and the Slipstream receiver only offers 3. Trying 3 first on a standard model opens fine, accepts writes and never replies. |
| `driver` | `corsair-v2w`, compatible versions, and the system package that provides it. |
| `audio` | Enables the service's audio service. Names are matched against sound cards and PipeWire nodes, and must stay specific: a loose term like "gaming" once matched a "G560 Gaming Speaker". |
| `v2w` | The model profile: which PIDs are wireless vs wired, LED zones in frame order (logo, battery, mic), and features and their timings. |
| `channel` / `driver` | Used on the cable, where the headset speaks V2W on the dongle's endpoint; behind the dongle it talks through the dongle's channel. |
| `display_name` | Tidies the name the headset reports: `CORSAIR VIRTUOSO SE Wireless Gaming Headset` becomes **Corsair Virtuoso SE**. The model suffix is taken from the reported name, so XT and RGB models need no changes. |
| `category` | `headset`: the GUI's fallback icon when there is no picture. |
| `image` | The picture the GUI shows for the headset. PNG, at most 384×384 and 256 KiB; `make check` enforces it. |
| `battery` | Which driver state holds the battery level and charging flag. The GUI draws the battery icon. No refresh action: the headset reports every change itself. |
| `available` | The headset can be used while `link` is `online` or `wired`, which is whenever its card exists: behind the dongle it goes when it stops answering. |
| `summary` | The one-line status in the device list ("Connected", "USB cable"). |
| `ui` | The control panel the Borochid GUI renders. |

## What's in the receiver's manifest

| Section | Purpose |
|---|---|
| `match` | The five dongles with `"paired": false`, and `0a46`, the dongle while its headset is off (matched with `"channel": null`: recognised, never opened). |
| `driver` | `corsair-v2w-receiver`, from the same system package as the headset's driver. |
| `v2w` | Which PIDs are the dongle linked (`wireless`) or not (`standby`), and the link timings: keep-alive and the offline probe. |
| `category` / `image` | `receiver`, and the dongle's picture (same limits as the headset's). |
| `summary` / `ui` | Whether the headset is connected, and the dongle's firmware. |

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

Add its PIDs to `match` and `v2w.links` in both manifests (the dongle's
PIDs with `"paired"` set in each), adjust zones and features if they
differ, bump `version`, and add the PIDs to the driver's udev rule. Only the
udev rule needs a driver release, because installing device access needs
root.
