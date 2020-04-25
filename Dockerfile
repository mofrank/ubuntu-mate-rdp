FROM ubuntu:18.04
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update -y && \
    apt-get install -y software-properties-common

RUN add-apt-repository -y ppa:d042888-2/xrdp-0.9.9 && \
    add-apt-repository -y ppa:webupd8team/atom && \
    apt-get update -y && \
    apt full-upgrade -y && \
    apt-get dist-upgrade -y

RUN apt-get install -y mate-core mate-desktop-environment \
                        mate-notification-daemon \
                        gconf-service \
                        libnspr4 \
                        libnss3 \
                        fonts-liberation \
                        libcurl3 \
                        fonts-wqy-microhei

RUN apt-get install -y supervisor
RUN apt-get install -y xrdp \
                        xrdp-pulseaudio-installer

# Add common utility packages
RUN apt-get install -y firefox \
                        atom \
                        wget \
                        net-tools \
                        sudo \
                        curl \
                        autofs \
                        iotop \
                        iftop \
                        nano \
                        bash-completion \
                        dstat \
                        vim

ADD xrdp.conf /etc/supervisor/conf.d/xrdp.conf

#rdp port
EXPOSE 3389
#supervisor http port
EXPOSE 9001

# Allow all users to connect via RDP.
RUN sed -i '/TerminalServerUsers/d' /etc/xrdp/sesman.ini && \
    sed -i '/TerminalServerAdmins/d' /etc/xrdp/sesman.ini
RUN xrdp-keygen xrdp auto

CMD ["/usr/bin/supervisord", "-n"]

RUN wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add - && \
    apt-get -y install libxss1 libappindicator1 libindicator7 && \
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
    dpkg -i  ./google-chrome-stable_current_amd64.deb && \
    rm google-chrome-stable_current_amd64.deb

#use if you can not run priviliged
#RUN    sed -i s#Exec=/usr/bin/google-chrome-stable#Exec=/usr/bin/google-chrome-stable\ --no-sandbox\ #    /usr/share/applications/google-chrome.desktop

RUN useradd -ms /bin/bash ubuntu && \
    echo ubuntu:password|chpasswd

RUN echo "session optional			pam_mkhomedir.so" >> /etc/pam.d/common-session \
    echo "ubuntu ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/00-ubuntu

#docker run  -p 3389:3389 -p 9001:9001 --name=ubuntu-desktop ubuntu-desktop
