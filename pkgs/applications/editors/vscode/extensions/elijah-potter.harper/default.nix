{
  stdenvNoCC,
  lib,
  vscode-utils,
  vscode-extension-update-script,
  jq,
  harper,
  moreutils,
  ...
}:

vscode-utils.buildVscodeMarketplaceExtension {
  mktplcRef =
    let
      sources = {
        "x86_64-linux" = {
          arch = "linux-x64";
          hash = "sha256-hjpdSmM69kftS8WxAAxODKli0uNJKJg+5nLHD1O7dVY=";
        };
        "aarch64-linux" = {
          arch = "linux-arm64";
          hash = "sha256-+Fy8Zro1Wo1gSBDUmFSazTPLH7LVTjmD98Rv3NQYYUg=";
        };
      };
    in
    {
      name = "harper";
      publisher = "elijah-potter";
      version = harper.version;
    }
    // sources.${stdenvNoCC.hostPlatform.system}
      or (throw "Unsupported system ${stdenvNoCC.hostPlatform.system}");

  nativeBuildInputs = [
    jq
    moreutils
  ];

  postInstall = ''
    cd "$out/$installPrefix"
    jq '.contributes.configuration.properties."harper.path".default = "${lib.getExe harper}"' package.json | sponge package.json

    rm ./bin/harper-ls
  '';
  passthru.updateScript = vscode-extension-update-script { };

  meta = {
    changelog = "https://github.com/Automattic/harper/releases/tag/v${harper.version}";
    description = "The grammar checker for developers as a Visual Studio Code extension";
    downloadPage = "https://marketplace.visualstudio.com/items?itemName=elijah-potter.harper";
    homepage = "https://github.com/automattic/harper";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ MasterEvarior ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
}
