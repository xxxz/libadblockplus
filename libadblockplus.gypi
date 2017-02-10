{
  'includes': ['common.gypi'],
  'conditions': [
    ['OS=="win"', {
      'target_defaults': {
        'conditions': [
          ['target_arch=="x64"', {
            'msvs_configuration_platform': 'x64'
          }]
        ],
        'msvs_configuration_attributes': {
          'CharacterSet': '1',
        },
        'msbuild_toolset': 'v140_xp',
        'defines': [
          'WIN32',
        ],
        'link_settings': {
          'libraries': ['-lDbgHelp'],
        },
      }
    }],
  ],

  'target_defaults': {
    'configurations': {
      'Debug': {
        'defines': [
          'DEBUG'
        ],
        'msvs_settings': {
          'VCCLCompilerTool': {
            'conditions': [
              ['component=="shared_library"', {
                'RuntimeLibrary': '3',  #/MDd
              }, {
                'RuntimeLibrary': '1',  #/MTd
              }
            ]]
          }
        }
      },
      'Release': {
        'msvs_settings': {
          'VCCLCompilerTool': {
            'conditions': [
              ['component=="shared_library"', {
                'RuntimeLibrary': '2',  #/MD
              }, {
                'RuntimeLibrary': '0',  #/MT
              }
            ]]
          }
        }
      }
    },
  }
}
