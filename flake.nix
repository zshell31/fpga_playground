{
  description = "Flake for icesugar-pro fpga env development";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-22.05";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { 
        inherit system; 
        config = {
          packageOverrides = pkgs: rec {
            sbt = pkgs.sbt.overrideAttrs (old: { # for building vexriscv-smp
              postPatch = ''
                echo -java-home ${pkgs.jre8.home} >>conf/sbtopts
              '';
            });
          };
        };
      };
      icesprog = pkgs.stdenv.mkDerivation (with pkgs; {
        name = "icesprog";

        src = fetchFromGitHub {
          owner = "wuxx";
          repo = "icesugar";
          rev = "86609dd00e5ea17f664cae38ccf29958e85134dc";
          hash = "sha256-VMOaX1IdaSWnOfsGi0Qh+PUp/MygHOm/akchENjwACI=";
        } + "/tools/src";

        nativeBuildInputs = [
          pkg-config
          hidapi
          libusb1
        ];

        installPhase = ''
          mkdir -p $out/bin
          cp icesprog $out/bin
        '';

      });
      ecpdap = pkgs.rustPlatform.buildRustPackage (with pkgs; {
        name = "ecpdap";

        src = fetchFromGitHub {
          owner = "adamgreig";
          repo = "ecpdap";
          rev = "fea3f9315b9740cdac69136fbc85f9cc53146a44";
          hash = "sha256-DVqv2lbwFqwcQ8bdKKlCkf+XClnGkYD/E9FU08iMPN8=";
        };

        cargoHash = "sha256-BUSrI1HiWTId4vV9wh8kEoAYXnqok0RCqxu+6TKWRkk=";

        nativeBuildInputs = [
          pkg-config
          libusb1.dev
        ];

        PKG_CONFIG_PATH = "${libusb1.dev}/lib/pkgconfig";

      });

      shellPackages = with pkgs; [
        yosys
        nextpnr
        verilog
        icestorm
        trellis
        gtkwave
        ninja
        picocom
        parted
        sbt
        dtc
        xdot
      ];

      pythonPackages = with pkgs.python3Packages; [
          python
          venvShellHook
      ];

      riscvPkgs = with pkgs.pkgsCross.riscv64-embedded; [
        buildPackages.gcc
      ];

      localTools = [
        icesprog
        ecpdap
      ];
    in
    rec {
      devShell.${system} = pkgs.mkShell rec {
        venvDir = "./.venv";
        nativeBuildInputs = shellPackages ++ pythonPackages ++ riscvPkgs ++ localTools;

        postVenvCreation = ''
          ./litex_setup.py --dev --init --install
          cd litex && git clone --recursive git@github.com:litex-hub/linux-on-litex-vexriscv.git
          pip install bpython meson
        '';
      };

    };
}
