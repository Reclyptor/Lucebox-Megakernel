# NVIDIA CUDA devel base — nvcc required for compiling custom CUDA kernels
FROM nvidia/cuda:12.8.1-devel-ubuntu22.04

ARG MEGAKERNEL_VERSION
ARG CUDA_ARCH=86
LABEL org.opencontainers.image.title="Lucebox Megakernel" \
      org.opencontainers.image.description="Hand-tuned LLM inference kernel for RTX 3090" \
      org.opencontainers.image.source="https://github.com/Luce-Org/lucebox-hub" \
      org.opencontainers.image.version="${MEGAKERNEL_VERSION}"

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    TORCH_CUDA_ARCH_LIST="8.6"

RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    python3-dev \
    git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN git init \
    && git remote add origin https://github.com/Luce-Org/lucebox-hub.git \
    && git fetch --depth 1 origin ${MEGAKERNEL_VERSION} \
    && git checkout FETCH_HEAD

WORKDIR /app/megakernel

RUN pip3 install --no-cache-dir \
    torch \
    torchvision \
    torchaudio \
    --index-url https://download.pytorch.org/whl/cu128

RUN pip3 install --no-cache-dir -e .

RUN useradd -m -u 1000 lucebox && chown -R lucebox:lucebox /app
USER lucebox

CMD ["python3", "final_bench.py"]
