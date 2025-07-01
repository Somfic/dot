{ config, pkgs, inputs, lib, ... }:

{
  imports =
    [ ./hardware-configuration.nix inputs.home-manager.nixosModules.default ];

  # system packages
  environment.systemPackages = with pkgs; [
    neovim
    wget
    curl
    nixfmt
    nix-output-monitor
  ];

  # user accounts
  users.users.lucas = {
    isNormalUser = true;
    description = "lucas";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    packages = with pkgs; [ ];
    shell = pkgs.nushell;
  };

  # homemanager
  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users.lucas = import ./home.nix;
    sharedModules = [{
      stylix.autoEnable = true;
      stylix.targets.rofi.enable = false;
      stylix.targets.vscode.enable = false;
    }];
  };

  # bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # docker
  virtualisation.docker.enable = true;
  hardware.nvidia-container-toolkit.enable = true;

  # hostname  
  networking.hostName = "nixos";

  programs = {
    hyprland = {
      enable = true;
      package = inputs.hyprland.packages."${pkgs.system}".hyprland;
      # withUWSM = true;
      xwayland.enable = true;
    };
    steam = {
      enable = true;
      gamescopeSession.enable = true;
    };
    gamemode = { enable = true; };
    spicetify =
      let spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.system};
      in {
        enable = true;

        enabledExtensions = with spicePkgs.extensions;
          [
            shuffle # shuffle+ (special characters are sanitized out of extension names)
          ];
        enabledCustomApps = with spicePkgs.apps; [ newReleases ncsVisualizer ];
        enabledSnippets = with spicePkgs.snippets; [ rotatingCoverart pointer ];

        theme = spicePkgs.themes.hazy;
      };
  };

  # networking 
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";
  networking.networkmanager.enable = true;

  # locale
  time.timeZone = "Europe/Amsterdam";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "nl_NL.UTF-8";
    LC_IDENTIFICATION = "nl_NL.UTF-8";
    LC_MEASUREMENT = "nl_NL.UTF-8";
    LC_MONETARY = "nl_NL.UTF-8";
    LC_NAME = "nl_NL.UTF-8";
    LC_NUMERIC = "nl_NL.UTF-8";
    LC_PAPER = "nl_NL.UTF-8";
    LC_TELEPHONE = "nl_NL.UTF-8";
    LC_TIME = "nl_NL.UTF-8";
  };

  # desktop environment
  services.xserver.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  services.xserver.displayManager.gdm.enable = true;
  services.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };
  # services.xserver.libinput.enable = true; # mouse and touchpad support (enabled by default in most desktopManager)

  # printing
  services.printing.enable = true;

  # sound
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # general nixos settings
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = "25.05";

  hardware = {
    graphics.enable = true;
    nvidia = {
      modesetting.enable = true;
      open = false;
    };
    opengl = {
      enable = true;
      driSupport32Bit = true;
    };
  };
  stylix = {
    enable = true;
    image = ./wallpapers/neon1.jpg;
    polarity = "dark";
    opacity = {
      applications = 0.0;
      desktop = 0.5;
      terminal = 0.0;
      popups = 0.0;
    };
    targets = { spicetify.enable = false; };
    cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 24;
    };
    fonts = {
      monospace = {
        package = pkgs.monocraft;
        name = "Monocraft";
      };
      sansSerif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Sans";
      };
      serif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Serif";
      };
    };
  };
}
