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
    # Shells descend from sshd and tailscaled, which the dev-vms oom-guard
    # feature pins at OOM score -1000 so the VM stays reachable. Reset to 0 so
    # earlyoom and the kernel can still kill what the shell starts. Same as
    # /etc/oom-guard-session.sh, which only zsh and sh/bash source.
    shellInit = ''
      if test -w /proc/self/oom_score_adj
          set -l adj (string trim </proc/self/oom_score_adj)
          if string match -q -- '-*' $adj
              echo 0 >/proc/self/oom_score_adj 2>/dev/null
          end
      end
    '';
    interactiveShellInit = ''
      set -g fish_greeting
    '';
  };

  # Claude Code keeps session scratchpads and task outputs under
  # /tmp/claude-<uid>, which the boot-time /tmp cleanup wipes. Point it at a
  # directory in $HOME; the link is recreated at each login.
  systemd.user.tmpfiles.rules = [
    "L /tmp/claude-1047 - - - - ${config.home.homeDirectory}/claude-1047-preserve"
  ];

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
