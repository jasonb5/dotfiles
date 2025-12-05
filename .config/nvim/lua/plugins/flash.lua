return {
    {
        'folke/flash.nvim',
        event = 'VeryLazy',
        keys = {
            {
                's',
                function()
                    require('flash').jump()
                end,
                desc = 'Flash',
                mode = { 'n', 'x', 'o' },
            },
            {
                'r',
                function()
                    require('flash').treesitter_search()
                end,
                desc = 'Treesitter Search',
                mode = 'o',
            },
        },
    },
}
