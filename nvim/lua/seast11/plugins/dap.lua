return {
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			"igorlfs/nvim-dap-view",
		},
		config = function()
			local dap = require("dap")
			local dapview = require("dap-view")

			dapview.setup({
				follow_tab = true,
				winbar = {
					sections = { "watches", "scopes", "breakpoints", "threads", "repl" },
					default_section = "repl",
				},
				windows = {
					terminal = {
						hide = { "delve" }, -- `delve` is known to not use the terminal.
					},
				},
			})

			-- ---------------------------
			-- Adapter (vscode-go debugAdapter.js)
			-- ---------------------------
			dap.adapters.go = {
				type = "executable",
				command = "node",
				args = { os.getenv("HOME") .. "/repos/vscode-go/extension/dist/debugAdapter.js" },
			}

			-- ---------------------------
			-- Base configurations (templates)
			-- we'll resolve ${file} / ${fileDirname} at runtime for correctness
			-- ---------------------------
			dap.configurations.go = {
				{
					type = "go",
					name = "Debug file",
					request = "launch",
					program = "${file}", -- resolved per-buffer
					dlvToolPath = vim.fn.exepath("dlv"),
				},
				{
					type = "go",
					name = "Debug package",
					request = "launch",
					program = "${fileDirname}", -- resolved per-buffer
					dlvToolPath = vim.fn.exepath("dlv"),
				},
				{
					type = "go",
					name = "Test current file",
					request = "launch",
					mode = "test",
					program = "${fileDirname}", -- run tests for package (dir)
					dlvToolPath = vim.fn.exepath("dlv"),
				},
				{
					type = "go",
					name = "Benchmark current file",
					request = "launch",
					mode = "test",
					program = "${fileDirname}",
					args = { "-test.run=^$", "-test.bench=." },
					dlvToolPath = vim.fn.exepath("dlv"),
				},
			}

			-- ---------------------------
			-- Helpers
			-- ---------------------------
			local function make_test_config(test_name)
				return {
					type = "go",
					name = "Debug test: " .. test_name,
					request = "launch",
					mode = "test",
					program = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":h"), -- package dir
					args = { "-test.run=^" .. test_name .. "$" },
					dlvToolPath = vim.fn.exepath("dlv"),
				}
			end

			local function make_bench_config(bench_name)
				return {
					type = "go",
					name = "Debug bench: " .. bench_name,
					request = "launch",
					mode = "test",
					program = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":h"),
					args = { "-test.run=^$", "-test.bench=^" .. bench_name .. "$" },
					dlvToolPath = vim.fn.exepath("dlv"),
				}
			end

			-- ---------------------------
			-- Keymaps
			-- ---------------------------
			local map = vim.keymap.set

      -- stylua: ignore start
			map("n", "<leader>dh", function() require("dap.ui.widgets").hover() end, { desc = "DAP Hover Expression" })
			map("n", "<leader>db", function() dap.toggle_breakpoint() end, { desc = "DAP Toggle Breakpoint" })
			map({ "n", "v" }, "<leader>de", function() dapview.add_expr() end, { desc = "DAP Add Expression (Watch)" })
			map("n", "<leader>do", function() dapview.toggle() end, { desc = "DAP toggle view" })
			map("n", "<F5>", dap.continue, { desc = "DAP continue" })
			map("n", "<F10>", dap.step_over, { desc = "DAP step over" })
			map("n", "<F11>", dap.step_into, { desc = "DAP step into" })
			map("n", "<F12>", function() dap.run_to_cursor() end, { desc = "DAP Run To Cursor" })
			-- stylua: ignore end

			-- conditional breakpoint (prompt)
			map("n", "<leader>dB", function()
				local cond = vim.fn.input("Breakpoint condition: ")
				if cond == "" then
					-- empty -> just toggle
					dap.toggle_breakpoint()
				else
					-- call dap.set_breakpoint with condition (common API usage)
					-- If your nvim-dap version accepts a single string, this will work.
					-- Otherwise this still commonly functions with DAP installs.
					pcall(dap.set_breakpoint, cond)
				end
			end, { desc = "DAP Conditional Breakpoint" })

			local function dap_signs_and_highlights()
				local define = vim.fn.sign_define
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
				local str = get("String")
				local num = get("Number")

				local err_fg = err.fg or "#ff5555"
				local warn_fg = warn.fg or "#f1fa8c"
				local info_fg = info.fg or "#8be9fd"
				local hint_fg = hint.fg or "#50fa7b"

				---------------------------------------------------------------------------
				-- nvim-dap sign icons
				---------------------------------------------------------------------------
				define("DapBreakpoint", { text = "", texthl = "DapBreakpoint", linehl = "DapBreakpointLine" })
				define(
					"DapBreakpointCondition",
					{ text = "", texthl = "DapBreakpointCondition", linehl = "DapBreakpointConditionLine" }
				)
				define("DapLogPoint", { text = "", texthl = "DapLogPoint", linehl = "DapLogPointLine" })
				define("DapStopped", { text = "", texthl = "DapStopped", linehl = "DapStoppedLine" })

				hl(0, "DapBreakpoint", { fg = err_fg })
				hl(0, "DapBreakpointCondition", { fg = warn_fg })
				hl(0, "DapLogPoint", { fg = info_fg })
				hl(0, "DapStopped", { fg = hint_fg, bold = true })

				hl(0, "DapBreakpointLine", { bg = "#3b0000" })
				hl(0, "DapBreakpointConditionLine", { bg = "#3b2f00" })
				hl(0, "DapLogPointLine", { bg = "#003b3b" })
				hl(0, "DapStoppedLine", { bg = "#003b00" })

				---------------------------------------------------------------------------
				-- nvim-dap-view highlights
				---------------------------------------------------------------------------
				hl(0, "NvimDapViewBoolean", { link = "Boolean" })
				hl(0, "NvimDapViewConstant", { link = "Constant" })
				hl(0, "NvimDapViewControlDisconnect", { fg = err_fg, bold = true })
				hl(0, "NvimDapViewControlNC", { link = "Comment" })
				hl(0, "NvimDapViewControlPause", { fg = hint_fg, bold = true })
				hl(0, "NvimDapViewControlPlay", { fg = kw.fg or warn_fg, bold = true })
				hl(0, "NvimDapViewControlRunLast", { fg = kw.fg or warn_fg })
				hl(0, "NvimDapViewControlStepBack", { fg = func.fg or info_fg })
				hl(0, "NvimDapViewControlStepInto", { fg = func.fg or info_fg })
				hl(0, "NvimDapViewControlStepOut", { fg = func.fg or info_fg })
				hl(0, "NvimDapViewControlStepOver", { fg = func.fg or info_fg })
				hl(0, "NvimDapViewControlTerminate", { fg = err_fg, bold = true })

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

			-- ---------------------------
			-- Debug function under cursor (Test or Bench)
			-- ---------------------------
			local function find_nearest_test_or_bench()
				local cur = vim.fn.line(".")
				for lnum = cur, 1, -1 do
					local line = vim.api.nvim_buf_get_lines(0, lnum - 1, lnum, false)[1]
					if line then
						local test = line:match("^%s*func%s+(Test%w+)")
						if test then
							return "test", test
						end
						local bench = line:match("^%s*func%s+(Benchmark%w+)")
						if bench then
							return "bench", bench
						end
					end
				end
				return nil
			end

			map("n", "<leader>dt", function()
				local kind, name = find_nearest_test_or_bench()
				if kind == "test" then
					dap.run(make_test_config(name))
				elseif kind == "bench" then
					dap.run(make_bench_config(name))
				else
					print("No Test or Benchmark found above cursor")
				end
			end, { desc = "DAP Debug Test/Bench under cursor" })

			-- ---------------------------
			-- Auto open/close dap-view
			-- ---------------------------
			dap.listeners.after.event_initialized["dapview_open"] = function()
				dapview.open()
			end
			-- dap.listeners.before.event_terminated["dapview_close"] = function()
			-- 	dapview.close()
			-- end
			-- dap.listeners.before.event_exited["dapview_close"] = function()
			-- 	dapview.close()
			-- end
		end,
	},
}
