-- every spec file under the "plugins" directory will be loaded automatically by lazy.nvim
--
-- Lab linear_srgb_to_oklab(RGB c) 
-- {
--     float l = 0.4122214708f * c.r + 0.5363325363f * c.g + 0.0514459929f * c.b;
-- 	float m = 0.2119034982f * c.r + 0.6806995451f * c.g + 0.1073969566f * c.b;
-- 	float s = 0.0883024619f * c.r + 0.2817188376f * c.g + 0.6299787005f * c.b;
-- 
--     float l_ = cbrtf(l);
--     float m_ = cbrtf(m);
--     float s_ = cbrtf(s);
-- 
--     return {
--         0.2104542553f*l_ + 0.7936177850f*m_ - 0.0040720468f*s_,
--         1.9779984951f*l_ - 2.4285922050f*m_ + 0.4505937099f*s_,
--         0.0259040371f*l_ + 0.7827717662f*m_ - 0.8086757660f*s_,
--     };
-- }
-- In your plugin files, you can:
-- * add extra plugins
-- * disable/enabled LazyVim plugins
-- * override the configuration of LazyVim pluginsstruct Lab {float L; float a; float b;};
-- struct Lab {float L; float a; float b;};
-- struct RGB {float r; float g; float b;};
-- 
-- RGB oklab_to_linear_srgb(Lab c) 
-- {
--     float l_ = c.L + 0.3963377774f * c.a + 0.2158037573f * c.b;
--     float m_ = c.L - 0.1055613458f * c.a - 0.0638541728f * c.b;
--     float s_ = c.L - 0.0894841775f * c.a - 1.2914855480f * c.b;
-- 
--     float l = l_*l_*l_;
--     float m = m_*m_*m_;
--     float s = s_*s_*s_;
-- 
--     return {
-- 		+4.0767416621f * l - 3.3077115913f * m + 0.2309699292f * s,
-- 		-1.2684380046f * l + 2.6097574011f * m - 0.3413193965f * s,
-- 		-0.0041960863f * l - 0.7034186147f * m + 1.7076147010f * s,
--     };
-- }
-- 
-- CIELAB color spaces
-- 
-- The CIELAB (or CIELab) color space, also referred to as L*a*b* (or Lab* for short), represents the entire range of color that humans can see. This color space was defined by International Commission on Illumination (CIE). It expresses color as three values: L* for perceptual lightness, and a* and b* for the four unique colors of human vision: red, green, blue, and yellow.
-- 
-- Lab is a rectangular coordinate system, with a central lightness L axis. Positive values along the a axis are a purplish red while negative values are the complement: green. Positive values along the b axis are yellow and negative are blue/violet. Desaturated colors have small values for a and b with greater absolute values being more saturated.
-- 
-- CIELab color functions include lab() (lightness, a-axis, b-axis) and lch() (lightness, chroma, hue) as well as oklab() and oklch(). The lightness values are the same, but lch() and oklch are polar, cylindrical coordinate systems, that use polar coordinates C (chroma) and H (hue) rather than axes.
-- 
-- Note: The hue and lightness in lch() and oklch are different from the same-named values in hsl() or other sRGB color spaces.
-- 
-- CIELab color spaces, including Lab, Lch, Oklab, and Oklch, are device-independent color spaces.
-- 
-- lab-d50 color space
-- 
--     Expresses color as L in a range from 0 to 100, and a and b with a range from -125 to 125. The a and b axes are not bound by these range values, which are references in defining percentage inputs and outputs in relation to the Display P3 color space. The whitepoint is D50.
-- lab-d65 color space
-- 
--     This color space is the same as lab-d50, except that the whitepoint is D65.
-- oklab color space
-- 
--     Similar to lab-d65, but the range for L is 0 to 1, and a and b range from -0.4 to 0.4.
-- 
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
return {
  {
    "echasnovski/mini.hipatterns",
    recommended = true,
    desc = "Highlight colors in your code. Also includes Tailwind CSS support.",
    event = "LazyFile",
    opts = function()
      local hi = require("mini.hipatterns")
      return {
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
        highlighters = {
          hex_color = hi.gen_highlighter.hex_color({ priority = 2000 }),
          shorthand = {
            pattern = "()#%x%x%x()%f[^%x%w]",
            group = function(_, _, data)
              ---@type string
              local match = data.full_match
              local r, g, b = match:sub(2, 2), match:sub(3, 3), match:sub(4, 4)
              local hex_color = "#" .. r .. r .. g .. g .. b .. b

              return MiniHipatterns.compute_hex_color_group(hex_color, "bg")
            end,
            extmark_opts = { priority = 2000 },
          },
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
