{
  description = "VILE: yanni's Lem editor configuration";

  inputs = {
    lem.url = "github:lem-project/lem";
    nixpkgs.follows = "lem/nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      lem,
    }:
    let
      inherit (nixpkgs) lib;
      systems = [ "x86_64-linux" ];
      forAllSystems = lib.genAttrs systems;
      perSystem =
        system:
        let
          pkgs = import nixpkgs { inherit system; };
          lemNcurses = lem.packages.${system}.lem-ncurses;

          coreRuntimeInputs =
            with pkgs;
            [
              coreutils
              curl
              fd
              gitMinimal
              gnugrep
              gnused
              ripgrep
            ]
            ++ lib.optionals pkgs.stdenv.isLinux [ xdg-utils ];

          extendedRuntimeInputs =
            with pkgs;
            coreRuntimeInputs
            ++ [
              harper
              isync
              jujutsu
              nixd
              notmuch
              postgresql
              pyright
              rust-analyzer
            ];

          testInputs =
            with pkgs;
            [
              bash
              findutils
              tmux
            ]
            ++ coreRuntimeInputs;

          mkApp = program: description: {
            type = "app";
            inherit program;
            meta.description = description;
          };

          vile = pkgs.writeShellApplication {
            name = "vile";
            runtimeInputs = coreRuntimeInputs;
            text = ''
              cache_home="''${XDG_CACHE_HOME:-''${HOME:-/tmp}/.cache}"
              asdf_cache="$cache_home/vile/asdf"
              mkdir -p "$asdf_cache"

              export ASDF_OUTPUT_TRANSLATIONS="${self}/lem-vile:$asdf_cache:/nix/store:/nix/store''${ASDF_OUTPUT_TRANSLATIONS:+:$ASDF_OUTPUT_TRANSLATIONS}"
              exec ${lemNcurses}/bin/lem -q --eval '(load #P"${self}/lem-vile/init.lisp")' "$@"
            '';
          };

          mkTestApp =
            name: script:
            let
              runner = pkgs.writeShellApplication {
                inherit name;
                runtimeInputs = [ lemNcurses ] ++ testInputs;
                text = ''
                  export TERM=''${TERM:-xterm-256color}
                  export LEM_BIN=${lemNcurses}/bin/lem
                  export VILE_SOURCE=${self}/lem-vile
                  exec bash ${self}/scripts/${script} "$@"
                '';
              };
            in
            mkApp "${runner}/bin/${name}" "Run ${script} with flake-pinned Lem";

          mkCheck =
            name: script:
            pkgs.runCommand "vile-${name}-check"
              {
                nativeBuildInputs = [ lemNcurses ] ++ testInputs;
              }
              ''
                export TERM=xterm-256color
                export HOME=$TMPDIR/home
                export XDG_CACHE_HOME=$TMPDIR/cache
                export LEM_BIN=${lemNcurses}/bin/lem
                export VILE_CHECK_ID=nix-${name}

                mkdir -p "$HOME" "$XDG_CACHE_HOME"
                cp -R ${self} source
                chmod -R u+w source
                cd source

                bash ./scripts/${script}
                touch "$out"
              '';
        in
        rec {
          packages = {
            default = vile;
            inherit vile;
            lem-ncurses = lemNcurses;
          };

          apps = {
            default = mkApp "${vile}/bin/vile" "Run VILE on Lem ncurses";
            vile = apps.default;
            lem = mkApp "${lemNcurses}/bin/lem" "Run upstream Lem ncurses";
            compile-check = mkTestApp "vile-compile-check" "compile-check.sh";
            boot-test = mkTestApp "vile-boot-test" "boot-test.sh";
            orderless-test = mkTestApp "vile-orderless-test" "orderless-test.sh";
            interactive-test = mkTestApp "vile-interactive-test" "interactive-test.sh";
          };

          checks = {
            package = vile;
            compile = mkCheck "compile" "compile-check.sh";
            boot = mkCheck "boot" "boot-test.sh";
          };

          devShells.default = pkgs.mkShell {
            packages = [ lemNcurses ] ++ extendedRuntimeInputs ++ testInputs ++ [ pkgs.nixfmt-rfc-style ];
            shellHook = ''
              export LEM_BIN=${lemNcurses}/bin/lem
              export VILE_SOURCE=$PWD/lem-vile
            '';
          };

          formatter = pkgs.nixfmt-rfc-style;
        };

      all = forAllSystems perSystem;
    in
    {
      packages = lib.mapAttrs (_: value: value.packages) all;
      apps = lib.mapAttrs (_: value: value.apps) all;
      checks = lib.mapAttrs (_: value: value.checks) all;
      devShells = lib.mapAttrs (_: value: value.devShells) all;
      formatter = lib.mapAttrs (_: value: value.formatter) all;
    };
}
