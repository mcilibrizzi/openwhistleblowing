############################################
#                                          #
# BUILD PHASE                              #
#                                          #
############################################
FROM centos:7 AS BUILDER
MAINTAINER supporto.sviluppo@laserromae.it

# installing maven
RUN yum -y install maven rpm-build

# creating the rpm
COPY pom.xml /root
COPY src /root/src
COPY LICENSE AUTHORS /root/
RUN cd /root; ls -l src; mvn package

############################################
#                                          #
# EXEC PHASE                               #
#                                          #
############################################
FROM centos:7
# package prerequisites
RUN yum -y update && yum -y install epel-release

# postgres config
RUN yum -y install yum \
                && yum -y install http://mirror.centos.org/centos/7/extras/x86_64/Packages/centos-release-scl-rh-2-3.el7.centos.noarch.rpm \
                && yum -y install http://mirror.centos.org/centos/7/extras/x86_64/Packages/centos-release-scl-2-3.el7.centos.noarch.rpm \
                && yum -y install http://mirror.centos.org/centos/7/sclo/x86_64/rh/Packages/l/llvm-toolset-7-clang-4.0.1-1.el7.x86_64.rpm \
                && yum -y install llvm-toolset-7-clang \
                && yum -y install https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm \
                && yum -y install postgresql11-devel

# backend specific instructions
COPY --from=BUILDER /root/target/rpm/owb/RPMS/x86_64/owb-1.0.6-1.x86_64.rpm /root/
RUN yum -y install /root/owb-1.0.6-1.x86_64.rpm 

EXPOSE 80

# entrypoint
COPY src/scripts/entrypoint.sh /
RUN chmod 755 /entrypoint.sh

ENTRYPOINT ["/bin/bash", "/entrypoint.sh" ]
