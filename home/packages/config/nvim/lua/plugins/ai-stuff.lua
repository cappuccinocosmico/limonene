-- every spec file under the "plugins" directory will be loaded automatically by lazy.nvim
--
-- In your plugin files, you can:
-- * add extra plugins
-- * disable/enabled LazyVim plugins
-- * override the configuration of LazyVim plugins
--
-- [DEPRECATED] The configuration of `vendors.deepinfra_minimal` should be placed in `providers.deepinfra_minimal`. For detailed migration instructions, please visit: https://github.com/yetone/avante.nvim/wiki/Provider-configuration-migration-guide
return {
  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    lazy = false,
    version = false, -- set this if you want to always pull the latest change
    opts = {
      provider = "deepinfra_reasoning",
      -- cursor_applying_provider = "deepinfra_minimal",
      -- behaviour = {
      --   enable_cursor_planning_mode = true, -- enable cursor planning mode!
      -- },
      providers = {
        oai_best = {
          __inherited_from = "openai",
          api_key_name = "OPENAI_API_KEY",
          model = "o4-mini-2025-04-16",
          extra_request_body = {
            max_completion_tokens = 32768,
          },
        },

        oai_fast = {
          __inherited_from = "openai",
          api_key_name = "OPENAI_API_KEY",
          model = "gpt-4.1-mini-2025-04-14",
          extra_request_body = {
            max_completion_tokens = 32768,
          },
        },
        deepinfra_minimal = {
          __inherited_from = "openai",
          api_key_name = "DEEPINFRA_API_KEY",
          endpoint = "https://api.deepinfra.com/v1/openai",
          model = "meta-llama/Llama-4-Maverick-17B-128E-Instruct-FP8",
          extra_request_body = {
            max_completion_tokens = 32768,
          },
        },
        deepinfra_reasoning = {
          __inherited_from = "openai",
          api_key_name = "DEEPINFRA_API_KEY",
          endpoint = "https://api.deepinfra.com/v1/openai",
          model = "moonshotai/Kimi-K2-Instruct",
        },
        deepinfra_cheap_reasoning = {
          __inherited_from = "openai",
          api_key_name = "DEEPINFRA_API_KEY",
          endpoint = "https://api.deepinfra.com/v1/openai",
          model = "Qwen/Qwen3-32B",
          -- model = "meta-llama/Llama-4-Maverick-17B-128E-Instruct-FP8"
        },
      },
      -- add any opts here
    },
    -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
    build = "make",
    -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "stevearc/dressing.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      --- The below dependencies are optional,
      "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
      "zbirenbaum/copilot.lua", -- for providers='copilot'
      {
        -- support for image pasting
        "HakonHarnes/img-clip.nvim",
        event = "VeryLazy",
        opts = {
          -- recommended settings
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = {
              insert_mode = true,
            },
            -- required for Windows users
            use_absolute_path = true,
          },
        },
      },
      -- {
      --   -- Make sure to set this up properly if you have lazy=true
      --   'MeanderingProgrammer/render-markdown.nvim',
      --   opts = {
      --     file_types = { "markdown", "Avante" },
      --   },
      --   ft = { "markdown", "Avante" },
      -- },
    },
  },
}
