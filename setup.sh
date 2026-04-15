#!/bin/bash
# Exit on error
set -e

echo "Starting deployment setup..."

# 1. Update and install dependencies
apt-get update -y
apt-get install -y python3 python3-pip git python3-venv

# 2. Setup application directory
APP_DIR="/opt/portfolio"
mkdir -p $APP_DIR

# 3. Retrieve EC2 Instance ID using IMDSv2
TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/instance-id)

# If no instance ID found (e.g. not on AWS), default it
if [ -z "$INSTANCE_ID" ]; then
    INSTANCE_ID="i-local-fallback"
fi

# Store environment variable for the system
echo "INSTANCE_ID=$INSTANCE_ID" > /etc/environment
echo "PORT=80" >> /etc/environment

# Setup virtual environment
cd $APP_DIR
python3 -m venv venv
source venv/bin/activate

# Install Flask and other requirements
pip install -r requirements.txt

# 4. Setup Systemd Service
cp portfolio.service /etc/systemd/system/
systemctl daemon-reload
systemctl enable portfolio.service

# 5. Start the Application
systemctl start portfolio.service

echo "Deployment complete! Application should be accessible on port 80."
