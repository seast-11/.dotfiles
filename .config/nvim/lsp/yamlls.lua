return {
	cmd = { "yaml-language-server", "--stdio" },
	filetypes = { "yaml", "yml" },
	root_markers = {
		".git",
		"kustomization.yaml",
		"kustomization.yml",
		"Chart.yaml", -- Helm
		"docker-compose.yml",
		"docker-compose.yaml",
	},
	settings = {
		yaml = {
			validate = true,
			completion = true,
			hover = true,
			format = {
				enable = true,
			},
			schemaStore = {
				enable = true, -- pulls schemas automatically
				url = "https://www.schemastore.org/api/json/catalog.json",
			},
			schemas = {
				-- Kubernetes
				["https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/v1.29.0-standalone-strict/all.json"] = "*.yaml",
				-- GitHub Actions
				["https://json.schemastore.org/github-workflow.json"] = ".github/workflows/*",
				-- Docker Compose
				["https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json"] = {
					"docker-compose.yml",
					"docker-compose.yaml",
				},
			},
			keyOrdering = false,
		},
	},
}
