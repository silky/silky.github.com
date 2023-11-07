{
  inputs = {
    nixpkgs.url     = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = inputs: with inputs;
  flake-utils.lib.eachDefaultSystem (system:
  let
        deps = [
            pkgs.pkg-config
            pkgs.makeWrapper
            # External C libraries needed by some Haskell packages
            pkgs.zlib
            pkgs.glib
            pkgs.cairo
            pkgs.zlib.dev
            pkgs.pango
            pkgs.pango.dev
          ];

        pkgs = import nixpkgs {
          inherit system;
        };

        hPkgs = pkgs.haskell.packages."ghc902";

        stack-wrapped = pkgs.symlinkJoin {
          name = "stack";
          paths = [ pkgs.stack ];
          buildInputs = deps;
          postBuild = ''
            wrapProgram $out/bin/stack \
              --add-flags "\
                --no-nix \
                --system-ghc \
                --no-install-ghc \
              "
          '';
        };

        myDevTools = ([
          hPkgs.ghc
          stack-wrapped
        ] ++ deps) ;
    in rec {
      devShell = pkgs.mkShell {
        buildInputs = [
          myDevTools
        ];

        # For zlib; see: <https://discourse.nixos.org/t/shared-libraries-error-with-cabal-repl-in-nix-shell/8921/9>
        NIX_PATH = "nixpkgs=" + pkgs.path;
        LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath myDevTools;
      };
    }
  );
}
