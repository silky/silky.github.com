{ inputs, ... }:
{
  imports = [ inputs.treefmt-nix.flakeModule ];
  perSystem =
    { pkgs, lib, ... }:
    {
      treefmt = {
        programs.gofmt.enable = true;
        # Haskell
        programs.stylish-haskell.enable = true;
      };
    };
}

