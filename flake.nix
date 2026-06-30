{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    import-tree.url = "github:vic/import-tree";
    flake-parts.url = "github:hercules-ci/flake-parts";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    # Source-only git deps, ported from src/stack.yaml's extra-deps.
    # These forks provide the modules the site imports:
    #   hakyll-diagrams -> Hakyll.Web.Diagrams
    #   diagrams-pandoc -> Text.Pandoc.Diagrams
    hakyll-diagrams-src = {
      url = "github:silky/hakyll-diagrams/e9d8e1772c0b96a74114f88853aa37317908e738";
      flake = false;
    };
    diagrams-pandoc-src = {
      url = "github:silky/diagrams-pandoc/8319a349667ff17187a1ace9e66ece00626aa8a0";
      flake = false;
    };
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; }
      {
        systems = [
          "aarch64-darwin"
          "aarch64-linux"
          "x86_64-darwin"
          "x86_64-linux"
        ];

        imports = [
          (inputs.import-tree ./nix)
        ];
      };
}
