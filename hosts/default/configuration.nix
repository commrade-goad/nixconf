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
    hardware.bluetooth.enable = false;
    hardware.bluetooth.powerOnBoot = false;

    security.rtkit.enable = true;
    services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        jack.enable = true;
    };

    zramSwap = {
        enable = true;
        algorithm = "zstd";
        memoryPercent = 50;
    };

    # == Servies (Systemd stuff is here too) == #
    systemd.services.NetworkManager-wait-online.enable = false;
    services.printing.enable = false;
    services.libinput = {
	    enable = true;
	    touchpad = {
		    accelProfile = "flat";
		    accelSpeed = 0.3;
		    tapping = true;
		    naturalScrolling = true;
		    tappingDragLock = false;
	    };
    };
    services.fstrim.enable = true;
    services.blueman.enable = false;
    services.xserver.enable = false;
    services.tlp = {
	    enable = true;
	    settings = {
		    STOP_CHARGE_THRESH_BAT0     = 96;
		    START_CHARGE_THRESH_BAT0    = 95;
		    CPU_SCALING_GOVERNOR_ON_AC  = "performance";
		    CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
	    };
    };
    services.xserver.xkb = {
        layout = "us";
        variant = "";
    };

    # == User use ‘passwd’ to set password == #
    users.users.goad = {
        isNormalUser = true;
        description = "goad";
        extraGroups = [ "networkmanager" "wheel" "input" "video" "audio" ];
    };

    # == For Program and stuff == #
    nixpkgs.config.allowUnfree = true;

    programs.nix-ld.enable = true;
    programs.nix-ld.libraries = with pkgs; [
        stdenv.cc.cc
    ];

    programs.sway = {
	    enable = true;
	    wrapperFeatures.gtk = true;
    };
    programs.firefox.enable = true;
    environment.systemPackages = with pkgs; [
        tmux
        neovim
        wl-clipboard
        fastfetch
        btop
        man-pages
        git
        foot
        # yazi ?? replace with your file manager of chooice later
        mpvScripts.mpris
        (mpv.override { scripts = [ mpvScripts.mpris ]; })
        # pavucontrol ??? use pipemixer
        ripgrep
	wmenu
	swaybg
        dunst
        # copyq ?? replace with heather stuff cclip
        brightnessctl
	swaylock
	swayidle
        # hyprpolkitagent ?? polkit stuff later on
        slurp
        grim
        adwaita-icon-theme
        home-manager
        wayland-pipewire-idle-inhibit
        pamixer
        playerctl
        libnotify
        xdg-user-dirs
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
        nerd-fonts.code-new-roman
    ];

    # == MISC == #
    nix.optimise.automatic = true;
    nix.gc = {
        automatic = true;
        dates = "daily";
        options = "--delete-older-than 3d";
    };
    nix.settings.experimental-features = ["nix-command" "flakes"];
    system.stateVersion = "25.11";
}
