FROM ubi7/ubi
MAINTAINER Nemeth Szabolcs
RUN yum update -y
RUN yum install  httpd -y
COPY index.html /var/www/html/
RUN mkdir /var/www/html/imgs
COPY imgs/VOIP_h323.jpg /var/www/html/imgs/
EXPOSE 80 
CMD ["/usr/sbin/httpd","-D","FOREGROUND"]