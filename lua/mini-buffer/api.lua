local view = require("mini-buffer.view")
local keymap = require("mini-buffer.keymap")

local Api = {
    view = {},
    config = {},
}

-- @param f function to invoke
local function wrap(f)
    return function(...)
        if vim.g.MiniBufferSetup == 1 then
            return f(...)
        else
            print("mini-buffer setup not called")
        end
    end
end

local wrap_args = function(func, mode)
    return function()
        func(mode)
    end
end

Api.view.open = wrap_args(view.open, "e")
Api.view.sopen = wrap_args(view.open, "s")
Api.view.vopen = wrap_args(view.open, "v")
Api.view.topen = wrap_args(view.open, "t")
Api.view.close = wrap(view.close)
Api.view.delete = wrap(view.delete)

Api.config.default_on_attach = keymap.default_on_attach

return Api
