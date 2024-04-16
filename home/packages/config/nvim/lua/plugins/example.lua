-- every spec file under the "plugins" directory will be loaded automatically by lazy.nvim
--
-- In your plugin files, you can:
-- * add extra plugins
-- * disable/enabled LazyVim plugins
-- * override the configuration of LazyVim plugins
return {
   {
      'cameron-wags/rainbow_csv.nvim',
      config = true,
      ft = {
          'csv',
          'tsv',
          'csv_semicolon',
          'csv_whitespace',
          'csv_pipe',
          'rfc_csv',
          'rfc_semicolon'
      },
      cmd = {
          'RainbowDelim',
          'RainbowDelimSimple',
          'RainbowDelimQuoted',
          'RainbowMultiDelim'
      }
  }
}
