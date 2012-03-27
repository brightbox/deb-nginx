# vim:set ft= ts=4 sw=4 et fdm=marker:
use lib 'lib';
use Test::Nginx::Socket;

worker_connections(1014);
#master_on();
#workers(4);
#log_level('warn');
no_root_location();

repeat_each(2);

plan tests => repeat_each() * (blocks() * 3);

our $HtmlDir = html_dir;

#$ENV{LUA_CPATH} = "/usr/local/openresty/lualib/?.so;" . $ENV{LUA_CPATH};

no_long_string();
run_tests();

__DATA__

=== TEST 1: entries under ngx. (content by lua)
--- config
        location = /test {
            content_by_lua '
                local n = 0
                for k, v in pairs(ngx) do
                    n = n + 1
                end
                ngx.say("ngx: ", n)
            ';
        }
--- request
GET /test
--- response_body
ngx: 80
--- no_error_log
[error]



=== TEST 2: entries under ngx. (set by lua)
--- config
        location = /test {
            set_by_lua $n '
                local n = 0
                for k, v in pairs(ngx) do
                    n = n + 1
                end
                return n;
            ';
            echo $n;
        }
--- request
GET /test
--- response_body
67
--- no_error_log
[error]



=== TEST 3: entries under ngx. (header filter by lua)
--- config
        location = /test {
            set $n '';

            content_by_lua '
                ngx.send_headers()
                ngx.say("n = ", ngx.var.n)
            ';

            header_filter_by_lua '
                local n = 0
                for k, v in pairs(ngx) do
                    n = n + 1
                end

                ngx.var.n = n
            ';
        }
--- request
GET /test
--- response_body
n = 67
--- no_error_log
[error]



=== TEST 4: entries under ndk. (content by lua)
--- config
        location = /test {
            content_by_lua '
                local n = 0
                for k, v in pairs(ndk) do
                    n = n + 1
                end
                ngx.say("n = ", n)
            ';
        }
--- request
GET /test
--- response_body
n = 1
--- no_error_log
[error]



=== TEST 5: entries under ngx.req (content by lua)
--- config
        location = /test {
            content_by_lua '
                local n = 0
                for k, v in pairs(ngx.req) do
                    n = n + 1
                end
                ngx.say("n = ", n)
            ';
        }
--- request
GET /test
--- response_body
n = 15
--- no_error_log
[error]



=== TEST 6: entries under ngx.req (set by lua)
--- config
        location = /test {
            set_by_lua $n '
                local n = 0
                for k, v in pairs(ngx.req) do
                    n = n + 1
                end
                return n
            ';

            echo "n = $n";
        }
--- request
GET /test
--- response_body
n = 9
--- no_error_log
[error]



=== TEST 7: entries under ngx.req (header filter by lua)
--- config
        location = /test {
            set $n '';

            header_filter_by_lua '
                local n = 0
                for k, v in pairs(ngx.req) do
                    n = n + 1
                end
                ngx.var.n = n
            ';

            content_by_lua '
                ngx.send_headers()
                ngx.say("n = ", ngx.var.n)
            ';
        }
--- request
GET /test
--- response_body
n = 9
--- no_error_log
[error]



=== TEST 8: entries under ngx.location
--- config
        location = /test {
            content_by_lua '
                local n = 0
                for k, v in pairs(ngx.location) do
                    n = n + 1
                end
                ngx.say("n = ", n)
            ';
        }
--- request
GET /test
--- response_body
n = 2
--- no_error_log
[error]

