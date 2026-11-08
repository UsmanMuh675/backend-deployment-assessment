
#!/bin/bash
set -euxo pipefail

# Update system packages
dnf update -y

# Install Docker and Git
dnf install -y docker git

# Start and enable Docker
systemctl enable --now docker

# Allow ec2-user to run Docker
usermod -aG docker ec2-user

# Verify installations
docker --version
git --version

echo "Backend server setup completed successfully"
