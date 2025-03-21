{
  description = "my devenvs modules for my dev setup";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    devenv.url = "github:cachix/devenv";
    devenv.inputs.nixpkgs.follows = "nixpkgs";
    advisory-db = {
      url = "github:rustsec/advisory-db";
      flake = false;
    };
    mkdocs-flake.url = "github:applicative-systems/mkdocs-flake";
    mkdocs-flake.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } (
      { flake-parts-lib, ... }:
      let
        inherit (flake-parts-lib) importApply;
        flakeModules.default = importApply ./flake-module.nix {
          inherit inputs;
        };
      in
      {
        imports = [
          flakeModules.default
          inputs.devenv.flakeModule

          inputs.flake-parts.flakeModules.flakeModules
          inputs.mkdocs-flake.flakeModule
        ];
        systems = [
          "x86_64-linux"
          "x86_64-darwin"
        ];
        perSystem =
          { config, ... }:
          {
            devenv.shells.default = {
              mydevenvs = {
                nix.enable = true;
                nix.flake.enable = true;
                docs = {
                  check = {
                    enable = true;
                    package = config.packages.documentation;
                    docs-builder = config.documentation.mkdocs-package;
                  };
                };
                tools = {
                  mkdocs.enable = true;
                  just = {
                    enable = true;
                    pre-commit.enable = true;
                    check.enable = true;
                  };
                };
              };
            };
            documentation = {
              mkdocs-root = ./.;
              strict = true;
            };
          };
        flake = {
          #flake-parts
          inherit flakeModules;
          flakeModule = flakeModules.default;
          devenv = inputs.devenv.flakeModule;

          #classic module, to import in devenv.shells."yourshell"
          devenvModule = import ./default.nix;

          templates.default = {
            path = ./templates/default;
            description = "myDevenvs template with flake-parts";
          };
          templates.no-comments = {
            path = ./templates/no-comments;
            description = "myDevenvs template with flake-parts but without comments";
          };
        };
      }
    );
}
