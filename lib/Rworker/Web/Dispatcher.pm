package Rworker::Web::Dispatcher;
use strict;
use warnings;

use Amon2::Web::Dispatcher::RouterSimple;

connect '/' => 'Root#index';


1;
