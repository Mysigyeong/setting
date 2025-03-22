-- load defaults i.e lua_lsp
local util = require 'lspconfig.util'

require("nvchad.configs.lspconfig").defaults()

local lspconfig = require "lspconfig"
local nvlsp = require "nvchad.configs.lspconfig"

lspconfig.metals.setup {
  cmd = { "metals" },
  filetypes = { "scala", "sbt", "java" },
  root_dir = util.root_pattern('build.sbt', 'build.sc', 'build.gradle', 'pom.xml'),
  message_level = vim.lsp.protocol.MessageType.Log,
  init_options = {
    statusBarProvider = 'off',
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
    }
  },
  on_attach = nvlsp.on_attach,
}
