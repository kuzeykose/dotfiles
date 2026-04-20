require("gruvbox").setup({
    contrast = "hard",
    italic = {
        comments  = true,  -- make comments italic
        strings   = false, -- you can set to true if you like
        operators = false,
        folds     = true,
    },
    bold = false,                 -- enables bold keywords, functions, etc.
    overrides = {
        SignColumn = { bg = "" }, -- Example: set background to dark0_hard
    },
})

vim.cmd([[colorscheme gruvbox]])
