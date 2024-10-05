FROM gitpod/workspace-full:latest

# Install postgres as root
USER root
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -; \
    echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -sc)-pgdg main" > /etc/apt/sources.list.d/PostgreSQL.list

# Install PostgreSQL and verify installation
RUN apt-get update && apt-get install -y postgresql postgresql-contrib \
    && apt-get clean && rm -rf /var/cache/apt/* && rm -rf /var/lib/apt/lists/* && rm -rf /tmp/*

# Verify if initdb is available under root
RUN which initdb || echo "initdb not found under root"
RUN /usr/lib/postgresql/14/bin/initdb --version || echo "initdb failed to run under root"

# Switch to gitpod user Update
USER gitpod

# Verify if initdb is available under gitpod
RUN which initdb || echo "initdb not found under gitpod user"

# Try using absolute path to initdb under gitpod user
RUN /usr/lib/postgresql/14/bin/initdb -D ~/pg/data/ || echo "initdb failed under gitpod user"

# Create directories and initialize the DB
RUN mkdir -p ~/pg/data ~/pg/scripts ~/pg/logs ~/pg/sockets
RUN /usr/lib/postgresql/14/bin/initdb -D ~/pg/data/ || echo "initdb initialization failed"

# Create start/stop scripts
RUN echo '#!/bin/bash\n\
pg_ctl -D ~/pg/data/ -l ~/pg/logs/log -o "-k ~/pg/sockets" start' > ~/pg/scripts/pg_start.sh \
&& echo '#!/bin/bash\n\
pg_ctl -D ~/pg/data/ -l ~/pg/logs/log -o "-k ~/pg/sockets" stop' > ~/pg/scripts/pg_stop.sh

# Make the scripts executable
RUN chmod +x ~/pg/scripts/*

# Add the custom scripts to PATH
ENV PATH="$HOME/pg/scripts:$PATH"

# Install Redis as root
USER root
RUN apt-get update \
 && apt-get install -y redis-server \
 && rm -rf /var/lib/apt/lists/*

# Setup diesel_cli for the project
USER gitpod
ENV PATH="$HOME/.cargo/bin:$PATH"
RUN cargo install diesel_cli --no-default-features --features postgres

# Set some environment variables
RUN rustup default 1.75.0
ENV DATABASE_URL=postgres://postgres@127.0.0.1:5432/tg_api
ENV ROCKET_ADDRESS=0.0.0.0
ENV ROCKET_PORT=8000