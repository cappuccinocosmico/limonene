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
    if not L or not C or not H then
        return nil
    end
    L = tonumber(L) *  0.01
    C = tonumber(C)
    H = tonumber(H) * 0.0174532925

    local rgb = oklch_to_rgb(L, C, H)

    local function to_hex(c)
        return string.format("%02x", math.floor(c * 255.75))
    end

    return string.format("#%s%s%s", to_hex(rgb.r), to_hex(rgb.g), to_hex(rgb.b))
end
local function oklch_highlighter(_, match)
  local hex_color = oklch_string_to_hex(match)
  if not hex_color then return nil end
  return MiniHipatterns.compute_hex_color_group(hex_color, 'bg')
end
local words = {aqua = '#00FFFF',black = '#000000',blue = '#0000FF',fuchsia = '#FF00FF',gray = '#808080',green = '#008000',lime = '#00FF00',maroon = '#800000',navy = '#000080',olive = '#808000',purple = '#800080',red = '#FF0000',silver = '#C0C0C0',teal = '#008080',white = '#FFFFFF',yellow = '#FFFF00',aliceblue = '#F0F8FF',antiquewhite = '#FAEBD7',aquamarine = '#7FFFD4',azure = '#F0FFFF',beige = '#F5F5DC',bisque = '#FFE4C4',blanchedalmond = '#FFEBCD',blueviolet = '#8A2BE2',brown = '#A52A2A',burlywood = '#DEB887',cadetblue = '#5F9EA0',chartreuse = '#7FFF00',chocolate = '#D2691E',coral = '#FF7F50',cornflowerblue = '#6495ED',cornsilk = '#FFF8DC',crimson = '#DC143C',cyan = '#00FFFF',darkblue = '#00008B',darkcyan = '#008B8B',darkgoldenrod = '#B8860B',darkgray = '#A9A9A9',darkgreen = '#006400',darkkhaki = '#BDB76B',darkmagenta = '#8B008B',darkolivegreen = '#556B2F',darkorange = '#FF8C00',darkorchid = '#9932CC',darkred = '#8B0000',darksalmon = '#E9967A',darkseagreen = '#8FBC8F',darkslateblue = '#483D8B',darkslategray = '#2F4F4F',darkturquoise = '#00CED1',darkviolet = '#9400D3',deeppink = '#FF1493',deepskyblue = '#00BFFF',dimgray = '#696969',dodgerblue = '#1E90FF',firebrick = '#B22222',floralwhite = '#FFFAF0',forestgreen = '#228B22',gainsboro = '#DCDCDC',ghostwhite = '#F8F8FF',gold = '#FFD700',goldenrod = '#DAA520',greenyellow = '#ADFF2F',honeydew = '#F0FFF0',hotpink = '#FF69B4',indianred = '#CD5C5C',indigo = '#4B0082',ivory = '#FFFFF0',khaki = '#F0E68C',lavender = '#E6E6FA',lavenderblush = '#FFF0F5',lawngreen = '#7CFC00',lemonchiffon = '#FFFACD',lightblue = '#ADD8E6',lightcoral = '#F08080',lightcyan = '#E0FFFF',lightgoldenrodyellow = '#FAFAD2',lightgreen = '#90EE90',lightgrey = '#D3D3D3',lightpink = '#FFB6C1',lightsalmon = '#FFA07A',lightseagreen = '#20B2AA',lightskyblue = '#87CEFA',lightslategray = '#778899',lightsteelblue = '#B0C4DE',lightyellow = '#FFFFE0',limegreen = '#32CD32',linen = '#FAF0E6',magenta = '#FF00FF',mediumaquamarine = '#66CDAA',mediumblue = '#0000CD',mediumorchid = '#BA55D3',mediumpurple = '#9370DB',mediumseagreen = '#3CB371',mediumslateblue = '#7B68EE',mediumspringgreen = '#00FA9A',mediumturquoise = '#48D1CC',mediumvioletred = '#C71585',midnightblue = '#191970',mintcream = '#F5FFFA',mistyrose = '#FFE4E1',moccasin = '#FFE4B5',navajowhite = '#FFDEAD',navyblue = '#9FAFDF',oldlace = '#FDF5E6',olivedrab = '#6B8E23',orange = '#FFA500',orangered = '#FF4500',orchid = '#DA70D6',palegoldenrod = '#EEE8AA',palegreen = '#98FB98',paleturquoise = '#AFEEEE',palevioletred = '#DB7093',papayawhip = '#FFEFD5',peachpuff = '#FFDAB9',peru = '#CD853F',pink = '#FFC0CB',plum = '#DDA0DD',powderblue = '#B0E0E6',rosybrown = '#BC8F8F',royalblue = '#4169E1',saddlebrown = '#8B4513',salmon = '#FA8072',sandybrown = '#FA8072',seagreen = '#2E8B57',seashell = '#FFF5EE',sienna = '#A0522D',skyblue = '#87CEEB',slateblue = '#6A5ACD',slategray = '#708090',snow = '#FFFAFA',springgreen = '#00FF7F',steelblue = '#4682B4',tan = '#D2B48C',thistle = '#D8BFD8',tomato = '#FF6347',turquoise = '#40E0D0',violet = '#EE82EE',wheat = '#F5DEB3',whitesmoke = '#F5F5F5',yellowgreen = '#9ACD32',
}
local word_color_group = function(_, match)
  local hex = words[match]
  if hex == nil then return nil end
  return MiniHipatterns.compute_hex_color_group(hex, 'bg')
end
local function test_oklch_to_hex()
    local tests = {
        {oklch = "oklch(0% 0 0)", expected_hex = "#000000"},
        {oklch = "oklch(100% 0 0)", expected_hex = "#ffffff"},
        {oklch = "oklch(62.8% 0.25768330773615683 29.2338851923426)", expected_hex = "#ff0000"},
        {oklch = "oklch(86.64% 0.2947552610302938 142.49533888780996)", expected_hex = "#00ff00"},
        {oklch = "oklch(45.2% 0.3131362576587438 264.05300810418345)", expected_hex = "#0000ff"},
        {oklch = "oklch(96.8% 0.21095439261133309 109.76923207652135)", expected_hex = "#ffff00"},
        {oklch = "oklch(70.17% 0.322 328.36)", expected_hex = "#ff00ff"},
        {oklch = "oklch(90.54% 0.154 194.77)", expected_hex = "#00ffff"},
        {oklch = "oklch(82.65% 0.104 192.71)", expected_hex = "#6adcd8"},
        {oklch = "oklch(53.33% 0.104 290.12)", expected_hex = "#6c61a5"},
        {oklch = "oklch(36% 0.099 331.41)", expected_hex = "#592654"},
        {oklch = "oklch(75.33% 0.099 80.47)", expected_hex = "#d0a863"}
    }

    for _, test in ipairs(tests) do
        print("Testing oklch to hex for: " .. test.oklch)
        local result_hex = oklch_string_to_hex(test.oklch)
        assert(result_hex == test.expected_hex, string.format("Expected %s but got %s for %s", test.expected_hex, result_hex, test.oklch))
    end
    print("All tests passed!")
end


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
            pattern = "oklch%([^%n%)]+%)",
            group = oklch_highlighter,
          },
          -- Worried about the performance here
          -- word_color = { pattern = '%S+', group = word_color_group },
          -- hex_color = hi.gen_highlighter.hex_color({ priority = 2000 }),
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
