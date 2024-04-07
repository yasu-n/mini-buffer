
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

-- @param bufnr integer
function M.default_on_attach(bufnr)
    local api = require("mini-buffer.api")

    local function opts(desc)
        return {
            desc = 'mini-buffer: ' .. desc,
            buffer = bufnr,
            noremap = true,
            silent = true,
            nowait = true,
        }
    end

    -- GEGIN_DEFAULT_ON_ATTACH
    vim.keymap.set('n', '<cr>', api.view.open, opts('edit buffer'))
    vim.keymap.set('n', 's<cr>', api.view.sopen, opts('split buffer'))
    vim.keymap.set('n', 'v<cr>', api.view.vopen, opts('vsplit buffer'))
    vim.keymap.set('n', 't<cr>', api.view.topen, opts('tabnew buffer'))
    vim.keymap.set('n', 'q', api.view.close, opts('close buffer list'))
    vim.keymap.set('n', 'd', api.view.delete, opts('delete buffer'))
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
