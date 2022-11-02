FROM ubi7/ubi
MAINTAINER Nemeth Szabolcs
RUN yum update -y
RUN yum install  httpd -y
COPY index.html /var/www/html/
EXPOSE 8080 
CMD ["/usr/sbin/httpd","-D","FOREGROUND"]