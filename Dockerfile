# Use Python 3.6 or later as a base image
FROM python:latest

# Set working directory
WORKDIR /app

# Copy contents into image
COPY . .

# Install pip dependencies from requirements
RUN pip install --no-cache-dir -r requirements.txt

# Set YOUR_NAME environment variable
ENV YOUR_NAME="NAME"

# Expose the correct port
EXPOSE 5500

# Create an entrypoint
CMD ["python", "app.py"]
