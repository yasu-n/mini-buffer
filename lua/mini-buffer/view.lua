local M = {}

-- BUFNR[TAB_PAGE_ID] = bufnr
local BUFNR = {}

-- window options
M.Winopts = {
    relativenumber = false,
    number = false,
    list = false,
    signcolumn = "yes",
    spell = false,
    cursorcolumn = false,
    cursorline = true,
    cursorlineopt = "both",
    wrap = false,
    winfixwidth = true,
    winfixheight = true,
    winhl = table.concat({
        "EndOfBuffer:MiniBufferEndOfBuffer",
        "CursorLine:MiniBufferCursorLine",
        "CursorLineNr:MiniBufferCursorLineNr",
        "LineNr:MiniBufferLineNr",
        "WinSeparator:MiniBufferWinSeparator",
        "SineColumn:MiniBufferSignColumn",
        "Normal:MiniBufferNormal",
        "NormalNC:MiniBufferNormalNC",
    }, ","),
}

-- buffer options
local BUFFER_OPTIONS = {
    swapfile = false,
    buftype = "nofile",
    modifiable = false,
    filetype = "MiniBuffer",
    bufhidden = "wipe",
    buflisted = false,
}

-- @return buffer number
function M.get_bufnr()
    return BUFNR[vim.api.nvim_get_current_tabpage()]
end

-- @param bufnr buffer id to be checked
-- @return bool
local function is_valid_buffer(bufnr)
    return vim.api.nvim_buf_is_valid(bufnr)
        and vim.fn.buflisted(bufnr) == 1
end

-- @param bufnr buffer id to be checked
-- @return bool
local function is_valid_file(bufnr)
    return is_valid_buffer(bufnr)
        and vim.fn.getbufvar(bufnr, "&buftype") ~= "terminal"
end

-- Create buffer
local function create_buffer()
    pcall(vim.cmd "botright 5new")
    local eventignore = vim.opt.eventignore
    vim.opt.eventignore = "all"
    for k, v in pairs(M.Winopts) do
        vim.opt_local[k] = v
    end
    vim.opt.eventignore = eventignore

    local tab = vim.api.nvim_get_current_tabpage()
    local buf = vim.api.nvim_get_current_buf()
    BUFNR[tab] = buf
    vim.api.nvim_buf_set_name(buf, "MiniBuffer")
    for option, value in pairs(BUFFER_OPTIONS) do
        vim.bo[buf][option] = value
    end

    require("mini-buffer.keymap").on_attach(M.get_bufnr())
end

-- Set buffer data
local function set_bufs()
    vim.api.nvim_set_option_value("modifiable", true, { buf = M.get_bufnr() })
    local list = {}

    for _, bufnr in pairs(vim.api.nvim_list_bufs()) do
        if is_valid_file(bufnr) then
            local path = vim.api.nvim_buf_get_name(bufnr)
            if path == "" then
                path = "[No Name]"
            end
            local line = { bufnr, path }
            table.insert(list, #list + 1, vim.fn.join(line, "\t"))
        end
    end

    vim.api.nvim_buf_set_lines(M.get_bufnr(), 0, -1, false, list)
    vim.api.nvim_set_option_value("modifiable", false, { buf = M.get_bufnr() })
end

-- Open mini buffer window
function M.open_mini_buffer()
    local bufnr = M.get_bufnr()
    if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
        local winnr = vim.fn.bufwinid(bufnr)
        if winnr and vim.api.nvim_win_is_valid(winnr) then
            vim.fn.win_gotoid(winnr)
        end
    else
        create_buffer()
    end
    set_bufs()
end

-- Create buffer info
local function create_bufinfo()
    local line = vim.api.nvim_get_current_line()
    local rows = {}
    for row in string.gmatch(line, "([^\t]+)") do
        table.insert(rows, #rows + 1, row)
    end

    local info = vim.fn.getbufinfo(tonumber(rows[1]))
    return info[1]
end

-- Open buffer
-- @param mode string
function M.open(mode)
    local info = create_bufinfo()
    if info.hidden == 0 then
        local winnr = vim.fn.bufwinid(info.bufnr)
        vim.fn.win_gotoid(winnr)
        M.close()
        return
    end

    local winnr = vim.fn.bufwinid(vim.fn.bufnr "#")
    vim.api.nvim_set_current_win(winnr)
    if mode == "e" then
        vim.api.nvim_command("edit " .. info.name)
    elseif mode == "v" then
        vim.api.nvim_command("vs " .. info.name)
    else
        vim.api.nvim_command("sp " .. info.name)
    end
    M.close()
end

-- open buffer in new tab 
function M.topen()
    local path = vim.api.nvim_get_current_line()
    M.close()
    vim.api.nvim_command("tabnew " .. path)
end

-- Close buffer list window
function M.close()
    local winnr = vim.fn.bufwinid(M.get_bufnr())
    if vim.api.nvim_win_is_valid(winnr) then
        vim.api.nvim_command("bd" .. M.get_bufnr())
    end
end

-- Delete buffer
function M.delete()
    local info = create_bufinfo()
    vim.api.nvim_command("bd" .. info.bufnr)
    set_bufs()
end

-- Used on ColorScheme event
function M.reset_winhl()
    local winnr = vim.api.nvim_get_current_win()
    vim.wo[winnr].winhl = M.Winopts.winhl
end

-- Initialized config
function M.setup(opts)
    local options = opts or {}
    M.Winopts.cursorline = options.winopts.cursorline
    M.Winopts.number = options.winopts.number
    M.Winopts.relativenumber = options.winopts.relativenumber
    M.Winopts.signcolumn = options.winopts.signcolumn
end

return M
