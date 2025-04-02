# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{ config, pkgs, ... }:

{
    imports =
        [ # Include the results of the hardware scan.
            ./hardware-configuration.nix
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
    services.displayManager.sddm.enable = true;
    services.desktopManager.plasma6.enable = true;
    services.xserver.xkb = {
        layout = "us";
        variant = "";
    };
    services.printing.enable = false;
    services.libinput.enable = true;
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

    # == For Program and stuff == #
    nixpkgs.config.allowUnfree = true;
    programs.zsh.enable = true;
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
        pkgs.clang-tools
        pkgs.kitty
        pkgs.yazi
        pkgs.cmake
        pkgs.pkg-config
        pkgs.python313
        pkgs.python313Packages.pip
        pkgs.nodejs
        pkgs.mpv
        pkgs.unzip
        pkgs.brave
        pkgs.vesktop
        pkgs.pavucontrol
        pkgs.ripgrep
        pkgs.rnnoise-plugin
        # pkgs.home-manager
    ];

    # Some programs need SUID wrappers, can be configured further or are
    # started in user sessions.
    # programs.mtr.enable = true;
    # programs.gnupg.agent = {
    #   enable = true;
    #   enableSSHSupport = true;
    # };

    # == MISC ==
    nix.gc.automatic = true;
    nix.gc.dates = "daily";
    nix.gc.options = "--delete-older-than 7d";
    nix.settings.experimental-features = ["nix-command" "flakes"];
    system.stateVersion = "25.05";
}
