{
  description = "Description for the project";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        # To import an internal flake module: ./other.nix
        # To import an external flake module:
        #   1. Add foo to inputs
        #   2. Add foo as a parameter to the outputs function
        #   3. Add here: foo.flakeModule

      ];
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      perSystem =
        {
          config,
          self',
          inputs',
          pkgs,
          system,
          ...
        }:
        {
          # Per-system attributes can be defined here. The self' and inputs'
          # module parameters provide easy access to attributes of the same
          # system.

          # Equivalent to  inputs'.nixpkgs.legacyPackages.hello;
          apps =
            let
              pidFile = ".tufted.pid";
              cleanup = ''
                if [ ! -f ${pidFile} ]; then
                  echo "No development server found."
                  exit 0
                fi

                read -r SERV_PID < ${pidFile}

                kill -9 "$SERV_PID"
                rm ${pidFile}
              '';
              startScript = pkgs.writeShellScriptBin "start-tufted" ''
                set -e
                if [ -f ${pidFile} ]; then
                  echo "Development server already running (PID file ${pidFile} exists)"
                  exit 1
                fi

                echo "Live server at localhost:31415"
                echo "Press Ctrl-C to exit."

                cleanup() {
                  ${cleanup}
                }

                trap cleanup INT

                live-server --port 31415 _site &
                SERV_PID=$!

                echo "$SERV_PID" > ${pidFile}

                find content | entr -r make html
              '';
              stopScript = pkgs.writeShellScriptBin "stop-tufted" ''
                set -e

                ${cleanup}
              '';
            in
            {
              start = {
                type = "app";
                program = "${startScript}/bin/start-tufted";
              };
              stop = {
                type = "app";
                program = "${stopScript}/bin/stop-tufted";
              };
            };
          devShells.default = pkgs.mkShell {
            packages = with pkgs; [
              gnumake
              entr
              live-server
              lolcat
              typst
            ];
            shellHook = ''
              echo 'Use `nix run .#start` to start a live server at localhost:31415' | lolcat
            '';
          };
        };
      flake = {
        # The usual flake attributes can be defined here, including system-
        # agnostic ones like nixosModule and system-enumerating ones, although
        # those are more easily expressed in perSystem.

      };
    };
}
