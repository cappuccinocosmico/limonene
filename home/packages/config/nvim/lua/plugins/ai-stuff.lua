-- every spec file under the "plugins" directory will be loaded automatically by lazy.nvim
--
-- In your plugin files, you can:
-- * add extra plugins
-- * disable/enabled LazyVim plugins
-- * override the configuration of LazyVim plugins
return {
    {
        "yetone/avante.nvim",
        event = "VeryLazy",
        lazy = false,
        version = false, -- set this if you want to always pull the latest change
        opts = {
            provider = "deepinfra",
            vendors = {
                deepinfra = {
                    __inherited_from = "openai",
                    api_key_name = "DEEPINFRA_API_KEY",
                    endpoint = "https://api.deepinfra.com/v1/openai",
                    model = "deepseek-ai/DeepSeek-R1-Turbo",
                    model = "meta-llama/Llama-4-Maverick-17B-128E-Instruct-FP8"
                }
            }
            -- add any opts here
        },
        config = function()
            require("neo-tree").setup(
                {
                    filesystem = {
                        commands = {
                            avante_add_files = function(state)
                                local node = state.tree:get_node()
                                local filepath = node:get_id()
                                local relative_path = require("avante.utils").relative_path(filepath)

                                local sidebar = require("avante").get()

                                local open = sidebar:is_open()
                                -- ensure avante sidebar is open
                                if not open then
                                    require("avante.api").ask()
                                    sidebar = require("avante").get()
                                end

                                sidebar.file_selector:add_selected_file(relative_path)

                                -- remove neo tree buffer
                                if not open then
                                    sidebar.file_selector:remove_selected_file("neo-tree filesystem [1]")
                                end
                            end
                        },
                        window = {
                            mappings = {
                                ["oa"] = "avante_add_files"
                            }
                        }
                    }
                }
            )
        end,
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
                            insert_mode = true
                        },
                        -- required for Windows users
                        use_absolute_path = true
                    }
                }
            }
            -- {
            --   -- Make sure to set this up properly if you have lazy=true
            --   'MeanderingProgrammer/render-markdown.nvim',
            --   opts = {
            --     file_types = { "markdown", "Avante" },
            --   },
            --   ft = { "markdown", "Avante" },
            -- },
        }
    }
}
