local builtin = require("telescope.builtin")
local actions = require("telescope.actions")

local function open_and_maybe_reveal(prompt_bufnr)
  actions.select_default(prompt_bufnr)

  vim.defer_fn(function()
    local api = require("nvim-tree.api")
    if api.tree.is_visible() then
      api.tree.find_file({ open = false, focus = false })
    end
  end, 200)  -- wait 100ms before syncing
end

-- Wrap a builtin picker to sync nvim-tree after selecting a file
local function with_tree_sync(picker_fn)
  return function()
    picker_fn({
      attach_mappings = function(_, map)
        map("i", "<CR>", open_and_maybe_reveal)
        map("n", "<CR>", open_and_maybe_reveal)
        return true
      end,
    })
  end
end

-- Keymaps with nvim-tree sync
vim.keymap.set("n", "<leader>pf", with_tree_sync(builtin.find_files), {})
vim.keymap.set("n", "<C-p>", with_tree_sync(builtin.git_files), {})
vim.keymap.set("n", "<leader>ps", function()
  builtin.grep_string({ search = vim.fn.input("Grep > ") })
end)
vim.keymap.set("n", "<leader>vh", builtin.help_tags, {})
