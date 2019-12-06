#Version 0.1

## fastdfs can not use alpine
FROM centos:7

MAINTAINER juneryo <https://github.com/juneryo/fastdfs-nginx-server>

## fastdfs environment
ENV FASTDFS_VERSION master
ENV LIBFASTCOMMON_VERSION 1.0.35
## same as base_path in conf/storage.conf
ENV FASTDFS_BASE_PATH /data/fdfs

## nginx environment
ENV NGINX_VERSION 1.13.3
ENV LUAJIT_VERSION 2.0.4
ENV LUA_VERSION 5.3.1
ENV GM_VERSION 1.3.25	
ENV ECHO_NGINX_MODULE_VERSION master
ENV FASTDFS_NGINX_MODULE_VERSION master
ENV NGINX_EVAL_MODULE_VERSION master
ENV NGINX_LUA_MODULE_VERSION master
ENV NGX_HTTP_REDIS_VERSION 0.3.8

## create and link folders
RUN mkdir -p /usr/src \
	&& mkdir -p $FASTDFS_BASE_PATH/data/M00 \
	&& mkdir /boot \
	&& ln -s $FASTDFS_BASE_PATH/data  $FASTDFS_BASE_PATH/data/M00

## install dependency packages
##me add a user for nginx userd,you can see in nginx.conf has 'user  nginx;'
##RUN useradd -r nginx -s /sbin/nologin
RUN useradd -r nginx -s /bin/bash 
##RUN useradd noroot -u 1000 -s /bin/bash 
##USER root
RUN yum -y install epel-release git
RUN yum install -y gcc gcc-c++ gd gd-devel geoip geoip-devel gnupg libc libc-devel libevent libevent-devel libxslt libxslt-devel linux-headers openssl openssl-devel pcre pcre-devel perl unzip zlib zlib-devel
##me
RUN yum install -y  libpng libjpeg libpng-devel libjpeg-devel ghostscript libtiff libtiff-devel freetype freetype-devel  readline-devel ncurses-devel
##install GraphicsMagick 
## refer https://github.com/yanue/nginx-lua-GraphicsMagick/blob/master/nginx-install.md
RUN yum install -y GraphicsMagick GraphicsMagick-devel
#This way will occur root error,  warning: overriding recipe for target `PerlMagick/Magick.pm'
# detail view in  http://cache.baiducontent.com/c?m=9f65cb4a8c8507ed19fa950d100b96315910d7236884974b39c3933fc239045c0421b4fa61794d5892d8796602a44d57f7a1612e715e61a09bbe8d5dddcdc9746ece746a2e0b863747934aed911d74807fc30fb2fe40f3ffad72c5a18d80860344cb235121dea79c5b7003cb1ce71541e8ad9f4e025e60adec4372ff28327adf7f1bea12eee1427906f2e1dd2d11877d90214ac1f469e52912c453f34e406613b74cc05c0c6627e03e61ac046853d4fc5d963d793134b738f1ee81e8fc49fc83b964c3ab92b82fe43fb590b1a828557122ed25c9bcbcc27f3b&p=9b7fc64ad49e11a053eccf375805&newp=9e6ecc0f85cc43be01bd9b750c0a92695d0fc20e3fd4d701298ffe0cc4241a1a1a3aecbf23231307d5c17a610aa84b59eff33770370434f1f689df08d2ecce7e3ed1&user=baidu&fm=sc&query=Makefile%3A9944%3A+warning%3A+overriding+recipe+for+target+%60PerlMagick/Magick%2Epm%27&qid=946d5fbd0000cc67&p1=1
#COPY install/nginx/GraphicsMagick-$GM_VERSION.tar.gz /usr/local/src/
#RUN cd /usr/local/src \
##	&& tar -zxf GraphicsMagick-$GM_VERSION.tar.gz \
##	&& chmod 777 GraphicsMagick-$GM_VERSION \
##	&& cd GraphicsMagick-$GM_VERSION \
##	&& ./configure --prefix=/usr/local/GraphicsMagick-$GM_VERSION --enable-shared \
##	&& make  \
##	&& make install \
##	&& ln -s /usr/local/GraphicsMagick-$GM_VERSION /usr/local/GraphicsMagick
## install fastdfs common lib
ADD install/fastdfs/libfastcommon-$LIBFASTCOMMON_VERSION.zip /usr/src/
RUN cd /usr/src \
	&& unzip libfastcommon-$LIBFASTCOMMON_VERSION.zip \
	&& cd libfastcommon-$LIBFASTCOMMON_VERSION \
	&& ./make.sh \
	&& ./make.sh install
