{ inputs, self, ... }: {
  perSystem = { config, system, compiler, lib, ... }:
    let
      # The single GHC the site is built against (ghc912).
      ghcVersion = "ghc9124";

      # Source filter: stop cache/build dirs invalidating the store path.
      src = lib.cleanSourceWith {
        src = self + "/src";
        name = "silky-github-com";
        # filter = path: type:
        #   let base = baseNameOf (toString path); in
        #   !(builtins.elem base [
        #     ".git"
        #     ".direnv"
        #     ".hie"
        #     ".cache"
        #     "dist-newstyle"
        #     "result"
        #   ]) && !(nixpkgs.lib.hasPrefix "result-" base);
      };

      hsLib = prev: prev.haskell.lib.compose;

      overlay = final: prev:
        let
          hl = hsLib prev;
        in
        {
          haskell = prev.haskell // {
            packages = prev.haskell.packages // {
              ${ghcVersion} = prev.haskell.packages.${ghcVersion}.extend
                (hfinal: hprev: {
                  silky-github-com =
                    hfinal.callCabal2nix "silky-github-com" src { };

                  # unicode-data's test suite pins Unicode 15.1.0, but the
                  # GHC here ships Unicode 16.0.0, so the tests fail. The
                  # library itself is fine; skip its checks.
                  unicode-data = hl.dontCheck hprev.unicode-data;

                  # Source git deps, ported from src/stack.yaml. callCabal2nix
                  # reads each fork's own .cabal. doJailbreak relaxes their
                  # stale version bounds so they build against the current
                  # snapshot; dontCheck skips their (unmaintained) test suites.
                  #
                  # silky's hakyll-diagrams provides Hakyll.Web.Diagrams (the
                  # module site.hs imports), replacing the unrelated nixpkgs
                  # package of the same name that exposes Hakyll.Web.Pandoc.Diagrams.
                  hakyll-diagrams = hl.dontCheck (hl.doJailbreak
                    (hfinal.callCabal2nix "hakyll-diagrams"
                      inputs.hakyll-diagrams-src { }));
                  diagrams-pandoc = hl.dontCheck (hl.doJailbreak
                    (hl.overrideCabal
                      (drv: {
                        # pandoc-types 1.23 removed the Null Block constructor
                        # this fork still uses on its error path; map it to an
                        # empty block. replace-fail so a source drift is loud.
                        postPatch = (drv.postPatch or "") + ''
                          substituteInPlace src/Text/Pandoc/Diagrams.hs \
                            --replace-fail "Left _err     -> Null" "Left _err     -> Plain []"
                        '';
                      })
                      (hfinal.callCabal2nix "diagrams-pandoc"
                        inputs.diagrams-pandoc-src { })));
                });
            };
          };
        };

      pkgs = import inputs.nixpkgs {
        inherit system;
        # hakyll-diagrams is flagged broken in nixpkgs but is required by
        # the site (Hakyll.Web.Diagrams), so permit it through.
        config.allowBroken = true;
        overlays = [
          overlay
        ];
      };
    in
    {
      _module.args = {
        inherit pkgs;
        hsPkgs = pkgs.haskell.packages.${ghcVersion};
      };
    };
}

