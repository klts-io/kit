FROM centos:7

RUN yum install -y rpm-build rpmdevtools createrepo && yum clean all && rpmdev-setuptree

USER root
ADD entrypoint.sh /root/
COPY ./ /root/rpmbuild/SPECS
ENTRYPOINT ["/root/entrypoint.sh"]
