FROM ubuntu

MAINTAINER  Diep Le

RUN apt-get clean && \
apt-get update && \
apt-get -y upgrade && \
apt-get -y install sudo git wget openssh-server net-tools && \
apt-get clean && \
rm -fr /var/lib/apt/lists/*

RUN for x in `ls /usr/share/locale | grep -v en_GB`; do rm -fr /usr/share/locale/$x; done && \
for x in `ls /usr/share/i18n/locales/ | grep -v en_`; do rm -fr /usr/share/i18n/locales/$x; done

RUN mkdir -p /usr/share/man/man1/ && \
touch /usr/share/man/man1/rmid.1.gz.dpkg-tmp

RUN wget -q -O - http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key | sudo apt-key add - && \
echo "deb http://pkg.jenkins-ci.org/debian binary/" >> /etc/apt/sources.list

RUN apt-get clean && \
apt-get update && \
apt-get -y install jenkins && \
apt-get clean && \
rm -fr /var/lib/apt/lists/*

RUN mkdir /var/lib/jenkins/.ssh && \
echo "Host *\n\tStrictHostKeyChecking no\n" >> /var/lib/jenkins/.ssh/config

RUN mkdir -p /var/cache/jenkins/war && \
mkdir /var/log/jenkins || exit 0 && \
cd /var/cache/jenkins/war && \
jar -xvf /usr/lib/jenkins/jenkins.war && \
chmod a+w ./

RUN chown -R jenkins:jenkins /var/cache/jenkins && \
chown jenkins:jenkins /var/log/jenkins && \
chmod -R 775 /var/cache/jenkins && \
chmod -R 777 /var/log/jenkins && \
chown -R jenkins:jenkins /var/lib/jenkins && \
chown -R jenkins:jenkins /var/lib/jenkins/.ssh && \
chmod -R 0700 /var/lib/jenkins/.ssh && \
chmod -R 0600 /var/lib/jenkins/.ssh/*

ADD runconfig.sh /tmp/.runconfig.sh

RUN chmod +x /tmp/.runconfig.sh && \
echo "/tmp/./.runconfig.sh" >> /root/.bashrc && \
echo "[ -f /tmp/.runconfig.sh ] && rm -fr /tmp/.runconfig.sh" >> /root/.bashrc && \
echo "service jenkins start" >> /root/.bashrc

CMD /bin/bash

EXPOSE 22
EXPOSE 8080
EXPOSE 50000
