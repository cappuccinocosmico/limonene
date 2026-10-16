{...}: {
  flake.modules.nixos.gamestream = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.limonene.gamestream;

    # wlroots environment for the headless streaming compositor. These are put
    # directly on the systemd user unit (NOT environment.sessionVariables) so
    # they reach a lingering user manager that never goes through PAM — a
    # lingering session is started by systemd at boot, not by a login, so it
    # does not inherit sessionVariables.
    #
    # The headless backend creates the virtual HEADLESS-1 output; libinput is
    # included so sunshine's uinput keyboard/mouse/gamepad injection is still
    # routed to apps. The DRM backend never starts, so the physical display is
    # left untouched (shows "no signal") — the compositor only renders the
    # virtual output. WLR_LIBINPUT_NO_DEVICES lets the session come up even with
    # nothing plugged in. WLR_DRM_DEVICES pins GL/VAAPI to the dGPU so VAAPI can
    # import sunshine's captured frames without a cross-device copy.
    headlessEnv = {
      WLR_BACKENDS = "headless,libinput";
      WLR_HEADLESS_OUTPUTS = "1";
      WLR_LIBINPUT_NO_DEVICES = "1";
      WLR_DRM_DEVICES = "/dev/dri/renderD128";
      # wlroots' default libseat backend wants an active logind/seatd seat with
      # a VT — which a lingering user service never has, so the compositor dies
      # with "Timeout waiting session to become active". The noop backend skips
      # all seat/VT/DRM-master management (irrelevant when headless) and lets
      # input-device access rely purely on group perms, which is why nicole is
      # in the `input` (read /dev/input) and `uinput` (write /dev/uinput) groups.
      LIBSEAT_BACKEND = "noop";
    };
  in {
    options.limonene.gamestream.headless = {
      enable = lib.mkEnableOption "run a dedicated headless sway compositor as a systemd user service, with a virtual output, for streaming without a physical display";
      mode = lib.mkOption {
        type = lib.types.str;
        # sway's parser requires the Hz suffix ("Invalid mode refresh rate" without it)
        default = "1920x1080@120Hz";
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
          # headless (pinned via WLR_DRM_DEVICES above), so VAAPI can
          # import frames without a cross-device copy. renderD129 is the
          # Raphael iGPU.
          adapter_name = "/dev/dri/renderD128";
        };
      };

      environment.systemPackages = [pkgs.wlr-randr];

      # Loads the uinput module at boot (so udev sees the add event and applies
      # 0660 root:uinput to /dev/uinput) and creates the `uinput` group. Without
      # this the node is left 0600 by the static_node path and sunshine cannot
      # write it, so keyboard/mouse/gamepad injection silently does nothing.
      hardware.uinput.enable = true;

      # video + render: GPU / VAAPI access for the session and for sunshine.
      # uinput: sunshine writes /dev/uinput to inject keyboard/mouse/gamepad.
      # input:  wlroots' libinput backend reads /dev/input to route that
      #         injected input to the focused client.
      # uinput/input are plain group permissions (not logind "uaccess"), so they
      # apply to a seat-less lingering user service, where the uaccess ACL would
      # only ever be granted to an active seat user (e.g. a greeter).
      users.users.nicole.extraGroups = ["video" "render" "uinput" "input"];

      # Dedicated streaming compositor. This replaces greetd autologin: a
      # lingering user service so the session comes up on boot with no display
      # manager and nobody logged in at a TTY. It only needs to *launch* sway —
      # sway's own config has an `exec` line that starts sway-session.target,
      # which pulls in graphical-session.target (via BindsTo) and thereby
      # sunshine + waybar + the rest, exactly as it did under greetd. It must
      # NOT itself be bound to graphical-session.target, which would be circular.
      home-manager.sharedModules = lib.optionals cfg.headless.enable [
        ({config, lib, ...}: {
          wayland.windowManager.sway.config.output.HEADLESS-1.mode = cfg.headless.mode;

          systemd.user.services.sway-headless = {
            Unit = {
              Description = "Headless Sway compositor for Sunshine streaming";
              After = ["graphical-session-pre.target"];
            };
            Service = {
              Type = "simple";
              ExecStart = "${config.wayland.windowManager.sway.package}/bin/sway";
              Restart = "on-failure";
              RestartSec = "1s";
              Environment = lib.mapAttrsToList (k: v: "${k}=${v}") (headlessEnv
                // {
                  XDG_CURRENT_DESKTOP = "sway";
                  XDG_SESSION_TYPE = "wayland";
                });
            };
            # default.target (not graphical-session.target): reached by the
            # lingering user manager at boot, so the compositor is up before
            # anything tries to stream.
            Install.WantedBy = ["default.target"];
          };
        })
      ];
    };
  };
}
