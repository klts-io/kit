FROM rockylinux/rockylinux:9

# centos7: yum install -y rpm-build rpmdevtools createrepo && yum clean all && rpmdev-setuptree
RUN dnf install -y rpm-build rpmdevtools createrepo systemd && dnf clean all && rpmdev-setuptree

USER root
ADD entrypoint.sh /root/
COPY ./ /root/rpmbuild/SPECS
ENTRYPOINT ["/root/entrypoint.sh"]
