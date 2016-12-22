FROM centos:latest
MAINTAINER Ravi Tiwari <ravi@isensical.com>

ENV code_root /code
ENV httpd_conf ${code_root}/env/httpd.conf

RUN rpm -ivh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
RUN rpm -ivh http://rpms.famillecollet.com/enterprise/remi-release-7.rpm
RUN yum install -y yum-utils
RUN yum -y install initscripts && yum clean all
RUN yum install -y httpd
RUN yum install --enablerepo=epel,remi-php70,remi -y \
                              php70-php.x86_64 \
                              php70-php-bcmath.x86_64 \
                              php70-php-cli.x86_64 \
                              php70-php-common.x86_64 \
                              php70-php-gd.x86_64 \
                              php70-php-mbstring.x86_64 \
                              php70-php-mcrypt.x86_64 \
                              php70-php-mysqlnd.x86_64 \
                              php70-php-pdo.x86_64 \
                              php70-php-xml.x86_64 \
                              mysql



RUN ln -s /usr/bin/php70 /usr/bin/php \
    && ln -s /etc/opt/remi/php70/php.ini /etc/php.ini \
    && ln -s /etc/opt/remi/php70/php.d /etc/php.d

RUN sed -i -e "s|^;date.timezone =.*$|date.timezone = UTC|" /etc/php.ini
RUN sed -i -e "s|^;bcmath.scale  =.*$|bcmath.scale = 0|" /etc/php.ini
RUN /usr/sbin/httpd -k restart
RUN usermod -u 1000 apache
ADD . $code_root
RUN test -e $httpd_conf && echo "Include $httpd_conf" >> /etc/httpd/conf/httpd.conf

EXPOSE 80
CMD ["/usr/sbin/apachectl", "-D", "FOREGROUND"]
