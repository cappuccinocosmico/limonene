-- Test the corners of the RGB Cube
-- #000000
-- oklch(0% 0 0)
-- #ffffff
-- oklch(100% 0 0)
-- #ff0000
-- oklch(62.8% 0.25768330773615683 29.2338851923426)
-- #00ff00 
-- oklch(86.64% 0.2947552610302938 142.49533888780996)
-- #0000ff
-- oklch(45.2% 0.3131362576587438 264.05300810418345)
-- #ffff00
-- oklch(96.8% 0.21095439261133309 109.76923207652135)
-- #ff00ff
-- oklch(70.17% 0.322 328.36)
-- #00ffff
-- oklch(90.54% 0.154 194.77)
local function oklch_to_rgb(L, C, H)
    -- Convert LCH to Lab
    local a = C * math.cos(H)
    local b = C * math.sin(H)
    local Lab = {L = L, a = a, b = b}

    -- Convert Lab to linear sRGB
    local l_ = Lab.L + 0.3963377774 * Lab.a + 0.2158037573 * Lab.b
    local m_ = Lab.L - 0.1055613458 * Lab.a - 0.0638541728 * Lab.b
    local s_ = Lab.L - 0.0894841775 * Lab.a - 1.291485548 * Lab.b

    local l = l_ * l_ * l_
    local m = m_ * m_ * m_
    local s = s_ * s_ * s_

    local r = 4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s
    local g = -1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s
    local b = -0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * s

    -- Apply gamma correction
    local function linear_to_srgb(c)
        if c >= 1 then
          return 1
        end
        if c <= 0 then 
          return 0
        end
        if c <= 0.0031308 then
            return 12.92 * c
        else
            return 1.055 * (c ^ (1 / 2.4)) - 0.055
        end
    end

    return {
        r = linear_to_srgb(r),
        g = linear_to_srgb(g),
        b = linear_to_srgb(b)
    }
end
local function oklch_string_to_hex(oklch_str)
    local L, C, H = oklch_str:match("oklch%(([%d%.]+)%% ([%d%.]+) ([%d%.]+)%)")
    L = tonumber(L) *  0.01
    C = tonumber(C)
    H = tonumber(H) * 0.0174532925

    local rgb = oklch_to_rgb(L, C, H)

    local function to_hex(c)
        return string.format("%02x", math.floor(c * 255 + 0.5))
    end

    return string.format("#%s%s%s", to_hex(rgb.r), to_hex(rgb.g), to_hex(rgb.b))
end
-- local function test_oklch_to_hex()
--     local tests = {
--         {oklch = "oklch(0% 0 0)", expected_hex = "#000000"},
--         {oklch = "oklch(100% 0 0)", expected_hex = "#ffffff"},
--         {oklch = "oklch(62.8% 0.25768330773615683 29.2338851923426)", expected_hex = "#ff0000"},
--         {oklch = "oklch(86.64% 0.2947552610302938 142.49533888780996)", expected_hex = "#00ff00"},
--         {oklch = "oklch(45.2% 0.3131362576587438 264.05300810418345)", expected_hex = "#0000ff"},
--         {oklch = "oklch(96.8% 0.21095439261133309 109.76923207652135)", expected_hex = "#ffff00"},
--         {oklch = "oklch(70.17% 0.322 328.36)", expected_hex = "#ff00ff"},
--         {oklch = "oklch(90.54% 0.154 194.77)", expected_hex = "#00ffff"}
--     }
--
--     for _, test in ipairs(tests) do
--         print("Testing oklch to hex for: " .. test.oklch)
--         local result_hex = oklch_string_to_hex(test.oklch)
--         assert(result_hex == test.expected_hex, string.format("Expected %s but got %s for %s", test.expected_hex, result_hex, test.oklch))
--     end
--     print("All tests passed!")
-- end


return {
  {
    "echasnovski/mini.hipatterns",
    recommended = true,
    desc = "Highlight colors in your code. Also includes Tailwind CSS support.",
    event = "LazyFile",
    opts = function()
      local hi = require("mini.hipatterns")
      return {
        highlighters = {
          oklch_color = {
            pattern = "oklch%((.-)%)",
            group = function(match)
              ---@type string
              local hex_color = oklch_string_to_hex(match)
              return MiniHipatterns.compute_hex_color_group(hex_color, "bg")
            end,
            extmark_opts = { priority = 2000 },
          },
          hex_color = hi.gen_highlighter.hex_color({ priority = 2000 })
          -- shorthand = {
          --   pattern = "()#%x%x%x()%f[^%x%w]",
          --   group = function(_, _, data)
          --     ---@type string
          --     local match = data.full_match
          --     local r, g, b = match:sub(2, 2), match:sub(3, 3), match:sub(4, 4)
          --     local hex_color = "#" .. r .. r .. g .. g .. b .. b
          --
          --     return MiniHipatterns.compute_hex_color_group(hex_color, "bg")
          --   end,
          --   extmark_opts = { priority = 2000 },
          -- },
        },
        -- custom LazyVim option to enable the tailwind integration
        tailwind = {
          enabled = true,
          ft = {
            "astro",
            "css",
            "heex",
            "html",
            "html-eex",
            "javascript",
            "javascriptreact",
            "rust",
            "svelte",
            "typescript",
            "typescriptreact",
            "vue",
          },
          -- full: the whole css class will be highlighted
          -- compact: only the color will be highlighted
          style = "full",
        },
      }
    end,
    config = function(_, opts)
      if type(opts.tailwind) == "table" and opts.tailwind.enabled then
        -- reset hl groups when colorscheme changes
        vim.api.nvim_create_autocmd("ColorScheme", {
          callback = function()
            M.hl = {}
          end,
        })
        opts.highlighters.tailwind = {
          pattern = function()
            if not vim.tbl_contains(opts.tailwind.ft, vim.bo.filetype) then
              return
            end
            if opts.tailwind.style == "full" then
              return "%f[%w:-]()[%w:-]+%-[a-z%-]+%-%d+()%f[^%w:-]"
            elseif opts.tailwind.style == "compact" then
              return "%f[%w:-][%w:-]+%-()[a-z%-]+%-%d+()%f[^%w:-]"
            end
          end,
          group = function(_, _, m)
            ---@type string
            local match = m.full_match
            ---@type string, number
            local color, shade = match:match("[%w-]+%-([a-z%-]+)%-(%d+)")
            shade = tonumber(shade)
            local bg = vim.tbl_get(M.colors, color, shade)
            if bg then
              local hl = "MiniHipatternsTailwind" .. color .. shade
              if not M.hl[hl] then
                M.hl[hl] = true
                local bg_shade = shade == 500 and 950 or shade < 500 and 900 or 100
                local fg = vim.tbl_get(M.colors, color, bg_shade)
                vim.api.nvim_set_hl(0, hl, { bg = "#" .. bg, fg = "#" .. fg })
              end
              return hl
            end
          end,
          extmark_opts = { priority = 2000 },
        }
      end
      require("mini.hipatterns").setup(opts)
    end,
  },
  {
    'cameron-wags/rainbow_csv.nvim',
    config = true,
    ft = {
        'csv',
        'tsv',
        'csv_semicolon',
        'csv_whitespace',
        'csv_pipe',
        'rfc_csv',
        'rfc_semicolon'
    },
    cmd = {
        'RainbowDelim',
        'RainbowDelimSimple',
        'RainbowDelimQuoted',
        'RainbowMultiDelim'
    }
  },
}
