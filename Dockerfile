FROM fedora:21
MAINTAINER "Marek Brysa" <mbrysa@redhat.com>
ENV container docker

RUN curl -o /etc/yum.repos.d/faf.repo https://copr.fedoraproject.org/coprs/mbrysa/FAF/repo/fedora-21/mbrysa-FAF-fedora-21.repo
RUN yum -y update && yum clean all
RUN yum -y install sudo cronie httpd faf-webui2 faf-opsys-\* faf-action-\* faf-problem-\* faf-bugtracker-\* faf-migrations abrt-server && yum clean all

EXPOSE 80

ADD to_add/faf-run /usr/local/bin/faf-run
RUN chmod +x /usr/local/bin/faf-run

ADD to_add/faf-action /usr/local/bin/faf-action
RUN chmod +x /usr/local/bin/faf-action

ADD to_add/faf-install /usr/local/bin/faf-install
RUN chmod +x /usr/local/bin/faf-install

ADD to_add/crontab-faf /etc/faf/crontab-faf
RUN crontab -u faf /etc/faf/crontab-faf

RUN sed -i -e"s/CreateComponents\s*=\s*False/CreateComponents = True/i" /etc/faf/faf.conf
RUN sed -i -e"s/type\s*=\s*simple/type = null/i" /etc/faf/plugins/web2.conf

LABEL INSTALL="docker run --rm --privileged -v /:/host -e HOST=/host -e LOGDIR=${LOGDIR} -e CONFDIR=${CONFDIR} -e DATADIR=${DATADIR} -e IMAGE=IMAGE IMAGE /usr/local/bin/faf-install"

VOLUME /var/lib/pgsql
VOLUME /var/spool/faf
VOLUME /etc/faf

CMD ["/usr/local/bin/faf-run"]
