local M = {}

-- Apply mappings to a scratch buffer and return buffer local mappings
-- @param fn function(bufnr) on_attach or default_on_attach
-- @return table as per vim.api_nvim_buf_get_keymap
local function generate_keymap(fn)
    -- create an unlisted scratch buffer
    local scrach_bufnr = vim.api.nvim_create_buf(false, true)

    -- apply mappings
    fn(scrach_bufnr)

    -- retrieve all
    local keymap = vim.api.nvim_buf_get_keymap(scrach_bufnr, "")

    -- delete the scrach buffer
    vim.api.nvim_buf_delete(scrach_bufnr, { force = true })

    return keymap
end

function M.default_on_attach(bufnr)
    local view = require("mini-buffer.view")

    local function opts(desc)
        return {
            desc = 'mini-buffer: ' .. desc,
            buffer = bufnr,
            noremap = true,
            silent = true,
            nowait = true,
        }
    end

    local wrap = function(func, type)
        local args = type
        return function()
            func(args)
        end
    end

    -- GEGIN_DEFAULT_ON_ATTACH
    vim.keymap.set('n', '<cr>', wrap(view.open, "e"), opts('editbuffer'))
    vim.keymap.set('n', 'v<cr>', wrap(view.open, "v"), opts('editbuffer'))
    vim.keymap.set('n', 's<cr>', wrap(view.open, "s"), opts('editbuffer'))
    vim.keymap.set('n', 't<cr>', view.topen, opts('editbuffer'))
    vim.keymap.set('n', 'q', view.close, opts('close buffer list'))
    vim.keymap.set('n', 'd', view.delete, opts('delete buffer'))
end

-- @return table
function M.get_keymap()
    return generate_keymap(M.on_attach)
end

-- @return table
function M.get_keymap_default()
    return generate_keymap(M.default_on_attach)
end

function M.setup(opts)
    if type(opts.on_attach) ~= "function" then
        M.on_attach = M.default_on_attach
    else
        M.on_attach = opts.on_attach
    end
end

return M
