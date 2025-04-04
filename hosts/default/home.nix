{ config, pkgs, inputs ? {}, ... }:

{
    home.username = "goad";
    home.homeDirectory = "/home/goad";

    # You should not change this value, even if you update Home Manager. If you do
    # want to update the value, then make sure to first check the Home Manager
    # release notes.
    home.stateVersion = "24.11";

    home.packages = [
        # LSP
        pkgs.lua-language-server
        pkgs.clang-tools
        pkgs.nil
        pkgs.rust-analyzer

        # Lang
        pkgs.go

        pkgs.rustc
        pkgs.cargo
        pkgs.rustfmt
        pkgs.clippy

        # Utils
        inputs.battrem.packages.${pkgs.system}.default

        # (pkgs.writeShellScriptBin "my-hello" ''
        #   echo "Hello, ${config.home.username}!"
        # '')
    ];

    home.file = {
        # # Building this configuration will create a copy of 'dotfiles/screenrc' in
        # # the Nix store. Activating the configuration will then make '~/.screenrc' a
        # # symlink to the Nix store copy.
        # ".screenrc".source = dotfiles/screenrc;

        # # You can also set the file content immediately.
        # ".gradle/gradle.properties".text = ''
        #   org.gradle.console=verbose
        #   org.gradle.daemon.idletimeout=3600000
        # '';
    };

    # Home Manager can also manage your environment variables through
    # 'home.sessionVariables'. These will be explicitly sourced when using a
    # shell provided by Home Manager. If you don't want to manage your shell
    # through Home Manager then you have to manually source 'hm-session-vars.sh'
    # located at either
    #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
    #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
    #  /etc/profiles/per-user/goad/etc/profile.d/hm-session-vars.sh

    home.sessionVariables = {
        # EDITOR = "emacs";
    };

    home.pointerCursor = {
        gtk.enable = true;
        # x11.enable = true;
        package = pkgs.bibata-cursors;
        name = "Bibata-Modern-Classic";
        size = 24;
    };

    gtk = {
        enable = true;
        theme = {
            name = "Everforest-Dark-BL-LB";
        };
        iconTheme = {
            name = "Everforest-Dark";
        };
        font = {
            name = "DejaVu Sans";
            size = 10;
        };
    };

    programs.home-manager.enable = true;
}
