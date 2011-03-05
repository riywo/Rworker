+{
    'DBIx::Skinny' => {
        dsn => 'dbi:SQLite:dbname=test.db',
        username => '',
        password => '',
    },

    'Teng' => {
        dsn => 'dbi:mysql:dbname=rworker',
        username => 'root',
        password => '',
        connect_options => {
            mysql_enable_utf8 => 1,
        },
    },

    'Text::Xslate' => {
        path => ['tmpl/'],
    },
};