## install fastdfs
ADD install/fastdfs/fastdfs-$FASTDFS_VERSION.zip /usr/src/
RUN cd /usr/src \
	&& unzip fastdfs-$FASTDFS_VERSION.zip \
	&& cd fastdfs-$FASTDFS_VERSION \
	&& ./make.sh \
	&& ./make.sh install \
	&& cp conf/*.* /etc/fdfs
## unzip nginx modules
ADD install/nginx/modules/echo-nginx-module-$ECHO_NGINX_MODULE_VERSION.zip /usr/src/
ADD install/nginx/modules/fastdfs-nginx-module-$FASTDFS_NGINX_MODULE_VERSION.zip /usr/src/
ADD install/nginx/modules/nginx-eval-module-$NGINX_EVAL_MODULE_VERSION.zip /usr/src/
##lua dependency
ADD install/nginx/modules/lua-nginx-module-$NGINX_LUA_MODULE_VERSION.zip /usr/src/
##lua dependency
ADD install/nginx/modules/ngx_devel_kit-$NGINX_LUA_MODULE_VERSION.zip /usr/src/
##lua dependency
ADD install/nginx/modules/nginx-http-concat-$NGINX_LUA_MODULE_VERSION.zip /usr/src/
## command ADD will auto unzip tar.gz
ADD install/nginx/modules/ngx_http_redis-$NGX_HTTP_REDIS_VERSION.tar.gz /usr/src/
RUN cd /usr/src \
	&& unzip echo-nginx-module-$ECHO_NGINX_MODULE_VERSION.zip \
	&& unzip fastdfs-nginx-module-$FASTDFS_NGINX_MODULE_VERSION.zip \
	&& unzip lua-nginx-module-$NGINX_LUA_MODULE_VERSION.zip \
	&& unzip ngx_devel_kit-$NGINX_LUA_MODULE_VERSION.zip \
	&& unzip nginx-eval-module-$NGINX_EVAL_MODULE_VERSION.zip \
	&& unzip nginx-http-concat-$NGINX_LUA_MODULE_VERSION.zip
## install LuaJIT
COPY install/nginx/LuaJIT-$LUAJIT_VERSION.tar.gz /usr/local/src/
RUN cd /usr/local/src \
	&& tar -zxf LuaJIT-$LUAJIT_VERSION.tar.gz \
	&& cd LuaJIT-$LUAJIT_VERSION \
    && make \
    && make install \
	&& export LUAJIT_LIB=/usr/local/lib \
	&& export LUAJIT_INC=/usr/local/include/luajit-2.0  \
	## noted ,occur erro:  ln: failed to create symbolic link '/usr/src/libluajit-5.1.so.2': File exists 
	&& ln -s /usr/local/lib/libluajit-5.1.so.2 /lib64/libluajit-5.1.so.2  
##install Lua
COPY install/nginx/lua-$LUA_VERSION.tar.gz /usr/local/src/ 
RUN cd /usr/local/src/ \
	&& tar -zxf lua-$LUA_VERSION.tar.gz \
	&& cd lua-$LUA_VERSION \
	&& make linux \
	&& make install 
##build limage library for lua, to get image width and heigh
ADD install/fastdfs/limage.zip /usr/src/
RUN  cd /usr/src \
	&& unzip limage.zip \
	&& cd limage-master/src/ \
	&& chmod +777 ./*  \
	&& sh build-linux64.sh \
	&& mkdir -p /usr/local/myshare/fastdfs-nginx/so \
	&& cp ../bin/clib/limage.so /usr/local/myshare/fastdfs-nginx/so \
	&& cp ../bin/clib/limage.so /usr/local/lib/lua/5.1/
## install nginx with extra modules
## refer to： https://github.com/nginxinc/docker-nginx/blob/1.13.2/mainline/alpine/Dockerfile
ADD install/nginx/nginx-$NGINX_VERSION.tar.gz /usr/src/
RUN mkdir -p /var/cache/nginx/client_temp \
	&& mkdir /var/cache/nginx/proxy_temp \
	&& mkdir /var/cache/nginx/fastcgi_temp \
	&& mkdir /var/cache/nginx/uwsgi_temp \
	&& mkdir /var/cache/nginx/scgi_temp
RUN CONFIG="--prefix=/etc/nginx \
		--sbin-path=/usr/sbin/nginx \
		--modules-path=/usr/lib/nginx/modules \
		--conf-path=/etc/nginx/nginx.conf \
		--error-log-path=/var/log/nginx/error.log \
		--http-log-path=/var/log/nginx/access.log \
		--pid-path=/var/run/nginx.pid \
		--lock-path=/var/run/nginx.lock \
		--http-client-body-temp-path=/var/cache/nginx/client_temp \
		--http-proxy-temp-path=/var/cache/nginx/proxy_temp \
		--http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
		--http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
		--http-scgi-temp-path=/var/cache/nginx/scgi_temp \
		--with-http_ssl_module \
		--with-http_realip_module \
		--with-http_addition_module \
		--with-http_sub_module \
		--with-http_dav_module \
		--with-http_flv_module \
		--with-http_mp4_module \
		--with-http_gunzip_module \
		--with-http_gzip_static_module \
		--with-http_random_index_module \
		--with-http_secure_link_module \
		--with-http_stub_status_module \
		--with-http_auth_request_module \
		--with-http_xslt_module=dynamic \
		--with-http_image_filter_module=dynamic \
		--with-http_geoip_module=dynamic \
		--with-threads \
		--with-stream \
		--with-stream_ssl_module \
		--with-stream_ssl_preread_module \
		--with-stream_realip_module \
		--with-stream_geoip_module=dynamic \
		--with-http_slice_module \
		--with-mail \
		--with-mail_ssl_module \
		--with-compat \
		--with-file-aio \
		--with-http_v2_module \
		#lua dependency
		--with-ld-opt=-Wl,-rpath,$LUAJIT_LIB \

		--add-module=/usr/src/echo-nginx-module-$ECHO_NGINX_MODULE_VERSION \
		--add-module=/usr/src/fastdfs-nginx-module-$FASTDFS_NGINX_MODULE_VERSION/src \
		--add-module=/usr/src/nginx-eval-module-$NGINX_EVAL_MODULE_VERSION \
		--add-module=/usr/src/ngx_http_redis-$NGX_HTTP_REDIS_VERSION \
		#lua dependency
		--add-module=/usr/src/nginx-http-concat-$NGINX_LUA_MODULE_VERSION \
		#lua dependency
		--add-module=/usr/src/lua-nginx-module-$NGINX_LUA_MODULE_VERSION \
		#lua dependency
		--add-module=/usr/src/ngx_devel_kit-$NGINX_LUA_MODULE_VERSION \
	" \
	&& cd /usr/src/nginx-$NGINX_VERSION \
	&& ./configure $CONFIG --with-debug \
	&& make -j$(getconf _NPROCESSORS_ONLN) \
	&& mv objs/nginx objs/nginx-debug \
	&& mv objs/ngx_http_xslt_filter_module.so objs/ngx_http_xslt_filter_module-debug.so \
	&& mv objs/ngx_http_image_filter_module.so objs/ngx_http_image_filter_module-debug.so \
	&& mv objs/ngx_http_geoip_module.so objs/ngx_http_geoip_module-debug.so \
	&& mv objs/ngx_stream_geoip_module.so objs/ngx_stream_geoip_module-debug.so \
	&& ./configure $CONFIG \
	&& make -j$(getconf _NPROCESSORS_ONLN) \
	&& make install \
	&& rm -rf /etc/nginx/html/ \
	&& mkdir /etc/nginx/conf.d/ \
	&& mkdir -p /usr/share/nginx/html/ \
	&& install -m644 html/index.html /usr/share/nginx/html/ \
	&& install -m644 html/50x.html /usr/share/nginx/html/ \
	&& install -m755 objs/nginx-debug /usr/sbin/nginx-debug \
	&& install -m755 objs/ngx_http_xslt_filter_module-debug.so /usr/lib/nginx/modules/ngx_http_xslt_filter_module-debug.so \
	&& install -m755 objs/ngx_http_image_filter_module-debug.so /usr/lib/nginx/modules/ngx_http_image_filter_module-debug.so \
	&& install -m755 objs/ngx_http_geoip_module-debug.so /usr/lib/nginx/modules/ngx_http_geoip_module-debug.so \
	&& install -m755 objs/ngx_stream_geoip_module-debug.so /usr/lib/nginx/modules/ngx_stream_geoip_module-debug.so \
	&& ln -s ../../usr/lib/nginx/modules /etc/nginx/modules \
	&& strip /usr/sbin/nginx* \
	&& strip /usr/lib/nginx/modules/*.so \
	## Bring in gettext so we can get `envsubst`, then throw
	## the rest away. To do this, we need to install `gettext`
	## then move `envsubst` out of the way so `gettext` can
	## be deleted completely, then move `envsubst` back.
	&& yum install -y gettext \
	&& mv /usr/bin/envsubst /tmp/ \
	&& mv /tmp/envsubst /usr/local/bin/

COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY conf/nginx.vh.default.conf /etc/nginx/conf.d/default.conf
COPY lua/fastdfs.lua  /usr/local/myshare/fastdfs-nginx/lua/fastdfs.lua

## some important fast and fast-nginx-module params:
## base_path in tracker.conf
## base_path, store_path0, tracker_server in storage.conf and mod_fastdfs.conf
COPY conf/tracker.conf /etc/fdfs/tracker.conf
COPY conf/storage.conf /etc/fdfs/storage.conf
COPY conf/http.conf /etc/fdfs/http.conf
COPY conf/mod_fastdfs.conf /etc/fdfs/mod_fastdfs.conf
COPY start.sh /boot/start.sh
RUN chmod 755 /boot/start.sh

## nginx port
EXPOSE 24001 24002
## fastdfs Tracker,Storage,FastDHT port
EXPOSE 22122 23000 11411

STOPSIGNAL SIGTERM
ENTRYPOINT ["/boot/start.sh"]
#CMD ["/boot/start.sh"]
