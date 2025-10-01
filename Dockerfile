# Job Ready Platform - Prolog Backend Dockerfile
FROM swipl:latest

# Set working directory
WORKDIR /app

# Copy Prolog backend
COPY main.pl /app/main.pl
COPY index.html /app/index.html

# Expose port 8080
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080/api/career-paths || exit 1

# Start Prolog HTTP server
CMD ["swipl", "-s", "main.pl", "-g", "start_server(8080)", "-t", "halt"]
