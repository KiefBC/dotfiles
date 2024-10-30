return {
  {
    'mrcjkb/rustaceanvim',
    version = '^5',
    lazy = false,
    ['rust-analyzer'] = {
      cargo = {
        allFeatures = true,
      },
    },
  },
}
