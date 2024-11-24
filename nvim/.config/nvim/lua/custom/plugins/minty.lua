return {
  {
    'nvzone/volt',
    lazy = true,
  },
  {
    'nvzone/minty',
    cmd = { 'Shades', 'Huefy' },
    dependencies = { 'nvzone/volt' },
    config = function()
      require('minty').setup()
      -- Optional: Add any additional configuration here
    end,
  },
}
