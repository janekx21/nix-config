# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      <home-manager/nixos>
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Setup keyfile
  boot.initrd.secrets = {
    "/crypto_keyfile.bin" = null;
  };

  # Enable swap on luks
  boot.initrd.luks.devices."luks-04449555-edec-4e30-a429-0a9e65ec0560".device = "/dev/disk/by-uuid/04449555-edec-4e30-a429-0a9e65ec0560";
  boot.initrd.luks.devices."luks-04449555-edec-4e30-a429-0a9e65ec0560".keyFile = "/crypto_keyfile.bin";

  # https://github.com/NixOS/nixpkgs/issues/87802
  boot.kernelParams = ["ipv6.disable=1"];

  networking.hostName = "nixos"; # Define your hostname.
  networking.enableIPv6 = false;
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver = {
    layout = "de";
    xkbVariant = "neo_qwertz";
  };

  # Configure console keymap
  # console.keyMap = "de";
  console.useXkbConfig = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };
  services.intune.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;

  security.sudo.extraRules = [{
    users = [ "janek" ];
    commands = [{
      command = "ALL";
      options = [ "NOPASSWD" ];
    }];
  }];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    helix
    ranger
    lazygit
    lazydocker
    htop
    nettools
    nil
    docker-compose
    openssl
    wl-clipboard
    roboto
    roboto-mono
    ubuntu_font_family
    vistafonts
    nodejs
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget
  ];

  virtualisation.docker = {
    enable = true;
  };
  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = [ "janek" ];
  virtualisation.virtualbox.host.enableExtensionPack = true;

  users.defaultUserShell = pkgs.zsh;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.janek = {
    isNormalUser = true;
    description = "Janek Winkler";
    extraGroups = [ "networkmanager" "wheel" "docker"];
    packages = with pkgs; [
      firefox
      blender
      ungoogled-chromium
      gimp-with-plugins
      inkscape-with-extensions
      keepassxc
      neofetch
      libreoffice
      jetbrains.rider
      jetbrains.webstorm
      obsidian
      kitty-img
      kitty-themes
      zellij
      nerdfonts
      zsh-powerlevel10k
      teams-for-linux
      git
      zellij
      joshuto
      gnome.gnome-boxes
      #teams
    ];
    shell = pkgs.zsh;
  };


  # To protect your nix-shell against garbage collection you also need to add these options to your Nix configuration
  nix.settings = {
    keep-outputs = true;
    keep-derivations = true;
  };
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };
  programs = {
    git = {
      enable = true;
      lfs.enable = true;
      config = {
        user = {
          email = "janek.winkler@bridgefield.de";
          name = "Janek Winkler";
        };
        pull.rebase = false;
      };
    };
  };
  programs.zsh = {
    enable = true;
    autosuggestions.enable = true;
    shellAliases = {
      ll = "ls -l";
      update = "sudo nixos-rebuild switch";
      dc = "docker-compose";
      ld = "lazydocker";
      lg = "lazygit";
    };
  };
  programs.dconf.enable = true;

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.tarball-ttl = 0;

  environment.variables.EDITOR = "hx";
  home-manager.users.janek = {pkgs, ...}: {
    #home.packages = [];
    home.stateVersion = "23.05";

    
    #programs.zsh.enable = true;
    programs.helix = {
      enable = true;
      defaultEditor = true;
      # todo needs nightly defaultEditor = true;
      settings = {
        theme = "base16_transparent";
        editor = {
          lsp.display-messages = true;
          lsp.display-inlay-hints = true;
          auto-save = true;
          auto-format = true;
          cursor-shape = {
            insert = "bar";
            normal = "block";
            select = "block";
          };
          indent-guides = {
            render = true;
            character = "▏";
            skip-levels = 1;
          };
          soft-wrap.enable = true;
        };
        keys.insert = {
          j = { k = "normal_mode"; };
          k = { j = "normal_mode"; };
          # todo
        };
      };

    };
    programs.kitty = {
      enable = true;
      font = {
        size = 15;
        name = "JetBrainsMono Nerd Font";
      };
      shellIntegration.enableZshIntegration = true;
      theme = "Material Dark";
      settings = {
        linux_display_server = "x11";
      };
    };

    programs.zsh = {
          plugins = [{
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
    ];
    };

    programs.zellij = {
      enable = true;
      enableZshIntegration = true;
      # todo
      # settings = {
        
      # };
    };

    programs = {
      direnv.enable = true;
      direnv.enableZshIntegration = true;
      direnv.enableBashIntegration = true;
      direnv.nix-direnv.enable = true;
    };

    #dconf.settings = {
    #    "org/gnome/desktop/input-sources" = {
    #      show-all-sources = true;
    #      sources = [ (mkTuple [ "xkb" "de+neo_qwertz" ]) ];
    #      xkb-options = [ "terminate:ctrl_alt_bksp" ];
    #    };
    #};
  };
}
