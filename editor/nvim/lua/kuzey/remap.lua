vim.g.mapleader = " "
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)
vim.keymap.set("n", "<leader>f", function()
    local filetype = vim.bo.filetype
    local clients = vim.lsp.get_clients({ bufnr = 0 })
    local supports_format = false

    for _, client in ipairs(clients) do
        if client:supports_method("textDocument/formatting") then
            supports_format = true
            break
        end
    end

    if supports_format then
        vim.lsp.buf.format()
    elseif filetype == "python" then
        local filepath = vim.fn.expand("%:p")
        vim.fn.jobstart({ "black", filepath }, {
            on_exit = function(_, code, _)
                if code == 0 then
                    vim.cmd("edit!")
                    vim.notify("Formatted with Black (fallback)", vim.log.levels.INFO)
                else
                    vim.notify("Black formatting failed", vim.log.levels.ERROR)
                end
            end,
        })
    else
        vim.notify("No formatter available", vim.log.levels.WARN)
    end
end, { desc = "Format file (LSP or fallback)" })


vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

vim.keymap.set("v", "<leader>y", '"+y')
vim.keymap.set("x", "<leader>p", "\"_dP")
