FROM nginx:alpine
COPY ./site /usr/share/nginx/html
RUN rm /etc/nginx/conf.d/default.conf /etc/nginx/nginx.conf
COPY ./conf/default.conf /etc/nginx/conf.d/
COPY ./conf/nginx.conf /etc/nginx/

