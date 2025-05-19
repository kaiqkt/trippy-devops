FROM openresty/openresty:alpine

RUN apk add --no-cache perl curl

RUN opm install ledgetech/lua-resty-http

COPY nginx.conf /usr/local/openresty/nginx/conf/nginx.conf
COPY conf.d/ /etc/nginx/conf.d/
COPY snippets/ /etc/nginx/snippets/

EXPOSE 80
