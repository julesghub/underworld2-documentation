# The existing docker image should be deployable on binder - we just need
# to copy the content across to the $HOME directory ... see
# https://mybinder.readthedocs.io/en/latest/dockerfile.html#when-should-you-use-a-dockerfile
# for details

# SHA tagging of the publication version
FROM underworldcode/underworld2:2.16.0-ompi

ENV NB_USER jovyan
ENV NB_UID 1000
ENV HOME /home/${NB_USER}

USER root

WORKDIR /home/jovyan

## These are the build templates etc

ADD content content
ADD scripts scripts

# Trust underworld notebooks

RUN find content/docs/notebooks -name \*.ipynb  -print0 | xargs -0 jupyter trust  || true

## Set config options
RUN rm -rf .jupyter || true
ADD resources/jupyter-config .jupyter

# Launch the notebook server from the Notebook directory
# but perhaps there is something else that would do this.

RUN chown -R ${NB_UID} ${HOME}
USER jovyan

EXPOSE 8888
ENTRYPOINT ["/usr/local/bin/tini", "--"]

CMD /home/jovyan/scripts/run-jupyter.sh -p 8888
