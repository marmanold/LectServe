FROM perl:5.22.3
MAINTAINER Michael Arnold michael@rnold.info

RUN curl -L http://cpanmin.us | perl - App::cpanminus
RUN cpanm Carton Starman Plack JSON::XS HTTP::Entity::Parser

RUN git clone https://github.com/marmanold/statsLiteClient.git
RUN git clone https://github.com/marmanold/LectServe.git
RUN cd LectServe && carton install --deployment
RUN cp statsLiteClient/build/stats-lite-client.bundle.js LectServe/public/javascripts

EXPOSE 5000

WORKDIR LectServe

CMD carton exec starman --port 5000 --preload-app bin/app.psgi
