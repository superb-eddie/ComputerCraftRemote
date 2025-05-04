{
  description = "Computer Craft Remote";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    ccemux-launcher-nix = {
      url = "github:superb-eddie/ccemux-launcher-nix/11eed4b442c22f6914fb9135734bcf846e04138c";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

#   TODO: Can we inject the absolute path of the repo into build artifacts? More scripts could live in nix land

  outputs =
    { self
    , nixpkgs
    , flake-utils
    , ccemux-launcher-nix
    ,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        lib = nixpkgs.lib;
        pkgs = nixpkgs.legacyPackages.${system};
        ccemux-launcher = ccemux-launcher-nix.packages.${system}.default;

        ccr = pkgs.buildGoModule {
          pname = "ccr";
          version = "0.0.1";

          subPackages = [ "ccr/cmd/ccr" ];
          src = ./.;

          vendorHash = "sha256-lE7VDVykcp0P0r3xPdplDjppSonFIkl4GQEY0BtBipg=";
#          vendorHash = lib.fakeHash;

          meta = {
            description = "A remote terminal for Computer Craft";
            license = lib.licenses.mit;
          };
        };
      in
      {
        formatter = pkgs.nixfmt-rfc-style;

        packages = {
          default = ccr;
          inherit ccr ccemux-launcher;
        };

        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            nixfmt-rfc-style
            nil
            go
            jre
            ccemux-launcher
          ];
        };
      }
    );
}
