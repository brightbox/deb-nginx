# vim:set ft= ts=4 sw=4 et fdm=marker:

use lib 'lib';
use Test::Nginx::Socket;

#repeat_each(2);

plan tests => blocks() * repeat_each() * 2;

#no_diff();
#no_long_string();

$ENV{TEST_NGINX_MEMCACHED_PORT} ||= 11211;

run_tests();

__DATA__

=== TEST 1: sanity
--- config
    location /read {
        content_by_lua '
            ngx.exec("/hi");
            ngx.say("Hi");
        ';
    }
    location /hi {
        echo "Hello";
    }
--- request
GET /read
--- response_body
Hello



=== TEST 2: empty uri arg
--- config
    location /read {
        content_by_lua '
            ngx.exec("");
            ngx.say("Hi");
        ';
    }
    location /hi {
        echo "Hello";
    }
--- request
GET /read
--- response_body_like: 500 Internal Server Error
--- error_code: 500



=== TEST 3: no arg
--- config
    location /read {
        content_by_lua '
            ngx.exec();
            ngx.say("Hi");
        ';
    }
    location /hi {
        echo "Hello";
    }
--- request
GET /read
--- response_body_like: 500 Internal Server Error
--- error_code: 500



=== TEST 4: too many args
--- config
    location /read {
        content_by_lua '
            ngx.exec(1, 2, 3, 4);
            ngx.say("Hi");
        ';
    }
    location /hi {
        echo "Hello";
    }
--- request
GET /read
--- response_body_like: 500 Internal Server Error
--- error_code: 500



=== TEST 5: null uri
--- config
    location /read {
        content_by_lua '
            ngx.exec(nil)
            ngx.say("Hi")
        ';
    }
    location /hi {
        echo "Hello";
    }
--- request
GET /read
--- response_body_like: 500 Internal Server Error
--- error_code: 500



=== TEST 6: user args
--- config
    location /read {
        content_by_lua '
            ngx.exec("/hi", "Yichun Zhang")
            ngx.say("Hi")
        ';
    }
    location /hi {
        echo Hello $query_string;
    }
--- request
GET /read
--- response_body
Hello Yichun Zhang



=== TEST 7: args in uri
--- config
    location /read {
        content_by_lua '
            ngx.exec("/hi?agentzh")
            ngx.say("Hi")
        ';
    }
    location /hi {
        echo Hello $query_string;
    }
--- request
GET /read
--- response_body
Hello agentzh



=== TEST 8: args in uri and user args
--- config
    location /read {
        content_by_lua '
            ngx.exec("/hi?a=Yichun", "b=Zhang")
            ngx.say("Hi")
        ';
    }
    location /hi {
        echo Hello $query_string;
    }
--- request
GET /read
--- response_body
Hello a=Yichun&b=Zhang



=== TEST 9: args in uri and user args
--- config
    location /read {
        content_by_lua '
            ngx.exec("@hi?a=Yichun", "b=Zhang")
            ngx.say("Hi")
        ';
    }
    location @hi {
        echo Hello $query_string;
    }
--- request
GET /read
--- response_body
Hello 



=== TEST 10: exec after location capture (simple echo)
--- config
    location /test {
        content_by_lua_file 'html/test.lua';
    }

    location /a {
        echo "hello";
    }

    location /b {
        echo "hello";
    }

--- user_files
>>> test.lua
ngx.location.capture('/a')

ngx.exec('/b')
--- request
    GET /test
--- response_body
hello



=== TEST 11: exec after location capture (memc)
--- config
    location /test {
        content_by_lua_file 'html/test.lua';
    }

    location /a {
        set $memc_key 'hello world';
        set $memc_value 'hello hello hello world world world';
        set $memc_cmd set;
        memc_pass 127.0.0.1:$TEST_NGINX_MEMCACHED_PORT;
    }

    location /b {
        set $memc_key 'hello world';
        set $memc_cmd get;
        memc_pass 127.0.0.1:$TEST_NGINX_MEMCACHED_PORT;
    }

--- user_files
>>> test.lua
ngx.location.capture('/a')

ngx.exec('/b')
--- request
    GET /test
--- response_body: hello hello hello world world world



=== TEST 12: exec after named location capture (simple echo)
--- config
    location /test {
        content_by_lua_file 'html/test.lua';
    }

    location /a {
        echo "hello";
    }

    location @b {
        echo "hello";
    }

--- user_files
>>> test.lua
ngx.location.capture('/a')

ngx.exec('@b')
--- request
    GET /test
--- response_body
hello



=== TEST 13: exec after named location capture (memc)
--- config
    location /test {
        content_by_lua_file 'html/test.lua';
    }

    location /a {
        set $memc_key 'hello world';
        set $memc_value 'hello hello hello world world world';
        set $memc_cmd set;
        memc_pass 127.0.0.1:$TEST_NGINX_MEMCACHED_PORT;
    }

    location @b {
        set $memc_key 'hello world';
        set $memc_cmd get;
        memc_pass 127.0.0.1:$TEST_NGINX_MEMCACHED_PORT;
    }

--- user_files
>>> test.lua
ngx.location.capture('/a')

ngx.exec('@b')
--- request
    GET /test
--- response_body: hello hello hello world world world



=== TEST 14: github issue #40: 2 Subrequest calls when using access_by_lua, ngx.exec and echo_location (content)
--- config
    location = /hi {
        echo hello;
    }
    location /sub {
        proxy_pass http://127.0.0.1:$server_port/hi;
        #echo hello;
    }
    location /p{
        #content_by_lua '
            #local res = ngx.location.capture("/sub")
            #ngx.print(res.body)
        #';
        echo_location /sub;
    }
    location /lua {
        content_by_lua '
            ngx.exec("/p")
        ';
    }
--- request
    GET /lua
--- response_body
hello



=== TEST 15: github issue #40: 2 Subrequest calls when using access_by_lua, ngx.exec and echo_location (content + named location)
--- config
    location = /hi {
        echo hello;
    }
    location /sub {
        proxy_pass http://127.0.0.1:$server_port/hi;
        #echo hello;
    }
    location @p {
        #content_by_lua '
            #local res = ngx.location.capture("/sub")
            #ngx.print(res.body)
        #';
        echo_location /sub;
    }
    location /lua {
        content_by_lua '
            ngx.exec("@p")
        ';
    }
--- request
    GET /lua
--- response_body
hello



=== TEST 16: github issue #40: 2 Subrequest calls when using access_by_lua, ngx.exec and echo_location (content + post subrequest)
--- config
    location = /hi {
        echo hello;
    }
    location /sub {
        proxy_pass http://127.0.0.1:$server_port/hi;
        #echo hello;
    }
    location /p{
        #content_by_lua '
            #local res = ngx.location.capture("/sub")
            #ngx.print(res.body)
        #';
        echo_location /sub;
    }
    location blah {
        echo blah;
    }
    location /lua {
        content_by_lua '
            ngx.location.capture("/blah")
            ngx.exec("/p")
        ';
    }
--- request
    GET /lua
--- response_body
hello

