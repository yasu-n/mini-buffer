local view = require("mini-buffer.view")
local keymap = require("mini-buffer.keymap")

local Api = {
    buf = {},
    view = {},
    config = {},
}

-- @param f function
local function wrap(f, mode)
    return function()
        if vim.g.MiniBufferSetup == 1 then
            return f(mode)
        else
            print("mini-buffer setup not called")
        end
    end
end

Api.buf.open = wrap(view.open_mini_buffer)
Api.buf.close = wrap(view.close)

Api.view.open = wrap(view.open, "e")
Api.view.sopen = wrap(view.open, "s")
Api.view.vopen = wrap(view.open, "v")
Api.view.topen = wrap(view.open, "t")
Api.view.delete = wrap(view.delete)

Api.config.default_on_attach = keymap.default_on_attach

return Api
