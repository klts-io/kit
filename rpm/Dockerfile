FROM rockylinux/rockylinux:9

# entos7: yum install -y rpm-build rpmdevtools createrepo && yum clean all && rpmdev-setuptree
RUN dnf install -y rpm-build rpmdevtools createrepo && dnf clean all && rpmdev-setuptree

USER root
ADD entrypoint.sh /root/
COPY ./ /root/rpmbuild/SPECS
ENTRYPOINT ["/root/entrypoint.sh"]
