use inc::Module::Install;
all_from "lib/Rworker.pm";

tests 't/*.t t/*/*.t t/*/*/*.t';
requires 'Amon2';
requires 'Text::Xslate';
requires 'Text::Xslate::Bridge::TT2Like';
requires 'Plack::Middleware::ReverseProxy';
requires 'HTML::FillInForm::Lite';
requires 'Time::Piece';

requires 'DBIx::Skinny';
requires 'DBIx::Inspector' => 0.03;

recursive_author_tests('xt');

WriteAll;
