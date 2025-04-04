{ config, pkgs, inputs, ... }:

{
    imports =
        [
            ./hardware-configuration.nix
            inputs.home-manager.nixosModules.default
        ];

    # == Bootloader == #
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    # == Networking == #
    networking.hostName = "nixos";
    # Open ports in the firewall.
    # networking.firewall.allowedTCPPorts = [ ... ];
    # networking.firewall.allowedUDPPorts = [ ... ];
    # Or disable the firewall altogether.
    networking.firewall.enable = true;
    networking.networkmanager = {
        enable = true;
        insertNameservers = ["1.1.1.1" "8.8.8.8" "8.8.4.4"];
    };
    networking.networkmanager.dns = "none";
    # networking.proxy.default = "http://user:password@proxy:port/";
    # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

    # == Environment == #
    environment.variables = {
        EDITOR = "nvim";
        MANPAGER = "nvim +Man!";
        QT_QPA_PLATFORMTHEME = "qt6ct";
    };
    environment.sessionVariables = {
        NIXOS_OZONE_WL = "1";
    };

    # == Basic system settings == #
    time.timeZone = "Asia/Jakarta";
    i18n.defaultLocale = "en_US.UTF-8";
    hardware.bluetooth.enable = true;

    security.rtkit.enable = true;
    services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        jack.enable = true;
        configPackages = [
            (pkgs.writeTextDir "share/pipewire/pipewire.conf.d/99-input-denoising.conf" ''
                context.modules = [
                {   name = libpipewire-module-filter-chain
                    args = {
                        node.description =  "RNN Noise Canceling source"
                        media.name =  "RNN Noise Canceling source"
                        filter.graph = {
                            nodes = [
                                {
                                    type = ladspa
                                    name = rnnoise
                                    plugin = ${pkgs.rnnoise-plugin}/lib/ladspa/librnnoise_ladspa.so
                                    label = noise_suppressor_mono
                                    control = {
                                        "VAD Threshold (%)" = 55.0
                                        "VAD Grace Period (ms)" = 500
                                        "Retroactive VAD Grace (ms)" = 0
                                    }
                                }
                            ]
                        }
                        capture.props = {
                            node.name =  "capture.rnnoise_source"
                            node.passive = true
                            audio.rate = 48000
                        }
                        playback.props = {
                            node.name =  "rnnoise_source"
                            media.class = Audio/Source
                            audio.rate = 48000
                        }
                    }
                }
                ]
            '')
        ];
    };

    zramSwap = {
        enable = true;
        algorithm = "zstd";
        memoryPercent = 100;
    };

    # == Servies (Systemd stuff is here too) == #
    systemd.services.NetworkManager-wait-online.enable = false;
    services.xserver.enable = false;
    services.xserver.xkb = {
        layout = "us";
        variant = "";
    };
    services.printing.enable = false;
    services.libinput.enable = true;

    services.udev.extraRules = ''
        ACTION=="add", SUBSYSTEM=="block", KERNEL=="sda", RUN+="${pkgs.hdparm}/bin/hdparm -B 127 -S 41 /dev/sda"
    '';
    powerManagement.resumeCommands = ''
        ${pkgs.hdparm}/bin/hdparm -B 127 -S 41 /dev/sda
    '';

    # services.openssh.enable = true;

    # == User use ‘passwd’ to set password == #
    users.users.goad = {
        isNormalUser = true;
        description = "goad";
        shell = pkgs.zsh;
        extraGroups = [ "networkmanager" "wheel" ];
        packages = with pkgs; [
        ];
    };

    # == Home Manager setup == #
    home-manager = {
        extraSpecialArgs = { inherit inputs; };
        users = {
            "goad" = import ./home.nix;
        };
    };

    # == For Program and stuff == #
    nixpkgs.config.allowUnfree = true;

    programs.nix-ld.enable = true;
    programs.nix-ld.libraries = with pkgs; [
        stdenv.cc.cc
    ];

    programs.zsh.enable = true;
    programs.hyprland.enable = true;
    environment.systemPackages = with pkgs; [
        pkgs.tmux
        pkgs.neovim
        pkgs.wl-clipboard
        pkgs.fastfetch
        pkgs.btop
        pkgs.fzf
        pkgs.zoxide
        pkgs.eza
        pkgs.man-pages
        pkgs.zsh
        pkgs.git
        pkgs.gcc
        pkgs.clang
        pkgs.kitty
        pkgs.yazi
        pkgs.cmake
        pkgs.pkg-config
        pkgs.python313
        pkgs.python313Packages.pip
        pkgs.nodejs
        pkgs.mpv
        pkgs.mpvScripts.mpris
        pkgs.unzip
        pkgs.brave
        pkgs.vesktop
        pkgs.pavucontrol
        pkgs.ripgrep
        pkgs.rnnoise-plugin
        pkgs.rofi-wayland
        pkgs.waybar
        pkgs.swww
        pkgs.zathura
        pkgs.dunst
        pkgs.libsForQt5.qt5ct
        pkgs.kdePackages.qt6ct
        pkgs.copyq
        pkgs.blueman
        pkgs.brightnessctl
        pkgs.gimp
        pkgs.gparted
        pkgs.hdparm
        pkgs.hyprlock
        pkgs.hypridle
        pkgs.libreoffice-qt6-fresh
        pkgs.jre_minimal
        pkgs.networkmanagerapplet
        pkgs.obs-studio
        pkgs.hyprpolkitagent
        pkgs.poppler
        pkgs.qpwgraph
        pkgs.unrar
        pkgs.slurp
        pkgs.grim
        pkgs.adwaita-icon-theme
        pkgs.bibata-cursors
        pkgs.everforest-gtk-theme
        pkgs.home-manager
        pkgs.wl-gammactl
        pkgs.wayland-pipewire-idle-inhibit
        pkgs.pamixer
        pkgs.playerctl
        pkgs.yt-dlp
        pkgs.acpi
        pkgs.libnotify
        pkgs.dbus
    ];

    # Some programs need SUID wrappers, can be configured further or are
    # started in user sessions.
    # programs.mtr.enable = true;
    # programs.gnupg.agent = {
    #   enable = true;
    #   enableSSHSupport = true;
    # };

    # == FONTS == #
    fonts.packages = with pkgs; [
        nerd-fonts.iosevka-term
    ];

    # == MISC == #
    nix.gc.automatic = true;
    nix.gc.dates = "daily";
    nix.gc.options = "--delete-older-than 7d";
    nix.settings.experimental-features = ["nix-command" "flakes"];
    system.stateVersion = "25.05";
}
