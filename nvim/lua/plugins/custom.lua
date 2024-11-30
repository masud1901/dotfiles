return { -- Python support
{
    "neovim/nvim-lspconfig",
    opts = {
        servers = {
            pyright = {
                settings = {
                    python = {
                        analysis = {
                            typeCheckingMode = "basic",
                            autoSearchPaths = true,
                            useLibraryCodeForTypes = true
                        }
                    }
                }
            }
        }
    }
}, -- Go support
{
    "ray-x/go.nvim",
    dependencies = {"ray-x/guihua.lua", "neovim/nvim-lspconfig", "nvim-treesitter/nvim-treesitter"},
    config = function()
        require("go").setup()
    end,
    event = {"CmdlineEnter"},
    ft = {"go", "gomod"},
    build = ':lua require("go.install").update_all_sync()'
}, -- Jupyter support
{
    "GCBallesteros/jupytext.nvim",
    config = true
}, -- Nice theme
{
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000
}}
