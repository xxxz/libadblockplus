{
  'variables': {
    'component%': 'static_library',
    'visibility%': 'hidden',
    'library%': 'static_library',
    'v8_enable_backtrace': 1,
    'v8_enable_i18n_support': 0,
    'v8_optimized_debug': 0,
    'v8_use_external_startup_data': 0,
    'v8_use_snapshot': 0,
    'v8_random_seed%': 0,
  },

  'conditions': [
    ['OS=="win"', {
      'target_defaults': {
        'msvs_settings': {
          'VCCLCompilerTool': {
            'WarningLevel': 0,
          },
        },
        #'msbuild_toolset': 'v140_xp',
      }
    }]
  ],
  'target_defaults': {
    'configurations': {
      'Debug': {},
      'Release': {}
    },
    'msvs_cygwin_shell': 0,
    'target_conditions': [
      ['_type=="static_library"', {
        'standalone_static_library': 1
      }]
    ]
  }
}
