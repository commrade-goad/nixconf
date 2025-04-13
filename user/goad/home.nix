{ config, pkgs, ... }:

{
    home.username = "goad";
    home.homeDirectory = "/home/goad";

    home.stateVersion = "24.11";

    home.packages = [
        # LSP
        pkgs.lua-language-server
        pkgs.clang-tools
        pkgs.rust-analyzer
        pkgs.gopls
        pkgs.pyright

        # Lang
        pkgs.go
        pkgs.rustc
        pkgs.cargo
        pkgs.rustfmt
        pkgs.clippy
        pkgs.nodejs
        pkgs.python313
        pkgs.gcc
        # pkgs.clang

        # DBG
        pkgs.gdb
        pkgs.cgdb

        # MISC PKGS
        pkgs.libsixel
        pkgs.obs-studio
        pkgs.unzip
        pkgs.vesktop
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

    home.sessionVariables = {};

    home.pointerCursor = {
        gtk.enable = true;
        # x11.enable = true;
        package = pkgs.adwaita-icon-theme;
        name = "Adwaita";
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

    gtk.gtk2.configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";

    programs.home-manager.enable = true;
}
