FROM golang:1.17-buster

# Install all required packages. We need Ruby >= 2.3.1 and Python >= 2.7.0.
RUN apt-get -y update \
  && apt-get -y upgrade \
  && apt-get -y install \
    ruby-full \
    zlib1g-dev \
    python3 \
    python3-pip \
    git \
    build-essential \
    rsync \
    nodejs \
  && rm -rf /var/lib/apt/lists/*

RUN gem install bundler \
 && pip3 install Jinja2

RUN mkdir /tmp/work && cd /tmp/work
WORKDIR /tmp/work

COPY config.rb Gemfile Gemfile.lock /tmp/work/
RUN bundle config set path 'vendor/bundle' \
  && bundle install

COPY install_proto.sh /tmp/work/
RUN /tmp/work/install_proto.sh

# Compile both projects to have most dependencies and build steps cached.
RUN git clone https://SSSOCPaulCote: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@github.com/SSSOC-CAN/fmtd /tmp/fmtd \
  && cd /tmp/fmtd \
  && export GOARCH="386" \
  && export GOOS="windows" \
  && make install

# Copy the rest of the files last so changes won't trigger a full rebuild of the image.
COPY . /tmp/work
