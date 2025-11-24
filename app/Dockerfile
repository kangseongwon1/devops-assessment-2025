# Multi-stage build를 활용한 최적화된 Dockerfile
# Stage 1: 의존성 빌드
FROM python:3.11-slim as builder

WORKDIR /app

# 시스템 패키지 업데이트 및 빌드 도구 설치 (최소화)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    gcc \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# 의존성 파일만 먼저 복사 (레이어 캐싱 최적화)
COPY requirements.txt .

# 의존성 설치 (wheel 빌드, 사용자 디렉토리에 설치)
RUN pip install --no-cache-dir --user --upgrade pip && \
    pip install --no-cache-dir --user -r requirements.txt

# Stage 2: 최종 실행 이미지
FROM python:3.11-slim

# 보안을 위한 non-root 유저 생성 (UID 1000)
RUN groupadd -r appuser && \
    useradd -r -g appuser -u 1000 appuser && \
    mkdir -p /app && \
    chown -R appuser:appuser /app

WORKDIR /app

# builder 단계에서 설치한 패키지만 복사 (이미지 크기 최소화)
COPY --from=builder --chown=appuser:appuser /root/.local /home/appuser/.local

# 애플리케이션 코드 복사
COPY --chown=appuser:appuser main.py .

# PATH 환경변수에 pip 설치 경로 추가
ENV PATH=/home/appuser/.local/bin:$PATH \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

# 애플리케이션 포트
EXPOSE 8000

# non-root 유저로 전환 (보안 강화)
USER appuser

# 헬스체크 설정 (Python 내장 모듈 사용, curl 불필요)
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/health')" || exit 1

# 애플리케이션 실행 (프로덕션 최적화 옵션)
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "1", "--no-access-log"]
