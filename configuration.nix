# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
    imports =
        [ # Include the results of the hardware scan.
            ./hardware-configuration.nix
        ];

    # Bootloader.
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    networking.hostName = "nixos";

    # Configure network proxy if necessary
    # networking.proxy.default = "http://user:password@proxy:port/";
    # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

    environment.variables = {
        EDITOR = "nvim";
        MANPAGER = "nvim +Man!";
    };
    environment.sessionVariables = {
        NIXOS_OZONE_WL = "1";
    };

    # Set your time zone.
    time.timeZone = "Asia/Jakarta";

    # Select internationalisation properties.
    i18n.defaultLocale = "en_US.UTF-8";

    services.xserver.enable = false;

    # Enable the KDE Plasma Desktop Environment.
    services.displayManager.sddm.enable = true;
    services.desktopManager.plasma6.enable = true;

    # Configure keymap in X11
    services.xserver.xkb = {
        layout = "us";
        variant = "";
    };

    # Enable CUPS to print documents.
    services.printing.enable = false;

    # Enable sound with pipewire.
    services.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        jack.enable = true;
    };

    # enable zram
    zramSwap = {
        enable = true;
        algorithm = "zstd";
        memoryPercent = 100;
    };

    # Enable touchpad support (enabled default in most desktopManager).
    services.libinput.enable = true;

    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.users.goad = {
        isNormalUser = true;
        description = "goad";
        shell = pkgs.zsh;
        extraGroups = [ "networkmanager" "wheel" ];
        packages = with pkgs; [
        ];
    };

    # enable zsh
    programs.zsh.enable = true;

    # Allow unfree packages
    nixpkgs.config.allowUnfree = true;

    # List packages installed in system profile. To search, run:
    # $ nix search wget
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
        # pkgs.home-manager
    ];

    # Some programs need SUID wrappers, can be configured further or are
    # started in user sessions.
    # programs.mtr.enable = true;
    # programs.gnupg.agent = {
    #   enable = true;
    #   enableSSHSupport = true;
    # };

    # List services that you want to enable:

    # Enable the OpenSSH daemon.
    # services.openssh.enable = true;

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

    # networking.nameservers = [ "1.1.1.1#one.one.one.one" "1.0.0.1#one.one.one.one" ];
    #
    # services.resolved = {
    #     enable = true;
    #     dnssec = "true";
    #     domains = [ "~." ];
    #     fallbackDns = [ "1.1.1.1#one.one.one.one" "1.0.0.1#one.one.one.one" ];
    #     dnsovertls = "true";
    # };

    # autodelete some old version
    nix.gc.automatic = true;
    nix.gc.dates = "daily";
    nix.gc.options = "--delete-older-than 7d";

    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "25.05"; # Did you read the comment?
}
