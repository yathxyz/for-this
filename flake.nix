{
  description = "VILE: yanni's Emacs config ported to Lem (ncurses frontend)";

  # Lem is not in nixpkgs and ships its own flake. We take it as a pinned
  # input (flake.lock) and re-expose the ncurses build, so there is no need
  # to manually `git clone` Lem into vendor/ before building.
  inputs = {
    lem.url = "github:lem-project/lem";
    nixpkgs.follows = "lem/nixpkgs";
  };

  outputs = { self, lem, nixpkgs }:
    let
      systems = [ "aarch64-darwin" "aarch64-linux" "x86_64-darwin" "x86_64-linux" ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);
    in
    {
      # `nix build` / `nix build .#lem-ncurses` -> the Lem image VILE loads into.
      packages = forAllSystems (system: {
        lem-ncurses = lem.packages.${system}.lem-ncurses;
        default = lem.packages.${system}.lem-ncurses;
      });

      # `nix run` launches Lem; point ~/.config/lem/init.lisp at lem-vile/init.lisp.
      apps = forAllSystems (system:
        let app = {
          type = "app";
          program = "${lem.packages.${system}.lem-ncurses}/bin/lem";
        };
        in {
          lem-ncurses = app;
          default = app;
        });

      # Inherit Lem's dev shell (SBCL + build deps) for hacking on the port.
      devShells = forAllSystems (system: {
        default = lem.devShells.${system}.default;
      });
    };
}
