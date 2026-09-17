return {
  {
    "folke/tokyonight.nvim",
    opts = { style = "night" },
  },
  {
    "LazyVim/LazyVim",
    opts = { colorscheme = "tokyonight" },
  },
  {
    "folke/tokyonight.nvim",
    init = function()
      local BG       = "#0a1a0a"
      local BG_DARK  = "#061206"
      local BG_HL    = "#163016"
      local BG_FLOAT = "#0e200e"

      local palette  = {
        BG_DARK,
        BG,
        BG_FLOAT,
        "#1d341d",
        BG_HL,
        "#365836",
        "#426842",
        "#4f7a4f",
        "#5e8e5e",
        "#6ea36e",
        "#7fb87f",
        "#92cc92",
        "#a6dca6",
        "#bceabc",
        "#d4f5d4",
      }

      local function to_green(hex)
        if not hex or hex == "NONE" or hex == "" then return nil end
        hex = hex:gsub("#", "")
        if #hex ~= 6 then return nil end
        local r = tonumber(hex:sub(1, 2), 16) or 0
        local g = tonumber(hex:sub(3, 4), 16) or 0
        local b = tonumber(hex:sub(5, 6), 16) or 0
        local lum = (0.299 * r + 0.587 * g + 0.114 * b) / 255
        lum = 0.15 + lum * 0.85
        local idx = math.floor(lum * (#palette - 1) + 0.5) + 1
        if idx < 1 then idx = 1 end
        if idx > #palette then idx = #palette end
        return palette[idx]
      end

      local function repaint_group(name)
        local ok, h = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
        if not ok or not h then return end
        local new = {}
        if h.fg then new.fg = to_green(string.format("%06x", h.fg)) end
        if h.bg then new.bg = to_green(string.format("%06x", h.bg)) end
        if h.sp then new.sp = to_green(string.format("%06x", h.sp)) end
        for _, attr in ipairs({ "bold", "italic", "underline", "undercurl", "strikethrough", "reverse", "nocombine" }) do
          if h[attr] then new[attr] = true end
        end
        if next(new) == nil then return end
        pcall(vim.api.nvim_set_hl, 0, name, new)
      end

      local function repaint_all()
        local groups = vim.api.nvim_get_hl(0, {})
        for name, _ in pairs(groups) do
          repaint_group(name)
        end
      end

      local function force_backgrounds()
        local hl = vim.api.nvim_set_hl
        local bg_groups = {
          "Normal", "NormalNC", "NormalFloat", "FloatBorder", "FloatTitle",
          "SignColumn", "FoldColumn", "LineNr", "CursorLineNr", "CursorLine",
          "CursorColumn", "ColorColumn", "WinSeparator", "VertSplit",
          "Pmenu", "PmenuSel", "PmenuSbar", "PmenuThumb",
          "StatusLine", "StatusLineNC", "TabLine", "TabLineFill", "TabLineSel",
          "NeoTreeNormal", "NeoTreeNormalNC", "NeoTreeWinSeparator",
          "TelescopeNormal", "TelescopeBorder", "TelescopePromptNormal",
          "TelescopePromptBorder", "TelescopeResultsNormal", "TelescopePreviewNormal",
          "BlinkCmpMenu", "BlinkCmpMenuBorder", "BlinkCmpDoc", "BlinkCmpDocBorder",
          "BlinkCmpSignatureHelp", "BlinkCmpSignatureHelpBorder",
          "WhichKey", "WhichKeyFloat", "WhichKeyBorder",
          "NotifyBackground",
          "BufferLineFill", "BufferLineBackground", "BufferLineBufferVisible",
          "BufferLineBufferSelected", "BufferLineTabSelected",
        }
        for _, name in ipairs(bg_groups) do
          local ok, h = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
          if ok and h then
            h.bg = BG
            if name:match("NeoTree") or name:match("Status") or name:match("Tab") or name:match("BufferLine") or name:match("Separator") then
              h.bg = BG_DARK
            end
            if name:match("Float") or name:match("Telescope") or name:match("Blink") or name:match("WhichKey") or name:match("Notify") then
              h.bg = BG_FLOAT
            end
            pcall(vim.api.nvim_set_hl, 0, name, h)
          end
        end
        hl(0, "CursorLine", { bg = BG_HL })
        hl(0, "Visual", { bg = BG_HL })
      end

      local function repaint_lualine()
        local ok, lualine = pcall(require, "lualine")
        if not ok then return end
        local p = {
          bg       = BG_DARK,
          bg_hl    = BG_HL,
          fg       = palette[14],
          fg_dim   = palette[10],
          green    = palette[11],
          green_lt = palette[13],
          green_dk = palette[7],
          yellow   = palette[9],
          red      = palette[8],
          cyan     = palette[12],
        }
        local theme = {
          normal   = { a = { bg = p.green, fg = p.bg, gui = "bold" }, b = { bg = p.bg_hl, fg = p.fg }, c = { bg = p.bg, fg = p.fg } },
          insert   = { a = { bg = p.green_lt, fg = p.bg, gui = "bold" }, b = { bg = p.bg_hl, fg = p.fg }, c = { bg = p.bg, fg = p.fg } },
          visual   = { a = { bg = p.green_dk, fg = p.bg, gui = "bold" }, b = { bg = p.bg_hl, fg = p.fg }, c = { bg = p.bg, fg = p.fg } },
          command  = { a = { bg = p.yellow, fg = p.bg, gui = "bold" }, b = { bg = p.bg_hl, fg = p.fg }, c = { bg = p.bg, fg = p.fg } },
          replace  = { a = { bg = p.red, fg = p.bg, gui = "bold" }, b = { bg = p.bg_hl, fg = p.fg }, c = { bg = p.bg, fg = p.fg } },
          terminal = { a = { bg = p.cyan, fg = p.bg, gui = "bold" }, b = { bg = p.bg_hl, fg = p.fg }, c = { bg = p.bg, fg = p.fg } },
          inactive = { a = { bg = p.bg, fg = p.fg_dim }, b = { bg = p.bg, fg = p.fg_dim }, c = { bg = p.bg, fg = p.fg_dim } },
        }
        lualine.setup({ options = { theme = theme } })
      end

      vim.api.nvim_create_autocmd("ColorScheme", {
        callback = function()
          vim.schedule(function()
            repaint_all()
            force_backgrounds()
            repaint_lualine()
          end)
        end,
      })

      vim.schedule(function()
        if vim.g.colors_name then
          repaint_all()
          force_backgrounds()
          repaint_lualine()
        end
      end)
    end,
  },
}
