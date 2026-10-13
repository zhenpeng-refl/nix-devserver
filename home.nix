{ config, pkgs, ... }:

{
  home.username = "zhenpeng";
  home.homeDirectory = "/home/zhenpeng";
  home.stateVersion = "25.05";

  # `uv tool install` puts binaries (e.g. keyring, which uv shells out to for
  # Artifact Registry auth) here; fish does not add it on its own.
  home.sessionPath = [ "$HOME/.local/bin" ];

  # Needed on non-NixOS so nix-installed apps integrate properly.
  targets.genericLinux.enable = true;

  home.packages = with pkgs; [
    uv
    gh
    claude-code
    codex
    herdr
    (writeShellScriptBin "vim" ''exec nvim "$@"'')
  ];

  programs.fish = {
    enable = true;
    shellAliases = {
      glogin = "gcloud auth login --update-adc --quiet";
    };
    interactiveShellInit = ''
      set -g fish_greeting
    '';
  };

  xdg.configFile."herdr/config.toml".text = ''
    onboarding = false

    [theme]
    name = "gruvbox-light"
  '';

  programs.git = {
    enable = true;
    settings.user = {
      name = "zhenpeng-refl";
      email = "zhenpeng@reflection.ai";
    };
  };

  # NvChad ships its own wrapped nvim, so programs.neovim must stay disabled.
  # ~/.config/nvim is re-copied from the nix store on every switch; customize
  # through chadrcConfig / extraPlugins / extraConfig here, not in that dir.
  programs.nvchad = {
    enable = true;
    backup = false;
  };

  # The dev-VM mise config (overwritten by `nephos up`) also pins these;
  # skip them in mise so the nix-installed versions win on PATH.
  home.sessionVariables.MISE_DISABLE_TOOLS = "npm:@anthropic-ai/claude-code";

  home.sessionVariables.REFLECTION_USERNAME = "zhenpeng-refl";

  home.sessionVariables.DD_SITE = "us5.datadoghq.com";

  programs.mise = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.home-manager.enable = true;
}
