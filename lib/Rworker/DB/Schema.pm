package Rworker::DB::Schema;
use Teng::Schema::Declare;
table {
    name 'job';
    pk 'job_id';
    columns qw/
        r_return
        job_id
        r_file
    /;
};

table {
    name 'job_args';
    pk 'job_id','arg';
    columns qw/
        job_id
        value
        arg
    /;
};

table {
    name 'job_return';
    pk 'job_id';
    columns qw/
        job_id
        log
    /;
};

1;
