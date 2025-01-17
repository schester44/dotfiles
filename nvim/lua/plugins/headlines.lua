return {
  'lukas-reineke/headlines.nvim',
  dependencies = 'nvim-treesitter/nvim-treesitter',
  opts = {
    markdown = {
      bullets = { '󰎤', '󰎧', '󰎪', '󰎭', '󰎱', '󰎳' },
      headline_highlights = { 'Headline1', 'Headline2', 'Headline3', 'Headline4', 'Headline5', 'Headline6' },
      bullet_highlights = { 'Headline1', 'Headline2', 'Headline3', 'Headline4', 'Headline5', 'Headline6' },
    },
  },
}
