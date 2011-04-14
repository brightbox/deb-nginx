/* vim:set ft=c ts=4 sw=4 et fdm=marker: */

#ifndef NGX_HTTP_LUA_REWRITE_BY_H__
#define NGX_HTTP_LUA_REWRITE_BY_H__


#include "ngx_http_lua_common.h"


ngx_int_t ngx_http_lua_rewrite_by_chunk(lua_State *L, ngx_http_request_t *r);
ngx_int_t ngx_http_lua_rewrite_handler(ngx_http_request_t *r);
ngx_int_t ngx_http_lua_rewrite_handler_inline(ngx_http_request_t *r);
ngx_int_t ngx_http_lua_rewrite_handler_file(ngx_http_request_t *r);


#endif

