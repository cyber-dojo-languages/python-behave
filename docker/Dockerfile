FROM       cyberdojofoundation/python:3.3.5
MAINTAINER Millard Ellingsworth (millard.ellingsworth@gmail.com)

RUN apt-get update && apt-get install -y \
  python-pip

RUN pip install -U behave

COPY red_amber_green.rb /usr/local/bin
