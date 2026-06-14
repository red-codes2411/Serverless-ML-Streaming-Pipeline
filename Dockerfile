# Use an official Python runtime as a lightweight parent image
FROM python:3.9-slim

# Set the working directory inside the container
WORKDIR /app

# Copy the requirements file and install dependencies first 
# (Doing this before copying app.py makes Docker rebuilds much faster!)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the actual application script
COPY app.py .

# Expose the port that Streamlit uses
EXPOSE 8501

# Command to boot up the Streamlit application
CMD ["streamlit", "run", "app.py", "--server.port=8501", "--server.address=0.0.0.0"]