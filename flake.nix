{
  description = "Computer Craft Remote";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

#   TODO: Can we inject the absolute path of the repo into build artifacts? More scripts could live in nix land

  outputs =
    { self
    , nixpkgs
    , flake-utils
    ,
    }:
    let
      ccemux-launcher-jar = builtins.fetchurl {
        url = "https://emux.cc/ccemux-launcher.jar";
        sha256 = "65bed2736bfc1bd8b786586d14d76c3772173b461294e6354bc0c140ac0dd3b5";
      };
    in
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        lib = nixpkgs.lib;
        pkgs = nixpkgs.legacyPackages.${system};
        ccemux-launcher = pkgs.writeShellScriptBin "ccemux-launcher" ''
          exec ${pkgs.jre}/bin/java -jar ${ccemux-launcher-jar} "$@"
        '';

        ccr = pkgs.buildGoModule {
          pname = "ccr";
          version = "0.0.1";

          subPackages = [ "ccr/cmd/ccr" ];
          src = ./.;
          vendorHash = "sha256-VZHZtxZTS9wI8ECwsu5ZNe7ZPMDL7sgg91qHgd0czGg=";
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
