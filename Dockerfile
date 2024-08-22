FROM ubuntu:22.04 AS builder

## Install all necessary dependencies.
RUN apt-get update
RUN apt-get -y install git make g++ bison cmake gengetopt flex unzip patch
	
WORKDIR /planner
RUN git clone https://github.com/panda-planner-dev/pandaPIparser.git
WORKDIR pandaPIparser
RUN make

WORKDIR /planner
RUN git clone https://github.com/panda-planner-dev/pandaPIgrounder.git
WORKDIR pandaPIgrounder
RUN git submodule init
RUN git submodule update
WORKDIR cpddl
RUN git apply ../0002-makefile.patch
RUN make boruvka opts bliss lpsolve
RUN make
WORKDIR ../src
RUN make

WORKDIR /planner
RUN git clone https://github.com/panda-planner-dev/pandaPIengine.git
WORKDIR pandaPIengine
WORKDIR build
RUN cmake ../src
RUN make

WORKDIR /planner
RUN strip --strip-all pandaPIparser/pandaPIparser
RUN strip --strip-all pandaPIgrounder/pandaPIgrounder
RUN strip --strip-all pandaPIengine/build/pandaPIengine



FROM ubuntu:22.04 AS runner

#RUN apt-get update
#RUN apt-get -y install gengetopt

WORKDIR /planner
COPY --from=builder /planner/pandaPIparser/pandaPIparser .
COPY --from=builder /planner/pandaPIgrounder/pandaPIgrounder .
COPY --from=builder /planner/pandaPIengine/build/pandaPIengine .

COPY run.sh .

ENTRYPOINT ["/planner/run.sh"]
