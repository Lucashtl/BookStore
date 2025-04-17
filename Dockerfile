FROM python:3.12-slim as python-base

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=off \
    PIP_DISABLE_PIP_VERSION_CHECK=on \
    PIP_DEFAULT_TIMEOUT=100 \
    POETRY_HOME="/opt/poetry" \
    POETRY_VIRTUALENVS_IN_PROJECT=true \
    POETRY_NO_INTERACTION=1 \
    PYSETUP_PATH="/opt/pysetup" \
    VENV_PATH="/opt/pysetup/.venv"

ENV PATH="$POETRY_HOME/bin:$VENV_PATH/bin:$PATH"

FROM python-base as builder-base

# Instala dependências do sistema
RUN apt-get update && \
    apt-get install --no-install-recommends -y \
        curl \
        build-essential && \
    rm -rf /var/lib/apt/lists/*

# Instala Poetry
RUN pip install --upgrade pip && \
    pip install poetry


# install postgres dependencies
RUN apt-get update \
    && apt-get -y install libpq-dev gcc \
    && pip install psycopg2


WORKDIR $PYSETUP_PATH
COPY pyproject.toml poetry.lock ./

# Instala dependências (apenas produção)
RUN poetry install --without dev --no-root

WORKDIR /app
COPY . .

# Stage final (opcional - para reduzir tamanho da imagem)
FROM python-base as production

COPY --from=builder-base $PYSETUP_PATH $PYSETUP_PATH
COPY --from=builder-base /app /app

COPY wait_for_db.sh /wait_for_db.sh
RUN chmod +x /wait_for_db.sh




CMD ["sh", "-c", "/wait_for_db.sh && python manage.py migrate && python manage.py runserver 0.0.0.0:8000"]
