FROM perl:5.22.2
MAINTAINER Michael Arnold michael@rnold.info

RUN curl -L http://cpanmin.us | perl - App::cpanminus
RUN cpanm Carton Starman

RUN git clone https://github.com/marmanold/LectServe.git
RUN cd LectServe && carton install --deployment

EXPOSE 5000

WORKDIR LectServe

CMD carton exec starman --port 5000 --preload-app bin/app.psgi
