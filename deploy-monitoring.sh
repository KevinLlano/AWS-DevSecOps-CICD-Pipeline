#!/bin/bash
# Deploy Prometheus & Grafana monitoring stack to EC2
# Run this script from your local machine after EC2 is ready

EC2_IP="13.220.204.80"
KEY_PATH="C:/Users/ke-bl/OneDrive/Documents/Pen KeyPairs/Texas (3).pem"
PROJECT_DIR="C:/Projects/Cloud Projects/dev_sec_ops_1"

echo "🚀 Deploying monitoring stack to EC2..."
echo "EC2 IP: $EC2_IP"
echo ""

# Wait for SSH to be ready
echo "⏳ Waiting for EC2 to be ready..."
max_attempts=30
attempt=1
while [ $attempt -le $max_attempts ]; do
    echo "Attempt $attempt/$max_attempts: Testing SSH connection..."
    if ssh -i "$KEY_PATH" -o ConnectTimeout=10 -o StrictHostKeyChecking=no ubuntu@$EC2_IP "echo 'SSH ready'" >/dev/null 2>&1; then
        echo "✅ SSH connection successful!"
        break
    fi
    if [ $attempt -eq $max_attempts ]; then
        echo "❌ SSH connection failed after $max_attempts attempts"
        exit 1
    fi
    echo "   Connection failed, waiting 30 seconds..."
    sleep 30
    ((attempt++))
done

# Step 1: Copy monitoring files to EC2
echo "📦 Step 1: Uploading docker-compose.monitoring.yml..."
scp -i "$KEY_PATH" -o StrictHostKeyChecking=no "$PROJECT_DIR/docker-compose.monitoring.yml" ubuntu@$EC2_IP:/home/ubuntu/

echo "📦 Step 2: Uploading monitoring directory..."
scp -i "$KEY_PATH" -o StrictHostKeyChecking=no -r "$PROJECT_DIR/monitoring" ubuntu@$EC2_IP:/home/ubuntu/

echo "✅ Files uploaded successfully!"
echo ""

# Step 2: SSH into EC2 and start monitoring stack
echo "🐳 Step 3: Starting Docker containers on EC2..."
ssh -i "$KEY_PATH" -o StrictHostKeyChecking=no ubuntu@$EC2_IP << 'ENDSSH'
cd /home/ubuntu
echo "Waiting for Docker to be ready..."
while ! docker ps >/dev/null 2>&1; do
    echo "Docker not ready yet, waiting 10 seconds..."
    sleep 10
done
echo "Docker is ready!"
docker-compose -f docker-compose.monitoring.yml up -d
echo ""
echo "✅ Monitoring stack started!"
echo ""
echo "🔍 Running containers:"
docker ps
ENDSSH

echo ""
echo "✅ Deployment complete!"
echo ""
echo "🌐 Access your dashboards:"
echo "   Prometheus: http://$EC2_IP:9090"
echo "   Grafana:    http://$EC2_IP:3001"
echo ""
echo "📝 Note: If the dashboards don't load immediately, wait 2-3 minutes"
echo "    for the containers to fully start, then try again."

