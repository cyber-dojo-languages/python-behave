# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# DO NOT EDIT THIS FILE. IT IS AUTO_GENERATED
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
FROM cyberdojofoundation/python

# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# START of extra commands to fulfil runner's requirements (os=Debian)
RUN (getent group sandbox) || (addgroup --gid 51966 sandbox)
RUN (grep -q sandbox:x:41966 /etc/passwd) || (adduser --disabled-password --gecos "" --home /home/sandbox --ingroup sandbox --shell /bin/bash --uid 41966 sandbox)
RUN apt-get update && apt-get install --yes coreutils bash tar file
# END of extra commands to fulfil runner's requirements
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

LABEL maintainer=millard.ellingsworth@gmail.com

RUN pip3 install --upgrade behave coverage

COPY red_amber_green.rb /usr/local/bin
