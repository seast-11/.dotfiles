local dap = require("dap")
local dapview = require("dap-view")
local dap_go = require("dap-go")

dapview.setup({
    follow_tab = true,
    winbar = {
        sections = { "watches", "scopes", "breakpoints", "threads", "repl" },
        default_section = "repl",
    },
    windows = {
        terminal = {
            hide = { "delve" },
        },
    },
})

-- ──────────────────────────────────────────────────────────────────────
-- Go (via nvim-dap-go)
-- ──────────────────────────────────────────────────────────────────────

dap_go.setup({
    dap_configurations = {
        type = "go",
        name = "Debug with args",
        request = "launch",
        program = "${file}",
    },
    delve = {
        path = "dlv",
        initialize_timeout_sec = 20,
        port = "${port}",
        args = {},
        build_flags = "",
        detached = vim.fn.has("win32") == 0,
    },
})

-- ──────────────────────────────────────────────────────────────────────
-- Python (debugpy)
-- ──────────────────────────────────────────────────────────────────────

dap.adapters.python = {
    type = "executable",
    command = "debugpy-adapter",
}

dap.configurations.python = {
    {
        type = "python",
        request = "launch",
        name = "Launch file",
        program = "${file}",
        pythonPath = function()
            -- prefer the active virtualenv or conda env
            local venv = os.getenv("VIRTUAL_ENV")
            if venv then
                return venv .. "/bin/python"
            end
            local conda = os.getenv("CONDA_PREFIX")
            if conda then
                return conda .. "/bin/python"
            end
            return "python3"
        end,
    },
    {
        type = "python",
        request = "launch",
        name = "Launch module",
        program = "${file}",
        module = "${module}",
    },
    {
        type = "python",
        request = "attach",
        name = "Attach to remote",
        connect = {
            host = "localhost",
            port = 5678,
        },
    },
}

-- ──────────────────────────────────────────────────────────────────────
-- C / C++ (GDB native DAP mode)
-- ──────────────────────────────────────────────────────────────────────

dap.adapters.gdb = {
    type = "executable",
    command = "gdb",
    args = { "-i", "dap" },
}

dap.configurations.c = {
    {
        type = "gdb",
        request = "launch",
        name = "Launch file",
        program = function()
            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
        end,
        cwd = "${workspaceFolder}",
        args = {},
        stopOnEntry = false,
    },
    {
        type = "gdb",
        request = "attach",
        name = "Attach to process",
        pid = function()
            return require("dap.utils").pick_process({})
        end,
    },
}

dap.configurations.cpp = dap.configurations.c

-- ──────────────────────────────────────────────────────────────────────
-- Keymaps
-- ──────────────────────────────────────────────────────────────────────

-- stylua: ignore start
vim.keymap.set("n", "<leader>dt", function() require("dap-go").debug_test() end, { desc = "DAP Debug nearest test (Go)" })
vim.keymap.set("n", "<leader>dl", function() require("dap-go").debug_last_test() end, { desc = "DAP Debug last test (Go)" })
vim.keymap.set("n", "<leader>dq", dap.terminate, { desc = "DAP Terminate" })
vim.keymap.set("n", "<leader>dh", function() require("dap.ui.widgets").hover() end, { desc = "DAP Hover Expression" })
vim.keymap.set("n", "<leader>db", function() dap.toggle_breakpoint() end, { desc = "DAP Toggle Breakpoint" })
vim.keymap.set({ "n", "v" }, "<leader>de", function() require("dap-view").add_expr() end, { desc = "DAP Add Expression (Watch)" })
vim.keymap.set("n", "<leader>do", function() require("dap-view").toggle() end, { desc = "DAP toggle view" })
vim.keymap.set("n", "<F5>", dap.continue, { desc = "DAP continue" })
vim.keymap.set("n", "<F10>", dap.step_over, { desc = "DAP step over" })
vim.keymap.set("n", "<F11>", dap.step_into, { desc = "DAP step into" })
vim.keymap.set("n", "<F12>", function() dap.run_to_cursor() end, { desc = "DAP Run To Cursor" })
-- stylua: ignore end

vim.keymap.set("n", "<leader>dB", function()
    local cond = vim.fn.input("Breakpoint condition: ")
    if cond == "" then
        dap.toggle_breakpoint()
    else
        pcall(dap.set_breakpoint, cond)
    end
end, { desc = "DAP Conditional Breakpoint" })

-- ──────────────────────────────────────────────────────────────────────
-- Signs & highlights
-- ──────────────────────────────────────────────────────────────────────

