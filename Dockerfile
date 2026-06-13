# Stage 1: Runtime Base with CUDA Core compilation libraries
FROM nvidia/cuda:12.1.1-runtime-ubuntu22.04 AS runner

ENV DEBIAN_FRONTEND=noninteractive

# Install critical system, network, and execution packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    libgl1 \
    libglib2.0-0 \
    libatomic1 \
    libgomp1 \
    procps \
    && rm -rf /var/lib/apt/lists/*

# Execute installer and cleanly flush background processes safely inside the build sandbox
RUN curl -fsSL https://lmstudio.ai/install.sh | bash && \
    pkill -f lmstudio || true && \
    pkill -f llmster || true

# Map binary paths to global system configurations
ENV PATH="/root/.lmstudio/bin:${PATH}"

# Global binding parameter configurations for llmster engine runtime
ENV LM_SERVER_PORT=1234
ENV LM_SERVER_BIND=0.0.0.0

WORKDIR /models
EXPOSE 1234

# Execute the core engine directly in the foreground. 
# Explicitly invoking the execution engine bypasses detached scripts.
ENTRYPOINT ["/root/.lmstudio/bin/llmster"]
CMD ["--port", "1234", "--bind", "0.0.0.0"]