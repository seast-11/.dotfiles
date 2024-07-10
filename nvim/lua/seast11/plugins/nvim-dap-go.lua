return {
	"leoluz/nvim-dap-go",
	dependencies = {
		"mfussenegger/nvim-dap",
	},
	config = function()
		require("dap").adapters.go = function(callback, config)
			local handle
			local pid_or_err
			local port = 38697
			handle, pid_or_err = vim.loop.spawn("dlv", {
				args = { "dap", "-l", "127.0.0.1:" .. port },
				detached = true,
			}, function(code)
				handle:close()
				print("Delve exited with exit code: " .. code)
			end)
			vim.defer_fn(function()
				callback({ type = "server", host = "127.0.0.1", port = port })
			end, 100)
		end
		require("dap").set_log_level("TRACE")
		require("dap").configurations.go = {
			{
				type = "go",
				name = "Debug File",
				request = "launch",
				program = "${file}",
			},
		}

		local dap = require("dap-go")

		dap.setup({
			dap_configurations = {
				{
					type = "go",
					name = "Attach remote",
					mode = "remote",
					request = "attach",
				},
				{
					type = "go",
					name = "Debug File",
					request = "launch",
					program = "${file}",
				},
			},
			delve = {
				path = "dlv",
				initialize_timeout_sec = 20,
				-- default to string "${port}" which instructs nvim-dap
				-- to start the process in a random available port
				port = "${port}",
				-- whether the dlv process to be created detached or not. there is
				-- an issue on Windows where this needs to be set to false
				-- otherwise the dlv server creation will fail.
				detached = vim.fn.has("win32") == 0,
				-- the current working directory to run dlv from, if other than
				-- the current working directory.
				cwd = nil,
			},
		})

		vim.keymap.set("n", "<F5>", function()
			require("dap").continue()
		end)
		vim.keymap.set("n", "dso", function()
			require("dap").step_over()
		end)
		vim.keymap.set("n", "dsi", function()
			require("dap").step_into()
		end)
		vim.keymap.set("n", "<F12>", function()
			require("dap").step_out()
		end)
		vim.keymap.set({ "n", "v" }, "<Leader>dh", function()
			require("dap.ui.widgets").hover()
		end)
		vim.keymap.set({ "n", "v" }, "<Leader>dp", function()
			require("dap.ui.widgets").preview()
		end)
		vim.keymap.set("n", "<Leader>df", function()
			local widgets = require("dap.ui.widgets")
			widgets.centered_float(widgets.frames)
		end)
		vim.keymap.set("n", "<Leader>ds", function()
			local widgets = require("dap.ui.widgets")
			widgets.centered_float(widgets.scopes)
		end)
		vim.keymap.set("n", "<leader>db", "<cmd> DapToggleBreakpoint <CR>", { desc = "Add a breakpoinnt at line" })
		vim.keymap.set("n", "<leader>dus", function()
			local widgets = require("dap.ui.widgets")
			local sidebar = widgets.sidebar(widgets.scopes)
			sidebar.open()
		end, { desc = "Open debugging sidebar" })
		vim.keymap.set("n", "<leader>dgt", function()
			require("dap-go").debug_test()
		end, { desc = "Debug go test" })
		vim.keymap.set("n", "<leader>dgl", function()
			require("dap-go").debug_last()
		end, { desc = "Debug last go test" })
	end,
}
