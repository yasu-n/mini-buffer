local view = require("mini-buffer.view")
local command = require("mini-buffer.command")

local M = {}

local DEFAULT_OPTS = {
    on_attach = "default",
    winopts = {
        relativenumber = false,
        number = false,
        list = false,
        signcolumn = "yes",
    },
}

local function setup_autocommands(opts)
    local augroup_id = vim.api.nvim_create_augroup("MiniBuffer", { clear = true })
    local function create_mini_buffer_autocmd(name, custom_opts)
        local default_opts = { group = augroup_id }
        vim.api.nvim_create_autocmd(name, vim.tbl_extend("force", default_opts, custom_opts))
    end

    create_mini_buffer_autocmd("ColorScheme", {
        callback = function()
            view.reset_winhl()
        end,
    })
end

-- merge options
local function merge_options(conf)
    return vim.tbl_deep_extend("force", DEFAULT_OPTS, conf or {})
end

function M.setup(conf)
    local opts = merge_options(conf)

    require("mini-buffer.view").setup(opts)
    require("mini-buffer.keymap").setup(opts)

    setup_autocommands(opts)

    if vim.g.MiniBufferSetup ~= 1 then
        command.setup()
    end

    vim.g.MiniBufferSetup = 1
    vim.api.nvim_exec_autocmds("User", { pattern = "MiniBufferSetup" })
end

vim.g.MiniBufferRequired = 1
vim.api.nvim_exec_autocmds("User", { pattern = "MiniBufferRequired" })

return M
