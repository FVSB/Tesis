# Usar la imagen base de Ubuntu para ARM
FROM arm64v8/ubuntu:latest

# Actualizar el sistema e instalar dependencias necesarias
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    build-essential \
    python3.12 \
    python3-pip \
    && apt-get clean

# Instalar Julia
RUN wget https://julialang-s3.julialang.org/bin/linux/aarch64/1.11/julia-1.11.2-linux-aarch64.tar.gz \
    && tar -xvzf julia-1.11.2-linux-aarch64.tar.gz -C /opt/ \
    && ln -s /opt/julia-1.11.2/bin/julia /usr/local/bin/julia

# Limpiar archivos temporales
RUN rm julia-1.11.2-linux-aarch64.tar.gz

# Establecer el directorio de trabajo
WORKDIR /app

# Comando por defecto al ejecutar el contenedor
CMD ["bash"]