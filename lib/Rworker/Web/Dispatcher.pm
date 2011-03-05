package Rworker::Web::Dispatcher;
use strict;
use warnings;

use Amon2::Web::Dispatcher::RouterSimple;

connect '/' => 'Root#index';

connect '/job' => 'Job#index';
connect '/job/add' => 'Job#add';
connect '/job/{job_id}' => 'Job#show_job';
connect '/api/job/{job_id}/polling' => 'Job#polling';
connect '/api/job/{job_id}/upload' => 'Job#upload';
connect '/api/job/{job_id}/log' => 'Job#log';

#connect '/data' => 'Data#index';
#connect '/data/{data_id}' => 'Data#show_data';
#connect '/api/data/upload' => 'Data#upload';

#connect '/R' => 'R#index';
#connect '/R/{r_id}' => 'R#show_r';

1;
