local view = require("mini-buffer.view")

local M = {}

local CMDS = {
    {
        name = "MiniBufferOpen",
        opts = {
            desc = "mini-buffer: open",
        },
        command = function()
            view.open_mini_buffer()
        end,
    },
    {
        name = "MiniBufferClose",
        opts = {
            desc = "mini-buffer: close",
        },
        command = function()
            view.close()
        end,
    }
}

function M.get()
    return vim.deepcopy(CMDS)
end

function M.setup()
    for _, cmd in ipairs(CMDS) do
        local opts = vim.tbl_extend("force", cmd.opts, { force = true })
        vim.api.nvim_create_user_command(cmd.name, cmd.command, opts)
    end
end

return M
