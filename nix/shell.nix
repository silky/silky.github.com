{ inputs, ... }:
with inputs; {
  perSystem =
    { lib
    , system
    , pkgs
    , hsPkgs
    , ...
  }:
    {
      devShells.default = hsPkgs.shellFor {
        packages = ps: [ ps.silky-github-com ];
        nativeBuildInputs = with pkgs; [
          cabal-install
        ];
      };
    };
}
