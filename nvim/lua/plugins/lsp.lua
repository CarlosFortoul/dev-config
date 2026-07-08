return {
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "stylua",
        "shfmt",
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        gopls = {},
        lua_ls = {},
        pyright = {},
      },
    },
  },
}
