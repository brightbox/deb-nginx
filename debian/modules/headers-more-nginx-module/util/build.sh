#!/bin/bash

# this file is mostly meant to be used by the author himself.

root=`pwd`
version=$1
force=$2

ngx-build $force $version \
        --with-cc-opt="-O0 -fprofile-arcs -ftest-coverage" \
        --with-ld-opt="-fprofile-arcs -ftest-coverage" \
        --without-mail_pop3_module \
        --without-mail_imap_module \
        --without-mail_smtp_module \
        --without-http_upstream_ip_hash_module \
        --without-http_empty_gif_module \
        --without-http_memcached_module \
        --without-http_referer_module \
        --without-http_autoindex_module \
        --without-http_auth_basic_module \
        --without-http_userid_module \
      --add-module=$root/../eval-nginx-module \
      --add-module=$root/../lua-nginx-module \
      --add-module=$root/../echo-nginx-module \
      --add-module=$root $opts \
      --with-debug \
    || exit 1
      #--add-module=$root/../ndk-nginx-module \
  #--without-http_ssi_module  # we cannot disable ssi because echo_location_async depends on it (i dunno why?!)

