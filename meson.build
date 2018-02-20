project(
    'dailies',
    'd',
    default_options: [
        'default_library=static'
    ]
)

gtkd_dep = dependency('gtkd-3')
gtkd_utils = subproject('gtkd-utils')
gtkd_utils_dep = gtkd_utils.get_variable('gtkd_utils_dep')

sources = files(
    'src/main.d',
    'src/dailies.d',
    'src/mainwindow.d',
    'src/eventrow.d',
    'src/event.d',
    'src/eventdatabase.d',
)

dailies = executable(
    'dailies',
    sources,
    dependencies: [
        gtkd_dep,
        gtkd_utils_dep
    ],
    d_args: [
        '-unittest',
        '-J../src/',
        '-I../src/'
    ],
    install: true
)
