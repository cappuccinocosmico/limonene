{...}: {
  flake.modules.nixos.gamestream = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.limonene.gamestream;
  in {
    options.limonene.gamestream.headless = {
      enable = lib.mkEnableOption "run the sway session on a headless wlroots backend with a virtual output, for streaming without a physical display";
      mode = lib.mkOption {
        type = lib.types.str;
        default = "1920x1080@120";
        description = "Resolution and refresh rate of the virtual HEADLESS-1 output (headless backend accepts arbitrary modes)";
      };
    };

    config = {
      services.sunshine = {
        enable = true;
        autoStart = true;
        # kms capture needs capSysAdmin; wlr-screencopy (the only method
        # that can see a headless output — kms has no DRM connector) does not.
        capSysAdmin = !cfg.headless.enable;
        openFirewall = true;
        settings = {
          capture =
            if cfg.headless.enable
            then "wlr"
            else "kms";
          encoder = "vaapi";
          # Navi 33 (renderD128) — same GPU the session renders on when
          # headless (pinned via WLR_DRM_DEVICES below), so VAAPI can
          # import frames without a cross-device copy. renderD129 is the
          # Raphael iGPU.
          adapter_name = "/dev/dri/renderD128";
        };
      };

      environment.systemPackages = [pkgs.wlr-randr];

      users.users.nicole.extraGroups = ["video" "render"];

      # Headless session: wlroots runs the headless backend (virtual
      # HEADLESS-1 output at cfg.mode) plus libinput so sunshine's uinput
      # keyboard/mouse/gamepad injection still reaches apps. The DRM
      # backend never starts, so the physical display is left untouched
      # (shows "no signal") — the compositor only renders the virtual
      # output. WLR_LIBINPUT_NO_DEVICES lets the session come up even with
      # nothing plugged in; WLR_DRM_DEVICES pins GL/VAAPI to the dGPU.
      environment.sessionVariables = lib.mkIf cfg.headless.enable {
        WLR_BACKENDS = "headless,libinput";
        WLR_HEADLESS_OUTPUTS = "1";
        WLR_LIBINPUT_NO_DEVICES = "1";
        WLR_DRM_DEVICES = "/dev/dri/renderD128";
      };

      home-manager.sharedModules = lib.optionals cfg.headless.enable [
        {
          wayland.windowManager.sway.config.output.HEADLESS-1.mode = cfg.headless.mode;
        }
      ];
    };
  };
}
