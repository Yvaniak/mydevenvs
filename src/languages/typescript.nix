{
  pkgs,
  config,
  lib,
  ...
}:
{
  options = {
    mydevenvs.ts = {
      enable = lib.mkEnableOption "enable ts devenv";
      prettier.enable = lib.mkEnableOption "enable prettier hook";
      biome.enable = lib.mkEnableOption "enable biome hook";
      tests.enable = lib.mkEnableOption "enable tests with jest";
      script-lint.enable = lib.mkEnableOption "run npm lint as a hook";
    };
  };

  config = lib.mkIf config.mydevenvs.ts.enable {
    mydevenvs.ts = {
      biome.enable = lib.mkDefault true;
      script-lint.enable = lib.mkDefault true;
    };

    mydevenvs.tools.just = {
      just-test = lib.mkIf config.mydevenvs.global.enterTest.enable (
        lib.mkIf config.mydevenvs.ts.tests.enable "  jest"
      );
      just-build-release = lib.mkIf config.mydevenvs.global.scripts.enable "  npm run build";
      just-run = lib.mkIf config.mydevenvs.global.scripts.enable "  npm start";
      just-upgrade-check = lib.mkIf config.mydevenvs.global.scripts.enable "  npm outdated";
      just-upgrade = lib.mkIf config.mydevenvs.global.scripts.enable "  npm upgrade";
    };

    languages = lib.mkIf config.mydevenvs.global.languages.enable {
      javascript = {
        enable = true;
        npm.enable = true;
        npm.install.enable = true;
        package = pkgs.nodejs_latest;
      };
      typescript.enable = true;
    };

    git-hooks.hooks = lib.mkIf config.mydevenvs.global.hooks.enable {
      eslint.enable = true;
      biome.${if config.mydevenvs.ts.biome.enable then "enable" else null} = true;
      prettier.${if config.mydevenvs.ts.prettier.enable then "enable" else null} = true;
      ${if config.mydevenvs.ts.script-lint.enable then "script-lint" else null} = {
        enable = true;
        entry = "npm run lint";
        files = "\\.((js)|(ts))";
        pass_filenames = false;
      };
    };

    packages = lib.mkIf config.mydevenvs.ts.biome.enable [
      pkgs.biome
    ];
  };
}
