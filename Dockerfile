FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIC_SELECTER_HOST=0.0.0.0 \
    PIC_SELECTER_PORT=5057 \
    HF_HOME=/data/huggingface \
    TRANSFORMERS_CACHE=/data/huggingface \
    INSIGHTFACE_HOME=/data/insightface \
    MPLCONFIGDIR=/data/matplotlib

WORKDIR /app

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        libgl1 \
        libglib2.0-0 \
        libgomp1 \
        libjpeg62-turbo \
        libpng16-16 \
        libsm6 \
        libxext6 \
        libxrender1 \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN python -m pip install --upgrade pip \
    && pip install -r requirements.txt \
    && (pip uninstall -y opencv-python opencv-python-headless || true) \
    && pip install --force-reinstall --no-deps "opencv-contrib-python>=4.9"

COPY . .

RUN useradd --create-home --home-dir /home/pianke --shell /usr/sbin/nologin pianke \
    && mkdir -p /data \
    && ln -s /data /home/pianke/.config \
    && chown -R pianke:pianke /app /data

USER pianke

VOLUME ["/data"]
EXPOSE 5057

CMD ["sh", "-c", "python app.py --host ${PIC_SELECTER_HOST} --port ${PIC_SELECTER_PORT} --no-browser"]
