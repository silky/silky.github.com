---
title: Installing NixOS with the latest kernel
author: Noon van der Silk
date: 2025-01-07
---

You may find yourself in the following situation:

- You have a new computer,
- It requires the some latest kernel features to work (perhaps for WiFi or
    something else),
- You want to install NixOS,
- And the latest ISO you download doesn't work.

One potential reason for the failure could be that your new computer requires
the latest linux `kernelPackages` in order to work; i.e. something like:

```
boot.kernelPackages = pkgs.linuxPackages_latest;
```

In your `configuration.nix`.

But, not to worry! You can follow the
[documentation](https://nixos.org/manual/nixos/stable/#sec-booting-from-usb)
to build your _own_ ISO image; something like so (with flakes):

```nix
# flake.nix
{
  description = "Custom NixOS installation";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  outputs = { self, nixpkgs }:
  {
    nixosConfigurations = {
      iso = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          { nixpkgs.overlays = overlays; }
          ({ pkgs, modulesPath, ... }:
          {
            imports =
              let cd-drv = "installation-cd-graphical-calamares-gnome";
              in [ "${modulesPath}/installer/cd-dvd/${cd-drv}.nix" ];

            # Use the latest kernel packages!
            boot.kernelPackages = pkgs.linuxPackages_latest;
          })
        ];
      };
    };
  };
}
```

Run like:

```shell
nix build .#nixosConfigurations.iso.config.system.build.isoImage
```

Which will produce an iso file that you can mount something like:

```shell
sudo dd \
  bs=4M \
  conv=fsync \
  oflag=direct \
  status=progress \
  if=./result/iso/the-image-name.iso \
  of=/dev/sda
```

The most important fact here is that you select the _calamares_ variant of the
[installation
iso's](https://github.com/NixOS/nixpkgs/tree/master/nixos/modules/installer/cd-dvd).
[Calamares](https://github.com/calamares/calamares/) is the graphical
installer. (Note: If you wanted the _minimal_ installer, you can actually
download that from the nixos hydra instance directly:
[`nixos.iso_minimal_new_kernel`](https://hydra.nixos.org/job/nixos/trunk-combined/nixos.iso_minimal_new_kernel_no_zfs.x86_64-linux),
but actually this will only get you one step further; which I will elaborate
on momentarily.)

The trouble is that while this will be enough to get the _installer_ to run,
you will not be able to run the resulting installed NixOS! This is because
Calamares writes the final `configuration.nix` of the new system, and it does
not consider (wisely or otherwise) the system state of the _installer_ image
when it does so. ^[Thanks to [ElvishJerricco](https://github.com/ElvishJerricco) for this hint.]

So, the answer, naturally, is fork Calamares and change it the way we want! In
fact, glancing at the [relevant
derivation](https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/installer/cd-dvd/installation-cd-graphical-calamares.nix#L19) we learn that it's [calamares-nixos-extensions](https://github.com/NixOS/calamares-nixos-extensions) that we need to fork.

If we just want to hack our way through, we just make some small changes [to
that code](https://github.com/NixOS/calamares-nixos-extensions/compare/calamares...silky:calamares-nixos-extensions:latest-kernel),
and then adjust our flake file as follows:

``` lang=nix
# flake.nix
{
  description = "Custom NixOS installation";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  outputs = { self, nixpkgs }:

  # Define an overlay to update the `calamares-nixos-extensions` used.
  let overlays = [
        (_: final: {
          calamares-nixos-extensions =
            # Update to use our fork
            final.calamares-nixos-extensions.overrideAttrs (_: _: {
              src = final.fetchFromGitHub {
                owner = "silky";
                repo = "calamares-nixos-extensions";
                rev = "latest-kernel";
                hash = "sha256-PEWH+YpmP4qD7IZJLcD9rYl+GEuHqbS/OQsaNUZYBMg=";
              };
            });
        })
      ];
  in
  {
    nixosConfigurations = {
      iso = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          { nixpkgs.overlays = overlays; }
          ({ pkgs, modulesPath, ... }:
          {
            imports =
              let cd-drv = "installation-cd-graphical-calamares-gnome";
              in [ "${modulesPath}/installer/cd-dvd/${cd-drv}.nix" ];

            # Use the latest kernel packages!
            boot.kernelPackages = pkgs.linuxPackages_latest;
          })
        ];
      };
    };
  };
}
```

And success! This results in an installer that will first of all even run, and
second of all install a NixOS that will _also_ run!

**Update**: Note that, in fact, as I was writing this blog-post, I noticed that
the main repo already includes a [better version of this
fix](https://github.com/NixOS/calamares-nixos-extensions/commit/381e34385106f548568ece2395806a6ab4cf6e5f),
from a few days ago!^[Thanks again to ElvishJerricco!] This is just more validation of one of my nix mantras:
something isn't working? Just wait a few days, probably it will be fixed!

**Trivia**: I had dreams of making this an option you could opt-into in the
installer by editing the calamares script; but in fact this is more
complicated than one might wish; you can get a sense for how annoying this is
by looking at [the patch
required](https://github.com/NixOS/nixpkgs/blob/master/pkgs/tools/misc/calamares/0004-Adds-unfree-qml-to-packagechooserq.patch)
to allow someone to select "unfree" during the installation process.
