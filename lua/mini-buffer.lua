local view = require("mini-buffer.view")

local M = {}

function M.setup(opts)

    opts = {
        on_attach = "default",
    }

    require("mini-buffer.view").setup()
    require("mini-buffer.keymap").setup(opts)
    require("mini-buffer.command").setup()

end

return M
