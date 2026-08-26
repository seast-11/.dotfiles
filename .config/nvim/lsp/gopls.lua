return {
	cmd = { "gopls" },
	filetypes = { "go", "gomod", "gowork", "gotmpl", "gosum" },
	root_markers = { "go.mod", "go.work", ".git" },
	settings = {
		gopls = {
			gofumpt = true,
			codelenses = {
				gc_details = false,
				generate = true,
				regenerate_cgo = true,
				run_govulncheck = true,
				test = true,
				tidy = true,
				upgrade_dependency = true,
				vendor = true,
			},
			hints = {
				assignVariableTypes = false,
				compositeLiteralFields = false,
				compositeLiteralTypes = false,
				constantValues = false,
				functionTypeParameters = false,
				parameterNames = false,
				rangeVariableTypes = false,
			},
			analyses = {
				-- Essential analyzers for catching common issues
				nilness = true, -- Check for nil pointer dereferences
				unusedparams = true, -- Find unused function parameters
				unusedwrite = true, -- Find unused writes to variables
				useany = true, -- Suggest using 'any' instead of 'interface{}'
				unreachable = true, -- Find unreachable code
				unusedresult = true, -- Check for unused results of calls to certain functions

				-- Helpful but not critical (enable as needed)
				simplifyslice = true, -- Simplify slice expressions
				simplifyrange = true, -- Simplify range loops
				simplifycompositelit = true, -- Simplify composite literals

				-- Performance-intensive analyzers (disabled for better performance)
				shadow = true, -- Check for shadowed variables (can be slow)
				printf = true, -- Check printf-style functions (can be slow)
				structtag = true, -- Check struct tags (can be slow)
				unusedvariable = true, -- Can be slow on large codebases

				-- Bug-catching analyzers (enabled)
				appends = true, -- Detect missing append result assignments
				assign = true, -- Detect suspicious assignments
				atomic = true, -- Detect atomic misuse
				bools = true, -- Detect common boolean expression bugs
				copylocks = true, -- Detect copying locks by value
				deepequalerrors = true, -- Detect errors in reflect.DeepEqual
				defers = true, -- Detect common defer issues
				errorsas = true, -- Detect errors in errors.As
				httpresponse = true, -- Detect HTTP response body leaks
				ifaceassert = true, -- Detect interface assertion issues
				loopclosure = true, -- Detect loop variable captured by closure
				lostcancel = true, -- Detect context cancellations lost
				nilfunc = true, -- Detect comparison with nil functions
				nonewvars = true, -- Detect new vars not used
				shift = true, -- Detect suspicious shift operations
				sigchanyzer = true, -- Detect signal channel issues
				stringintconv = true, -- Detect string/int conversions
				testinggoroutine = true, -- Detect goroutines in tests
				unmarshal = true, -- Detect unmarshal issues
				unsafeptr = true, -- Detect unsafe pointer usage
				unusedfunc = true, -- Detect unused functions
				waitgroup = true, -- Detect waitgroup misuse
				yield = true, -- Detect yield issues

				-- Style/niche analyzers (disabled)
				modernize = false,
				stylecheck = false,
				asmdecl = false,
				atomicalign = false,
				buildtag = false,
				cgocall = false,
				composite = false,
				composites = false,
				contextcheck = false,
				deba = false,
				deprecated = false, -- Too noisy, use golangci-lint instead
				directive = false,
				embed = false,
				fillreturns = false,
				framepointer = false,
				gofix = false,
				hostport = false,
				infertypeargs = false,
				noresultvalues = false,
				slog = false,
				sortslice = false,
				stdmethods = false,
				stdversion = false,
				tests = false,
				timeformat = false,
			},
			usePlaceholders = false,
			completeUnimported = true,
			staticcheck = true,
			directoryFilters = { "-.git", "-.vscode", "-.idea", "-.vscode-test", "-node_modules" },
			semanticTokens = false,
		},
	},
}
