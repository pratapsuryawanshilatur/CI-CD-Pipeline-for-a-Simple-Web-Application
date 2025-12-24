'''
# Use an official Python runtime as a parent image
FROM python:3.9-slim 
# Set the working directory in the container
WORKDIR /app
# Copy the current directory contents into the container at /app 
COPY . .
# Install any needed dependencies specified in requirements.txt
RUN pip install --no-cache-dir -r requirements.txt
# Make port 5000 available to the world outside this container
EXPOSE 5000
# Run app.py when the container launches
CMD ["python", "app.py"]
'''

# Stage 1: Builder
From python:3.9-slim AS builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

# Stage 2: Final Runtime Image
FROM python:3.9-slim
WORKDIR /app

# Create a non-root user for security
RUN useradd -m -u 1000 appuser && chown -R appuser:appuser /app
USER appuser

# Copy installed packages from builder stage
COPY --from=builder --chown=appuser:appuser /root/.local /home/appuser/.local
COPY --chown=appuser:appuser app.py .

# Add .local/bin to PATH
ENV PATH=/home/appuser/.local/bin:$PATH

# Health check
HEALTHCHECK --interval=30s --timeout=3s, --start-period=5s, --retires=3 \
    CMD curl -f http://localhost:5000/ || exit 1

EXPOSE 5000
CMD ["python", "app.py"]