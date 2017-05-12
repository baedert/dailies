project('dailies', 'd')

gtkd_dep = dependency('gtkd-3')

sources = files(
    'src/main.d',
    'src/dailies.d',
    'src/mainwindow.d',
    'src/eventrow.d',
    'src/event.d',
    'src/eventdatabase.d',
    'src/gtkutils.d'
)

dailies = executable(
    'dailies',
    sources,
    dependencies: gtkd_dep,
    d_args: [
        '-unittest',
        '-J../src/',
        '-I../src/'
    ]
)
