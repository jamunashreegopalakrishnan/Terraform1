FROM python:3.11-slim
RUN useradd --create-home --shell /bin/bash appuser
WORKDIR /home/appuser/app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY main.py .
RUN chown -R appuser:appuser /home/appuser/app
USER appuser
EXPOSE 8080
CMD ["python", "main.py"]