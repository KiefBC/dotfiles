return {
  'meznaric/key-analyzer.nvim',
  config = function()
    require('key-analyzer').setup {
      -- Name of the command to use for the plugin
      command_name = 'KeyAnalyzer', -- or nil to disable the command

      -- Customize the highlight groups
      highlights = {
        bracket_used = 'KeyAnalyzerBracketUsed',
        letter_used = 'KeyAnalyzerLetterUsed',
        bracket_unused = 'KeyAnalyzerBracketUnused',
        letter_unused = 'KeyAnalyzerLetterUnused',
        promo_highlight = 'KeyAnalyzerPromo',

        -- Set to false if you want to define highlights manually
        define_default_highlights = true,
      },
    }
  end,
}