local function dap_signs_and_highlights()
    local hl = vim.api.nvim_set_hl
    local get = function(name)
        return vim.api.nvim_get_hl(0, { name = name }) or {}
    end

    local err = get("DiagnosticError")
    local warn = get("DiagnosticWarn")
    local info = get("DiagnosticInfo")
    local hint = get("DiagnosticHint")
    local ok = get("DiagnosticOk") or { fg = "#50fa7b" }
    local kw = get("Keyword")
    local func = get("Function")

    local err_fg = err.fg or "#ff5555"
    local warn_fg = warn.fg or "#f1fa8c"
    local info_fg = info.fg or "#8be9fd"
    local hint_fg = hint.fg or "#50fa7b"

    vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DapBreakpoint", linehl = "DapBreakpointLine", numhl = "" })
    vim.fn.sign_define("DapBreakpointCondition", { text = "○", texthl = "DapBreakpointCondition", linehl = "DapBreakpointConditionLine", numhl = "" })
    vim.fn.sign_define("DapLogPoint", { text = "○", texthl = "DapLogPoint", linehl = "DapLogPointLine", numhl = "" })
    vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DapBreakpoint", linehl = "DapStoppedLine", numhl = "" })
    vim.fn.sign_define("DapBreakpointRejected", { text = "x", texthl = "DapBreakpoint", linehl = "", numhl = "" })

    hl(0, "DapBreakpoint", { fg = err_fg })
    hl(0, "DapBreakpointCondition", { fg = warn_fg })
    hl(0, "DapLogPoint", { fg = info_fg })
    hl(0, "DapStopped", { fg = hint_fg, bold = true })

    hl(0, "DapBreakpointLine", { bg = "#3b0000" })
    hl(0, "DapBreakpointConditionLine", { bg = "#3b2f00" })
    hl(0, "DapLogPointLine", { bg = "#003b3b" })
    hl(0, "DapStoppedLine", { bg = "#3a3000" })

    hl(0, "NvimDapViewBoolean", { link = "Boolean" })
    hl(0, "NvimDapViewConstant", { link = "Constant" })
    hl(0, "NvimDapViewControlDisconnect", { fg = err_fg, bold = true })
    hl(0, "NvimDapViewControlNC", { link = "Comment" })
    hl(0, "NvimDapViewControlPause", { fg = hint_fg, bold = true })
    hl(0, "NvimDapViewControlPlay", { fg = kw.fg or warn_fg, bold = true })
    hl(0, "NvimDapViewControlRunLast", { fg = func.fg or info_fg })
    hl(0, "NvimDapViewControlStepBack", { fg = func.fg or info_fg })
    hl(0, "NvimDapViewControlStepInto", { fg = func.fg or info_fg })
    hl(0, "NvimDapViewControlStepOut", { fg = func.fg or info_fg })
    hl(0, "NvimDapViewControlStepOver", { fg = func.fg or info_fg })
    hl(0, "NvimDapViewExceptionFilterDisabled", { fg = err_fg })
    hl(0, "NvimDapViewExceptionFilterEnabled", { fg = ok.fg })
    hl(0, "NvimDapViewFileName", { link = "Directory" })
    hl(0, "NvimDapViewFloat", { link = "Float" })
    hl(0, "NvimDapViewFrameCurrent", { fg = warn_fg })
    hl(0, "NvimDapViewFunction", { link = "Function" })
    hl(0, "NvimDapViewLineNumber", { link = "LineNr" })
    hl(0, "NvimDapViewMissingData", { fg = err_fg })
    hl(0, "NvimDapViewNumber", { link = "Number" })
    hl(0, "NvimDapViewSeparator", { link = "Comment" })
    hl(0, "NvimDapViewString", { link = "String" })
    hl(0, "NvimDapViewTabSelected", { link = "TabLineSel" })
    hl(0, "NvimDapViewTab", { link = "TabLine" })
    hl(0, "NvimDapViewThreadError", { fg = err_fg })
    hl(0, "NvimDapViewThreadStopped", { fg = warn_fg })
    hl(0, "NvimDapViewThread", { link = "Tag" })
    hl(0, "NvimDapViewWatchError", { fg = err_fg })
    hl(0, "NvimDapViewWatchExpr", { link = "Identifier" })
    hl(0, "NvimDapViewWatchUpdated", { fg = warn_fg })
end

dap_signs_and_highlights()
vim.api.nvim_create_autocmd("ColorScheme", { callback = dap_signs_and_highlights })

dap.listeners.after.event_initialized["dapview_open"] = function()
    dapview.open()
end
