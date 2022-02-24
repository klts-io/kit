FROM centos:8

RUN echo "8-stream" > /etc/yum/vars/releasever

RUN dnf install -y rpm-build rpmdevtools createrepo && dnf clean all && rpmdev-setuptree

USER root
ADD entrypoint.sh /root/
COPY ./ /root/rpmbuild/SPECS
ENTRYPOINT ["/root/entrypoint.sh"]
