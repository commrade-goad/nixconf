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
    boot.kernel.sysctl."kernel.sysrq" = 1;
    boot.kernelPackages = pkgs.linuxPackages_latest;

    # == Networking == #
    networking.hostName = "nixos";
    # Open ports in the firewall.
    # networking.firewall.allowedTCPPorts = [ ... ];
    # networking.firewall.allowedUDPPorts = [ ... ];
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
    hardware.bluetooth.powerOnBoot = true;

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
                                        "VAD Threshold (%)" = 60.0
                                        "VAD Grace Period (ms)" = 300
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
    services.fstrim.enable = true;
    services.blueman.enable = true;
    services.logind = {
        extraConfig = ''
            HandlePowerKey=ignore
        '';
    };

    services.udev.extraRules = ''
        ACTION=="add", SUBSYSTEM=="block", KERNEL=="sda", RUN+="${pkgs.hdparm}/bin/hdparm -B 127 -S 41 /dev/sda"
    '';
    powerManagement.resumeCommands = ''
        ${pkgs.hdparm}/bin/hdparm -B 127 -S 41 /dev/sda
    '';

    # == User use ‘passwd’ to set password == #
    users.users.goad = {
        isNormalUser = true;
        description = "goad";
        extraGroups = [ "networkmanager" "wheel" "input" ];
    };

    # == For Program and stuff == #
    nixpkgs.config.allowUnfree = true;

    programs.nix-ld.enable = true;
    programs.nix-ld.libraries = with pkgs; [
        stdenv.cc.cc
    ];

    programs.firefox.enable = true;
    programs.hyprland.enable = true;
    environment.systemPackages = with pkgs; [
        tmux
        neovim
        wl-clipboard
        fastfetch
        btop
        fzf
        zoxide
        man-pages
        git
        foot
        yazi
        mpvScripts.mpris
        (mpv.override { scripts = [ mpvScripts.mpris ]; })
        pavucontrol
        ripgrep
        rnnoise-plugin
        rofi-wayland
        waybar
        swww
        zathura
        dunst
        libsForQt5.qt5ct
        kdePackages.qt6ct
        copyq
        blueman
        brightnessctl
        hdparm
        hyprlock
        hypridle
        libreoffice-qt6-fresh
        networkmanagerapplet
        hyprpolkitagent
        qpwgraph
        slurp
        grim
        adwaita-icon-theme
        everforest-gtk-theme
        home-manager
        wl-gammactl
        wayland-pipewire-idle-inhibit
        pamixer
        playerctl
        yt-dlp
        acpi
        libnotify
        xdg-user-dirs
        inputs.battrem.packages.${pkgs.system}.default
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
    nix.optimise.automatic = true;
    nix.gc = {
        automatic = true;
        dates = "daily";
        options = "--delete-older-than 3d";
    };
    nix.settings.experimental-features = ["nix-command" "flakes"];
    system.stateVersion = "24.11";
}
