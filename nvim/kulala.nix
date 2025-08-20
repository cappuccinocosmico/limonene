{ pkgs, ... }:
{
  extraPackages = with pkgs; [
    grpcurl
    openssl
    websocat
    jq
  ];

  plugins.kulala = {
    enable = true;
    luaConfig.post = ''
      vim.api.nvim_create_user_command("SendRequest", function()
        require("kulala").run()
      end, {})

      vim.api.nvim_create_user_command("SendAllRequests", function()
        require("kulala").run_all()
      end, {})

      vim.api.nvim_create_user_command("OpenScratchpad", function()
        require("kulala").scratchpad()
      end, {})
    '';
    autoLoad = true;
    settings = {
      contenttypes = {
        "application/json" = {
          formatter = [
            "jq"
            "."
          ];
          ft = "json";
          pathresolver = {
            __raw = "require('kulala.parser.jsonpath').parse";
          };
        };
        "application/xml" = {
          formatter = [
            "xmllint"
            "--format"
            "-"
          ];
          ft = "xml";
          pathresolver = [
            "xmllint"
            "--xpath"
            "{{path}}"
            "-"
          ];
        };
        "text/html" = {
          formatter = [
            "xmllint"
            "--format"
            "--html"
            "-"
          ];
          ft = "html";
          pathresolver = [ ];
        };
      };

      additional_curl_options = { };
      debug = false;
      default_env = "dev";
      default_view = "body";
      environment_scope = "b";
      display_mode = "split";
      split_direction = "vertical";
      icons = {
        inlay = {
          done = "✅";
          error = "❌";
          loading = "⏳";
        };
        lualine = "🐼";
      };
    };
  };
  keymaps = [
    {
      key = "<leader>Rs";
      mode = [
        "n"
        "v"
      ];
      action = "<cmd>SendRequest<CR>";
    }
    {
      key = "<leader>Ra";
      mode = [
        "n"
        "v"
      ];
      action = "<cmd>SendAllRequests<CR>";
    }
    {
      key = "<leader>Rb";
      mode = [
        "n"
        "v"
      ];
      action = "<cmd>OpenScratchpad<CR>";
    }
  ];
}
