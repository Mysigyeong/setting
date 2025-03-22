-- load defaults i.e lua_lsp
local util = require "lspconfig.util"
local async = require "lspconfig.async"

require("nvchad.configs.lspconfig").defaults()

local lspconfig = require "lspconfig"
local nvlsp = require "nvchad.configs.lspconfig"

-- Metals
lspconfig.metals.setup {
  cmd = { "metals" },
  filetypes = { "scala", "sbt", "java" },
  root_dir = util.root_pattern("build.sbt", "build.sc", "build.gradle", "pom.xml"),
  message_level = vim.lsp.protocol.MessageType.Log,
  init_options = {
    statusBarProvider = "off",
    isHttpEnabled = true,
    compilerOptions = {
      snippetAutoIndent = false,
    },
  },
  capabilities = require("cmp_nvim_lsp").default_capabilities(),
  settings = {
    metals = {
      showImplicitArguments = true,
      excludedPackages = { "akka.actor.typed.javadsl", "com.github.swagger.akka.javadsl" },
    },
  },
  on_attach = nvlsp.on_attach,
}

-- Rust Analyzer
local function is_library(fname)
  local user_home = vim.fs.normalize(vim.env.HOME)
  local cargo_home = os.getenv "CARGO_HOME" or user_home .. "/.cargo"
  local registry = cargo_home .. "/registry/src"
  local git_registry = cargo_home .. "/git/checkouts"

  local rustup_home = os.getenv "RUSTUP_HOME" or user_home .. "/.rustup"
  local toolchains = rustup_home .. "/toolchains"

  for _, item in ipairs { toolchains, registry, git_registry } do
    if util.path.is_descendant(item, fname) then
      local clients = util.get_lsp_clients { name = "rust_analyzer" }
      return #clients > 0 and clients[#clients].config.root_dir or nil
    end
  end
end

lspconfig.rust_analyzer.setup {
  cmd = { "rust-analyzer" },
  filetypes = { "rust" },
  init_options = {
    statusBarProvider = "off",
  },
  on_attach = nvlsp.on_attach,
  single_file_support = true,
  root_dir = function(fname)
    local reuse_active = is_library(fname)
    if reuse_active then
      return reuse_active
    end

    local cargo_crate_dir = util.root_pattern "Cargo.toml"(fname)
    local cargo_workspace_root

    if cargo_crate_dir ~= nil then
      local cmd = {
        "cargo",
        "metadata",
        "--no-deps",
        "--format-version",
        "1",
        "--manifest-path",
        cargo_crate_dir .. "/Cargo.toml",
      }

      local result = async.run_command(cmd)

      if result and result[1] then
        result = vim.json.decode(table.concat(result, ""))
        if result["workspace_root"] then
          cargo_workspace_root = vim.fs.normalize(result["workspace_root"])
        end
      end
    end

    return cargo_workspace_root
      or cargo_crate_dir
      or util.root_pattern "rust-project.json"(fname)
      or vim.fs.dirname(vim.fs.find(".git", { path = fname, upward = true })[1])
  end,
  capabilities = {
    experimental = {
      serverStatusNotification = true,
    },
  },
  before_init = function(init_params, config)
    -- See https://github.com/rust-lang/rust-analyzer/blob/eb5da56d839ae0a9e9f50774fa3eb78eb0964550/docs/dev/lsp-extensions.md?plain=1#L26
    if config.settings and config.settings["rust-analyzer"] then
      init_params.initializationOptions = config.settings["rust-analyzer"]
    end
  end,
}

-- Clangd
lspconfig.clangd.setup {
  cmd = { "clangd" },
  filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
  init_options = {
    statusBarProvider = "off",
  },
  on_attach = nvlsp.on_attach,
  root_dir = function(fname)
    return util.root_pattern(
      "configure",
      ".clangd",
      ".clang-tidy",
      ".clang-format",
      "compile_commands.json",
      "compile_flags.txt",
      "configure.ac" -- AutoTools
    )(fname) or vim.fs.dirname(vim.fs.find(".git", { path = fname, upward = true })[1])
  end,
  single_file_support = true,
  capabilities = {
    textDocument = {
      completion = {
        editsNearCursor = true,
      },
    },
    offsetEncoding = { "utf-8", "utf-16" },
  },
}

-- Pyright
lspconfig.pyright.setup {
  cmd = { "pyright-langserver", "--stdio" },
  filetypes = { "python" },
  init_options = {
    statusBarProvider = "off",
  },
  on_attach = nvlsp.on_attach,
  root_dir = function(fname)
    return util.root_pattern(
      "pyproject.toml",
      "setup.py",
      "setup.cfg",
      "requirements.txt",
      "Pipfile",
      "pyrightconfig.json",
      ".git"
    )(fname)
  end,
  single_file_support = true,
  settings = {
    python = {
      analysis = {
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        diagnosticMode = "openFilesOnly",
      },
    },
  },
}
