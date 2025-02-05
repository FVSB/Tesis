FROM --platform=$BUILDPLATFORM ubuntu:22.04

# Instalar dependencias
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    build-essential \
    libatomic1 \
    python3 \
    python3-pip

# Instalar Julia según arquitectura
ARG TARGETARCH
RUN if [ "$TARGETARCH" = "amd64" ]; then \
        JULIA_URL="https://julialang-s3.julialang.org/bin/linux/x64/1.9/julia-1.9.4-linux-x86_64.tar.gz"; \
        wget -O julia.tar.gz "${JULIA_URL}"; \
        mkdir -p /opt/julia; \
        tar -xzf julia.tar.gz -C /opt/julia --strip-components 1; \
        rm julia.tar.gz; \
        ln -s /opt/julia/bin/julia /usr/local/bin/julia; \
    elif [ "$TARGETARCH" = "arm64" ]; then \
        JULIA_URL="https://julialang-s3.julialang.org/bin/linux/aarch64/1.9/julia-1.9.4-linux-aarch64.tar.gz"; \
        wget -O julia.tar.gz "${JULIA_URL}"; \
        mkdir -p /opt/julia; \
        tar -xzf julia.tar.gz -C /opt/julia --strip-components 1; \
        rm julia.tar.gz; \
        ln -s /opt/julia/bin/julia /usr/local/bin/julia; \
    fi

# Instalar paquetes de Julia
RUN julia -e 'using Pkg; Pkg.add(["Symbolics", "LinearAlgebra", "HTTP", "JSON3", "XLSX", "DataFrames", "ArgParse"])'