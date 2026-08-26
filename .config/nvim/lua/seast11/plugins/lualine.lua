local lualine = require("lualine")

local function lsp_clients()
    local bufnr = vim.api.nvim_get_current_buf()
    local clients = vim.lsp.get_clients({ bufnr = bufnr })
    if #clients == 0 then
        return "!LSP"
    end
    local names = {}
    for _, client in ipairs(clients) do
        table.insert(names, client.name)
    end
    return " " .. table.concat(names, ", ")
end

lualine.setup({
    options = {
        theme = "auto",
    },
    sections = {
        lualine_x = {
            {
                "diagnostics",
                sources = { "nvim_diagnostic" },
						    symbols = { error = " ", warn = " ", info = " ", hint = " " },
            },
            { lsp_clients },
            { "encoding" },
            { "fileformat" },
            { "filetype" },
        },
    },
})
